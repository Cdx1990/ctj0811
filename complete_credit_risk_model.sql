-- 完整的客户逾期风险预测模型
-- Complete Credit Risk Prediction Model

-- ===========================================
-- 第一部分：数据准备和特征工程
-- ===========================================

-- 1. 创建交易特征提取视图
CREATE OR REPLACE VIEW transaction_features_extracted AS
SELECT 
    id,
    -- 基础交易统计
    COUNT(*) as total_transactions,
    COUNT(CASE WHEN label = 'C' THEN 1 END) as inflow_count,
    COUNT(CASE WHEN label = 'D' THEN 1 END) as outflow_count,
    
    -- 交易金额统计
    SUM(CASE WHEN label = 'C' THEN f5 ELSE 0 END) as total_inflow_amount,
    SUM(CASE WHEN label = 'D' THEN f5 ELSE 0 END) as total_outflow_amount,
    AVG(CASE WHEN label = 'C' THEN f5 END) as avg_inflow_amount,
    AVG(CASE WHEN label = 'D' THEN f5 END) as avg_outflow_amount,
    STDDEV(CASE WHEN label = 'C' THEN f5 END) as inflow_amount_std,
    STDDEV(CASE WHEN label = 'D' THEN f5 END) as outflow_amount_std,
    
    -- 时间窗口特征
    COUNT(CASE WHEN f2 >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 1 END) as transactions_last_30_days,
    COUNT(CASE WHEN f2 >= DATE_SUB(CURDATE(), INTERVAL 90 DAY) THEN 1 END) as transactions_last_90_days,
    COUNT(CASE WHEN f2 >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN 1 END) as transactions_last_7_days,
    
    -- 渠道和账户特征
    COUNT(DISTINCT f6) as channel_diversity,
    COUNT(CASE WHEN f1 = 'INV' THEN 1 END) as deposit_transactions,
    COUNT(CASE WHEN f1 = 'LON' THEN 1 END) as loan_transactions,
    
    -- 交易行为特征
    COUNT(CASE WHEN f9 = 1 THEN 1 END) * 1.0 / COUNT(*) as reversal_rate,
    COUNT(CASE WHEN f5 > 100000 THEN 1 END) as large_transaction_count,
    SUM(CASE WHEN f5 > 100000 AND label = 'C' THEN f5 ELSE 0 END) as large_inflow_amount,
    SUM(CASE WHEN f5 > 100000 AND label = 'D' THEN f5 ELSE 0 END) as large_outflow_amount,
    
    -- 交易时间跨度
    DATEDIFF(MAX(f2), MIN(f2)) as transaction_span_days,
    MIN(f2) as first_transaction_date,
    MAX(f2) as last_transaction_date,
    
    -- 金额分布特征
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f5) as median_transaction_amount,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY f5) as p95_transaction_amount,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY f5) as p99_transaction_amount

FROM market_train
GROUP BY id;

-- 2. 创建增强特征视图
CREATE OR REPLACE VIEW enhanced_customer_features AS
SELECT 
    t.*,
    -- 财务比率特征
    CASE WHEN t.f3 > 0 THEN t.f2 / t.f3 ELSE NULL END as asset_liability_ratio,
    CASE WHEN t.f6 > 0 THEN t.f5 / t.f6 ELSE NULL END as profit_margin,
    CASE WHEN t.f10 > 0 THEN t.f9 / t.f10 ELSE NULL END as receivables_ratio,
    CASE WHEN t.f11 > 0 THEN t.f10 / t.f11 ELSE NULL END as current_ratio,
    CASE WHEN t.f2 > 0 THEN t.f8 / t.f2 ELSE NULL END as cash_flow_ratio,
    
    -- 时间特征
    DATEDIFF(CURDATE(), t.f15) as company_age_days,
    DATEDIFF(CURDATE(), t.f21) as account_age_days,
    DATEDIFF(CURDATE(), t.f24) as legal_person_age_days,
    
    -- 企业规模分类
    CASE 
        WHEN t.f13 < 50 THEN 'small'
        WHEN t.f13 < 200 THEN 'medium'
        WHEN t.f13 < 1000 THEN 'large'
        ELSE 'enterprise'
    END as company_size_category,
    
    -- 行业风险等级
    CASE t.f17
        WHEN 'A' THEN 4  -- 农、林、牧、渔业 - 高风险
        WHEN 'B' THEN 4  -- 采矿业 - 高风险
        WHEN 'C' THEN 3  -- 制造业 - 中等风险
        WHEN 'D' THEN 1  -- 电力、燃气及水 - 低风险
        WHEN 'E' THEN 4  -- 建筑业 - 高风险
        WHEN 'F' THEN 3  -- 批发和零售业 - 中等风险
        WHEN 'G' THEN 3  -- 交通运输、仓储和邮政业 - 中等风险
        WHEN 'H' THEN 4  -- 住宿和餐饮业 - 高风险
        WHEN 'I' THEN 2  -- 信息传输、软件和信息技术服务业 - 低风险
        WHEN 'J' THEN 1  -- 金融业 - 低风险
        WHEN 'K' THEN 3  -- 房地产业 - 中等风险
        WHEN 'L' THEN 3  -- 租赁和商务服务业 - 中等风险
        WHEN 'M' THEN 2  -- 科学研究和技术服务业 - 低风险
        WHEN 'N' THEN 2  -- 水利、环境和公共设施管理业 - 低风险
        WHEN 'O' THEN 4  -- 居民服务、修理和其他服务业 - 高风险
        WHEN 'P' THEN 1  -- 教育 - 低风险
        WHEN 'Q' THEN 2  -- 卫生和社会工作 - 低风险
        WHEN 'R' THEN 4  -- 文化、体育和娱乐业 - 高风险
        WHEN 'S' THEN 1  -- 公共管理、社会保障和社会组织 - 低风险
        WHEN 'T' THEN 2  -- 国际组织 - 低风险
        ELSE 3  -- 其他 - 中等风险
    END as industry_risk_level,
    
    -- 企业性质风险等级
    CASE t.f14
        WHEN 'A' THEN 1  -- 国有企业 - 低风险
        WHEN 'B' THEN 2  -- 集体企业 - 中等风险
        WHEN 'C' THEN 3  -- 股份合作企业 - 中等风险
        WHEN 'D' THEN 3  -- 联营企业 - 中等风险
        WHEN 'E' THEN 1  -- 国有独资有限 - 低风险
        WHEN 'F' THEN 2  -- 其他有限责任 - 中等风险
        WHEN 'G' THEN 2  -- 股份有限公司 - 中等风险
        WHEN 'H' THEN 4  -- 私营企业 - 高风险
        WHEN 'I' THEN 4  -- 其他企业 - 高风险
        WHEN 'J' THEN 3  -- 港、澳、台商投资-中外合资 - 中等风险
        WHEN 'K' THEN 3  -- 港、澳、台商投资-中外合作 - 中等风险
        WHEN 'L' THEN 3  -- 港、澳、台商投资-外商独资 - 中等风险
        WHEN 'M' THEN 3  -- 港、澳、台商投资-股份有限 - 中等风险
        WHEN 'N' THEN 3  -- 外商投资-中外合资 - 中等风险
        WHEN 'O' THEN 3  -- 外商投资-中外合作 - 中等风险
        WHEN 'P' THEN 3  -- 外商投资-外商独资 - 中等风险
        WHEN 'Q' THEN 3  -- 外商投资-股份有限 - 中等风险
        WHEN 'R' THEN 1  -- 其他类型客户 - 低风险
        WHEN 'W' THEN 3  -- 不适用 - 中等风险
        WHEN 'Z' THEN 3  -- 外国企业 - 中等风险
        ELSE 3
    END as company_type_risk_level,
    
    -- 学历风险等级
    CASE t.f25
        WHEN 0 THEN 4  -- 其他 - 高风险
        WHEN 1 THEN 4  -- 小学 - 高风险
        WHEN 2 THEN 4  -- 初中 - 高风险
        WHEN 3 THEN 3  -- 高中 - 中等风险
        WHEN 4 THEN 3  -- 中职 - 中等风险
        WHEN 5 THEN 2  -- 专科 - 低风险
        WHEN 6 THEN 1  -- 本科 - 低风险
        WHEN 7 THEN 1  -- 硕士 - 低风险
        WHEN 8 THEN 1  -- 博士 - 低风险
        ELSE 3
    END as education_risk_level

FROM risk_train t;

-- 3. 创建完整特征集（包含交易特征）
CREATE OR REPLACE VIEW complete_feature_set AS
SELECT 
    e.*,
    COALESCE(tf.total_transactions, 0) as total_transactions,
    COALESCE(tf.inflow_count, 0) as inflow_count,
    COALESCE(tf.outflow_count, 0) as outflow_count,
    COALESCE(tf.total_inflow_amount, 0) as total_inflow_amount,
    COALESCE(tf.total_outflow_amount, 0) as total_outflow_amount,
    COALESCE(tf.avg_inflow_amount, 0) as avg_inflow_amount,
    COALESCE(tf.avg_outflow_amount, 0) as avg_outflow_amount,
    COALESCE(tf.inflow_amount_std, 0) as inflow_amount_std,
    COALESCE(tf.outflow_amount_std, 0) as outflow_amount_std,
    COALESCE(tf.transactions_last_30_days, 0) as transactions_last_30_days,
    COALESCE(tf.transactions_last_90_days, 0) as transactions_last_90_days,
    COALESCE(tf.transactions_last_7_days, 0) as transactions_last_7_days,
    COALESCE(tf.channel_diversity, 0) as channel_diversity,
    COALESCE(tf.deposit_transactions, 0) as deposit_transactions,
    COALESCE(tf.loan_transactions, 0) as loan_transactions,
    COALESCE(tf.transaction_span_days, 0) as transaction_span_days,
    COALESCE(tf.reversal_rate, 0) as reversal_rate,
    COALESCE(tf.large_transaction_count, 0) as large_transaction_count,
    COALESCE(tf.large_inflow_amount, 0) as large_inflow_amount,
    COALESCE(tf.large_outflow_amount, 0) as large_outflow_amount,
    COALESCE(tf.median_transaction_amount, 0) as median_transaction_amount,
    COALESCE(tf.p95_transaction_amount, 0) as p95_transaction_amount,
    COALESCE(tf.p99_transaction_amount, 0) as p99_transaction_amount,
    
    -- 交易行为比率特征
    CASE WHEN tf.total_transactions > 0 THEN tf.inflow_count * 1.0 / tf.total_transactions ELSE 0 END as inflow_ratio,
    CASE WHEN tf.total_transactions > 0 THEN tf.outflow_count * 1.0 / tf.total_transactions ELSE 0 END as outflow_ratio,
    CASE WHEN tf.total_outflow_amount > 0 THEN tf.total_inflow_amount / tf.total_outflow_amount ELSE 0 END as inflow_outflow_ratio,
    CASE WHEN tf.transaction_span_days > 0 THEN tf.total_transactions * 1.0 / tf.transaction_span_days ELSE 0 END as daily_transaction_frequency,
    CASE WHEN tf.total_transactions > 0 THEN tf.large_transaction_count * 1.0 / tf.total_transactions ELSE 0 END as large_transaction_ratio

FROM enhanced_customer_features e
LEFT JOIN transaction_features_extracted tf ON e.id = tf.id;

-- ===========================================
-- 第二部分：模型训练和预测
-- ===========================================

-- 4. 创建训练数据集
CREATE OR REPLACE VIEW training_dataset AS
SELECT 
    id,
    label,
    -- 基础财务特征
    f2, f3, f4, f5, f6, f7, f8, f9, f10, f11,
    -- 比率特征
    asset_liability_ratio, profit_margin, receivables_ratio, current_ratio, cash_flow_ratio,
    -- 时间特征
    company_age_days, account_age_days, legal_person_age_days,
    -- 风险等级特征
    industry_risk_level, company_type_risk_level, education_risk_level,
    -- 企业特征
    f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28, f29,
    -- 交易特征
    total_transactions, inflow_count, outflow_count, total_inflow_amount, total_outflow_amount,
    avg_inflow_amount, avg_outflow_amount, inflow_amount_std, outflow_amount_std,
    transactions_last_30_days, transactions_last_90_days, transactions_last_7_days, channel_diversity,
    deposit_transactions, loan_transactions, transaction_span_days, reversal_rate,
    large_transaction_count, large_inflow_amount, large_outflow_amount,
    median_transaction_amount, p95_transaction_amount, p99_transaction_amount,
    inflow_ratio, outflow_ratio, inflow_outflow_ratio, daily_transaction_frequency, large_transaction_ratio
FROM complete_feature_set
WHERE label IS NOT NULL;

-- 5. 创建测试数据集
CREATE OR REPLACE VIEW test_dataset AS
SELECT 
    id,
    -- 基础财务特征
    f2, f3, f4, f5, f6, f7, f8, f9, f10, f11,
    -- 比率特征
    asset_liability_ratio, profit_margin, receivables_ratio, current_ratio, cash_flow_ratio,
    -- 时间特征
    company_age_days, account_age_days, legal_person_age_days,
    -- 风险等级特征
    industry_risk_level, company_type_risk_level, education_risk_level,
    -- 企业特征
    f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28, f29,
    -- 交易特征
    total_transactions, inflow_count, outflow_count, total_inflow_amount, total_outflow_amount,
    avg_inflow_amount, avg_outflow_amount, inflow_amount_std, outflow_amount_std,
    transactions_last_30_days, transactions_last_90_days, transactions_last_7_days, channel_diversity,
    deposit_transactions, loan_transactions, transaction_span_days, reversal_rate,
    large_transaction_count, large_inflow_amount, large_outflow_amount,
    median_transaction_amount, p95_transaction_amount, p99_transaction_amount,
    inflow_ratio, outflow_ratio, inflow_outflow_ratio, daily_transaction_frequency, large_transaction_ratio
FROM complete_feature_set
WHERE label IS NULL;

-- 6. 计算特征重要性（基于相关性）
CREATE OR REPLACE VIEW feature_importance AS
SELECT 
    'asset_liability_ratio' as feature_name, 
    CORR(asset_liability_ratio, label) as correlation,
    ABS(CORR(asset_liability_ratio, label)) as abs_correlation
FROM training_dataset
WHERE asset_liability_ratio IS NOT NULL
UNION ALL
SELECT 'profit_margin', CORR(profit_margin, label), ABS(CORR(profit_margin, label))
FROM training_dataset
WHERE profit_margin IS NOT NULL
UNION ALL
SELECT 'current_ratio', CORR(current_ratio, label), ABS(CORR(current_ratio, label))
FROM training_dataset
WHERE current_ratio IS NOT NULL
UNION ALL
SELECT 'industry_risk_level', CORR(industry_risk_level, label), ABS(CORR(industry_risk_level, label))
FROM training_dataset
WHERE industry_risk_level IS NOT NULL
UNION ALL
SELECT 'company_type_risk_level', CORR(company_type_risk_level, label), ABS(CORR(company_type_risk_level, label))
FROM training_dataset
WHERE company_type_risk_level IS NOT NULL
UNION ALL
SELECT 'education_risk_level', CORR(education_risk_level, label), ABS(CORR(education_risk_level, label))
FROM training_dataset
WHERE education_risk_level IS NOT NULL
UNION ALL
SELECT 'reversal_rate', CORR(reversal_rate, label), ABS(CORR(reversal_rate, label))
FROM training_dataset
WHERE reversal_rate IS NOT NULL
UNION ALL
SELECT 'inflow_outflow_ratio', CORR(inflow_outflow_ratio, label), ABS(CORR(inflow_outflow_ratio, label))
FROM training_dataset
WHERE inflow_outflow_ratio IS NOT NULL
UNION ALL
SELECT 'daily_transaction_frequency', CORR(daily_transaction_frequency, label), ABS(CORR(daily_transaction_frequency, label))
FROM training_dataset
WHERE daily_transaction_frequency IS NOT NULL
UNION ALL
SELECT 'f18', CORR(f18, label), ABS(CORR(f18, label))
FROM training_dataset
WHERE f18 IS NOT NULL
UNION ALL
SELECT 'f20', CORR(f20, label), ABS(CORR(f20, label))
FROM training_dataset
WHERE f20 IS NOT NULL
UNION ALL
SELECT 'f8', CORR(f8, label), ABS(CORR(f8, label))
FROM training_dataset
WHERE f8 IS NOT NULL
UNION ALL
SELECT 'f5', CORR(f5, label), ABS(CORR(f5, label))
FROM training_dataset
WHERE f5 IS NOT NULL
UNION ALL
SELECT 'f2', CORR(f2, label), ABS(CORR(f2, label))
FROM training_dataset
WHERE f2 IS NOT NULL
UNION ALL
SELECT 'f3', CORR(f3, label), ABS(CORR(f3, label))
FROM training_dataset
WHERE f3 IS NOT NULL;

-- 7. 创建简化的逻辑回归模型
CREATE OR REPLACE VIEW logistic_regression_model AS
WITH feature_weights AS (
    SELECT 
        -- 基于相关性的权重计算
        COALESCE(SUM(CASE WHEN feature_name = 'asset_liability_ratio' THEN correlation * 2 ELSE 0 END), 0) as w_asset_liability,
        COALESCE(SUM(CASE WHEN feature_name = 'profit_margin' THEN correlation * 2 ELSE 0 END), 0) as w_profit_margin,
        COALESCE(SUM(CASE WHEN feature_name = 'current_ratio' THEN correlation * 2 ELSE 0 END), 0) as w_current_ratio,
        COALESCE(SUM(CASE WHEN feature_name = 'industry_risk_level' THEN correlation * 2 ELSE 0 END), 0) as w_industry_risk,
        COALESCE(SUM(CASE WHEN feature_name = 'company_type_risk_level' THEN correlation * 2 ELSE 0 END), 0) as w_company_type_risk,
        COALESCE(SUM(CASE WHEN feature_name = 'education_risk_level' THEN correlation * 2 ELSE 0 END), 0) as w_education_risk,
        COALESCE(SUM(CASE WHEN feature_name = 'reversal_rate' THEN correlation * 2 ELSE 0 END), 0) as w_reversal_rate,
        COALESCE(SUM(CASE WHEN feature_name = 'inflow_outflow_ratio' THEN correlation * 2 ELSE 0 END), 0) as w_inflow_outflow_ratio,
        COALESCE(SUM(CASE WHEN feature_name = 'daily_transaction_frequency' THEN correlation * 2 ELSE 0 END), 0) as w_daily_frequency,
        COALESCE(SUM(CASE WHEN feature_name = 'f18' THEN correlation * 2 ELSE 0 END), 0) as w_private_company,
        COALESCE(SUM(CASE WHEN feature_name = 'f20' THEN correlation * 2 ELSE 0 END), 0) as w_new_customer,
        COALESCE(SUM(CASE WHEN feature_name = 'f8' THEN correlation * 2 ELSE 0 END), 0) as w_cash_flow,
        COALESCE(SUM(CASE WHEN feature_name = 'f5' THEN correlation * 2 ELSE 0 END), 0) as w_profit,
        COALESCE(SUM(CASE WHEN feature_name = 'f2' THEN correlation * 2 ELSE 0 END), 0) as w_assets,
        COALESCE(SUM(CASE WHEN feature_name = 'f3' THEN correlation * 2 ELSE 0 END), 0) as w_liabilities,
        -- 截距项
        LOG(AVG(CASE WHEN label = 1 THEN 1 ELSE 0 END) / (1 - AVG(CASE WHEN label = 1 THEN 1 ELSE 0 END))) as intercept
    FROM feature_importance
    CROSS JOIN training_dataset
)
SELECT * FROM feature_weights;

-- 8. 生成测试集预测结果
CREATE OR REPLACE VIEW test_predictions AS
WITH normalized_test_features AS (
    SELECT 
        id,
        -- 特征标准化（使用训练集的统计量）
        (asset_liability_ratio - (SELECT AVG(asset_liability_ratio) FROM training_dataset)) / 
        (SELECT STDDEV(asset_liability_ratio) FROM training_dataset) as asset_liability_norm,
        (profit_margin - (SELECT AVG(profit_margin) FROM training_dataset)) / 
        (SELECT STDDEV(profit_margin) FROM training_dataset) as profit_margin_norm,
        (current_ratio - (SELECT AVG(current_ratio) FROM training_dataset)) / 
        (SELECT STDDEV(current_ratio) FROM training_dataset) as current_ratio_norm,
        (industry_risk_level - (SELECT AVG(industry_risk_level) FROM training_dataset)) / 
        (SELECT STDDEV(industry_risk_level) FROM training_dataset) as industry_risk_norm,
        (company_type_risk_level - (SELECT AVG(company_type_risk_level) FROM training_dataset)) / 
        (SELECT STDDEV(company_type_risk_level) FROM training_dataset) as company_type_risk_norm,
        (education_risk_level - (SELECT AVG(education_risk_level) FROM training_dataset)) / 
        (SELECT STDDEV(education_risk_level) FROM training_dataset) as education_risk_norm,
        (reversal_rate - (SELECT AVG(reversal_rate) FROM training_dataset)) / 
        (SELECT STDDEV(reversal_rate) FROM training_dataset) as reversal_rate_norm,
        (inflow_outflow_ratio - (SELECT AVG(inflow_outflow_ratio) FROM training_dataset)) / 
        (SELECT STDDEV(inflow_outflow_ratio) FROM training_dataset) as inflow_outflow_ratio_norm,
        (daily_transaction_frequency - (SELECT AVG(daily_transaction_frequency) FROM training_dataset)) / 
        (SELECT STDDEV(daily_transaction_frequency) FROM training_dataset) as daily_frequency_norm,
        (f8 - (SELECT AVG(f8) FROM training_dataset)) / (SELECT STDDEV(f8) FROM training_dataset) as cash_flow_norm,
        (f5 - (SELECT AVG(f5) FROM training_dataset)) / (SELECT STDDEV(f5) FROM training_dataset) as profit_norm,
        (f2 - (SELECT AVG(f2) FROM training_dataset)) / (SELECT STDDEV(f2) FROM training_dataset) as assets_norm,
        (f3 - (SELECT AVG(f3) FROM training_dataset)) / (SELECT STDDEV(f3) FROM training_dataset) as liabilities_norm,
        -- 分类特征
        f18 as private_company_flag,
        f20 as new_customer_flag
    FROM test_dataset
),
predictions AS (
    SELECT 
        t.id,
        -- 计算线性组合
        m.intercept + 
        m.w_asset_liability * COALESCE(t.asset_liability_norm, 0) +
        m.w_profit_margin * COALESCE(t.profit_margin_norm, 0) +
        m.w_current_ratio * COALESCE(t.current_ratio_norm, 0) +
        m.w_industry_risk * COALESCE(t.industry_risk_norm, 0) +
        m.w_company_type_risk * COALESCE(t.company_type_risk_norm, 0) +
        m.w_education_risk * COALESCE(t.education_risk_norm, 0) +
        m.w_reversal_rate * COALESCE(t.reversal_rate_norm, 0) +
        m.w_inflow_outflow_ratio * COALESCE(t.inflow_outflow_ratio_norm, 0) +
        m.w_daily_frequency * COALESCE(t.daily_frequency_norm, 0) +
        m.w_private_company * COALESCE(t.private_company_flag, 0) +
        m.w_new_customer * COALESCE(t.new_customer_flag, 0) +
        m.w_cash_flow * COALESCE(t.cash_flow_norm, 0) +
        m.w_profit * COALESCE(t.profit_norm, 0) +
        m.w_assets * COALESCE(t.assets_norm, 0) +
        m.w_liabilities * COALESCE(t.liabilities_norm, 0) as linear_combination
    FROM normalized_test_features t
    CROSS JOIN logistic_regression_model m
)
SELECT 
    id,
    -- 使用sigmoid函数计算概率
    1.0 / (1.0 + EXP(-linear_combination)) as predicted_probability
FROM predictions;

-- ===========================================
-- 第三部分：结果输出和评估
-- ===========================================

-- 9. 生成最终预测结果
CREATE OR REPLACE VIEW final_prediction_results AS
SELECT 
    id,
    ROUND(predicted_probability, 6) as predicted_probability,
    ROW_NUMBER() OVER (ORDER BY predicted_probability DESC) as risk_rank
FROM test_predictions
ORDER BY predicted_probability DESC;

-- 10. 模型特征重要性分析
CREATE OR REPLACE VIEW model_feature_analysis AS
SELECT 
    feature_name,
    correlation,
    abs_correlation,
    ROW_NUMBER() OVER (ORDER BY abs_correlation DESC) as importance_rank
FROM feature_importance
ORDER BY abs_correlation DESC;

-- 11. 风险等级分布分析
CREATE OR REPLACE VIEW risk_distribution_analysis AS
SELECT 
    CASE 
        WHEN predicted_probability >= 0.8 THEN '极高风险'
        WHEN predicted_probability >= 0.6 THEN '高风险'
        WHEN predicted_probability >= 0.4 THEN '中等风险'
        WHEN predicted_probability >= 0.2 THEN '低风险'
        ELSE '极低风险'
    END as risk_level,
    COUNT(*) as customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM final_prediction_results), 2) as percentage
FROM final_prediction_results
GROUP BY 
    CASE 
        WHEN predicted_probability >= 0.8 THEN '极高风险'
        WHEN predicted_probability >= 0.6 THEN '高风险'
        WHEN predicted_probability >= 0.4 THEN '中等风险'
        WHEN predicted_probability >= 0.2 THEN '低风险'
        ELSE '极低风险'
    END
ORDER BY 
    CASE 
        WHEN predicted_probability >= 0.8 THEN 1
        WHEN predicted_probability >= 0.6 THEN 2
        WHEN predicted_probability >= 0.4 THEN 3
        WHEN predicted_probability >= 0.2 THEN 4
        ELSE 5
    END;

-- 12. 输出最终预测结果（用于提交）
SELECT 
    id,
    predicted_probability
FROM final_prediction_results
ORDER BY id;