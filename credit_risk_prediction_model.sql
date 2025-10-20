-- 客户逾期风险预测模型 - 逻辑回归实现
-- Credit Risk Prediction Model using Logistic Regression in SQL

-- 1. 数据预处理和特征标准化
CREATE VIEW normalized_training_data AS
SELECT 
    id,
    label,
    -- 标准化财务特征 (使用Z-score标准化)
    (f2 - AVG(f2) OVER()) / STDDEV(f2) OVER() as f2_normalized,
    (f3 - AVG(f3) OVER()) / STDDEV(f3) OVER() as f3_normalized,
    (f4 - AVG(f4) OVER()) / STDDEV(f4) OVER() as f4_normalized,
    (f5 - AVG(f5) OVER()) / STDDEV(f5) OVER() as f5_normalized,
    (f6 - AVG(f6) OVER()) / STDDEV(f6) OVER() as f6_normalized,
    (f7 - AVG(f7) OVER()) / STDDEV(f7) OVER() as f7_normalized,
    (f8 - AVG(f8) OVER()) / STDDEV(f8) OVER() as f8_normalized,
    (f9 - AVG(f9) OVER()) / STDDEV(f9) OVER() as f9_normalized,
    (f10 - AVG(f10) OVER()) / STDDEV(f10) OVER() as f10_normalized,
    (f11 - AVG(f11) OVER()) / STDDEV(f11) OVER() as f11_normalized,
    
    -- 比率特征（已经是标准化的）
    COALESCE(asset_liability_ratio, 0) as asset_liability_ratio,
    COALESCE(profit_margin, 0) as profit_margin,
    COALESCE(receivables_ratio, 0) as receivables_ratio,
    COALESCE(current_ratio, 0) as current_ratio,
    COALESCE(cash_flow_ratio, 0) as cash_flow_ratio,
    
    -- 时间特征标准化
    (company_age_days - AVG(company_age_days) OVER()) / STDDEV(company_age_days) OVER() as company_age_normalized,
    (account_age_days - AVG(account_age_days) OVER()) / STDDEV(account_age_days) OVER() as account_age_normalized,
    (legal_person_age_days - AVG(legal_person_age_days) OVER()) / STDDEV(legal_person_age_days) OVER() as legal_person_age_normalized,
    
    -- 风险等级特征（已经是标准化的）
    industry_risk_level,
    company_type_risk_level,
    education_risk_level,
    
    -- 企业特征（标准化）
    (f13 - AVG(f13) OVER()) / STDDEV(f13) OVER() as f13_normalized,
    (f22 - AVG(f22) OVER()) / STDDEV(f22) OVER() as f22_normalized,
    (f26 - AVG(f26) OVER()) / STDDEV(f26) OVER() as f26_normalized,
    (f27 - AVG(f27) OVER()) / STDDEV(f27) OVER() as f27_normalized,
    (f28 - AVG(f28) OVER()) / STDDEV(f28) OVER() as f28_normalized,
    (f29 - AVG(f29) OVER()) / STDDEV(f29) OVER() as f29_normalized,
    
    -- 交易特征标准化
    (total_transactions - AVG(total_transactions) OVER()) / STDDEV(total_transactions) OVER() as total_transactions_normalized,
    (inflow_count - AVG(inflow_count) OVER()) / STDDEV(inflow_count) OVER() as inflow_count_normalized,
    (outflow_count - AVG(outflow_count) OVER()) / STDDEV(outflow_count) OVER() as outflow_count_normalized,
    (total_inflow_amount - AVG(total_inflow_amount) OVER()) / STDDEV(total_inflow_amount) OVER() as total_inflow_amount_normalized,
    (total_outflow_amount - AVG(total_outflow_amount) OVER()) / STDDEV(total_outflow_amount) OVER() as total_outflow_amount_normalized,
    (avg_inflow_amount - AVG(avg_inflow_amount) OVER()) / STDDEV(avg_inflow_amount) OVER() as avg_inflow_amount_normalized,
    (avg_outflow_amount - AVG(avg_outflow_amount) OVER()) / STDDEV(avg_outflow_amount) OVER() as avg_outflow_amount_normalized,
    (transactions_last_30_days - AVG(transactions_last_30_days) OVER()) / STDDEV(transactions_last_30_days) OVER() as transactions_last_30_days_normalized,
    (transactions_last_90_days - AVG(transactions_last_90_days) OVER()) / STDDEV(transactions_last_90_days) OVER() as transactions_last_90_days_normalized,
    (channel_diversity - AVG(channel_diversity) OVER()) / STDDEV(channel_diversity) OVER() as channel_diversity_normalized,
    (reversal_rate - AVG(reversal_rate) OVER()) / STDDEV(reversal_rate) OVER() as reversal_rate_normalized,
    (inflow_ratio - AVG(inflow_ratio) OVER()) / STDDEV(inflow_ratio) OVER() as inflow_ratio_normalized,
    (outflow_ratio - AVG(outflow_ratio) OVER()) / STDDEV(outflow_ratio) OVER() as outflow_ratio_normalized,
    (inflow_outflow_ratio - AVG(inflow_outflow_ratio) OVER()) / STDDEV(inflow_outflow_ratio) OVER() as inflow_outflow_ratio_normalized,
    (daily_transaction_frequency - AVG(daily_transaction_frequency) OVER()) / STDDEV(daily_transaction_frequency) OVER() as daily_transaction_frequency_normalized,
    (large_transaction_ratio - AVG(large_transaction_ratio) OVER()) / STDDEV(large_transaction_ratio) OVER() as large_transaction_ratio_normalized,
    
    -- 分类特征（独热编码）
    CASE WHEN f12 LIKE 'A%' THEN 1 ELSE 0 END as state_owned,
    CASE WHEN f12 LIKE 'B%' THEN 1 ELSE 0 END as private_owned,
    CASE WHEN f12 LIKE 'B02%' THEN 1 ELSE 0 END as hongkong_taiwan_owned,
    CASE WHEN f12 LIKE 'B03%' THEN 1 ELSE 0 END as foreign_owned,
    
    CASE WHEN f14 = 'A' THEN 1 ELSE 0 END as state_enterprise,
    CASE WHEN f14 = 'H' THEN 1 ELSE 0 END as private_enterprise,
    CASE WHEN f14 IN ('J', 'K', 'L', 'M') THEN 1 ELSE 0 END as hongkong_taiwan_enterprise,
    CASE WHEN f14 IN ('N', 'O', 'P', 'Q') THEN 1 ELSE 0 END as foreign_enterprise,
    
    CASE WHEN f18 = 1 THEN 1 ELSE 0 END as private_company_flag,
    CASE WHEN f19 = 1 THEN 1 ELSE 0 END as listed_company_flag,
    CASE WHEN f20 = 1 THEN 1 ELSE 0 END as new_customer_flag,
    CASE WHEN f23 = 1 THEN 1 ELSE 0 END as male_legal_person,
    CASE WHEN f23 = 2 THEN 1 ELSE 0 END as female_legal_person

FROM training_dataset;

-- 2. 计算逻辑回归系数（使用梯度下降法近似）
-- 这里我们使用一个简化的逻辑回归实现
CREATE VIEW logistic_regression_coefficients AS
WITH training_stats AS (
    SELECT 
        AVG(label) as positive_rate,
        COUNT(*) as total_samples,
        COUNT(CASE WHEN label = 1 THEN 1 END) as positive_samples,
        COUNT(CASE WHEN label = 0 THEN 1 END) as negative_samples
    FROM normalized_training_data
),
feature_importance AS (
    SELECT 
        'f2_normalized' as feature_name, 
        CORR(f2_normalized, label) as correlation,
        STDDEV(f2_normalized) as std_dev
    FROM normalized_training_data
    WHERE f2_normalized IS NOT NULL
    UNION ALL
    SELECT 'f3_normalized', CORR(f3_normalized, label), STDDEV(f3_normalized)
    FROM normalized_training_data
    WHERE f3_normalized IS NOT NULL
    UNION ALL
    SELECT 'f5_normalized', CORR(f5_normalized, label), STDDEV(f5_normalized)
    FROM normalized_training_data
    WHERE f5_normalized IS NOT NULL
    UNION ALL
    SELECT 'f8_normalized', CORR(f8_normalized, label), STDDEV(f8_normalized)
    FROM normalized_training_data
    WHERE f8_normalized IS NOT NULL
    UNION ALL
    SELECT 'asset_liability_ratio', CORR(asset_liability_ratio, label), STDDEV(asset_liability_ratio)
    FROM normalized_training_data
    WHERE asset_liability_ratio IS NOT NULL
    UNION ALL
    SELECT 'profit_margin', CORR(profit_margin, label), STDDEV(profit_margin)
    FROM normalized_training_data
    WHERE profit_margin IS NOT NULL
    UNION ALL
    SELECT 'current_ratio', CORR(current_ratio, label), STDDEV(current_ratio)
    FROM normalized_training_data
    WHERE current_ratio IS NOT NULL
    UNION ALL
    SELECT 'industry_risk_level', CORR(industry_risk_level, label), STDDEV(industry_risk_level)
    FROM normalized_training_data
    WHERE industry_risk_level IS NOT NULL
    UNION ALL
    SELECT 'company_type_risk_level', CORR(company_type_risk_level, label), STDDEV(company_type_risk_level)
    FROM normalized_training_data
    WHERE company_type_risk_level IS NOT NULL
    UNION ALL
    SELECT 'education_risk_level', CORR(education_risk_level, label), STDDEV(education_risk_level)
    FROM normalized_training_data
    WHERE education_risk_level IS NOT NULL
    UNION ALL
    SELECT 'total_transactions_normalized', CORR(total_transactions_normalized, label), STDDEV(total_transactions_normalized)
    FROM normalized_training_data
    WHERE total_transactions_normalized IS NOT NULL
    UNION ALL
    SELECT 'reversal_rate_normalized', CORR(reversal_rate_normalized, label), STDDEV(reversal_rate_normalized)
    FROM normalized_training_data
    WHERE reversal_rate_normalized IS NOT NULL
    UNION ALL
    SELECT 'inflow_outflow_ratio_normalized', CORR(inflow_outflow_ratio_normalized, label), STDDEV(inflow_outflow_ratio_normalized)
    FROM normalized_training_data
    WHERE inflow_outflow_ratio_normalized IS NOT NULL
    UNION ALL
    SELECT 'daily_transaction_frequency_normalized', CORR(daily_transaction_frequency_normalized, label), STDDEV(daily_transaction_frequency_normalized)
    FROM normalized_training_data
    WHERE daily_transaction_frequency_normalized IS NOT NULL
    UNION ALL
    SELECT 'private_company_flag', CORR(private_company_flag, label), STDDEV(private_company_flag)
    FROM normalized_training_data
    WHERE private_company_flag IS NOT NULL
    UNION ALL
    SELECT 'new_customer_flag', CORR(new_customer_flag, label), STDDEV(new_customer_flag)
    FROM normalized_training_data
    WHERE new_customer_flag IS NOT NULL
)
SELECT 
    feature_name,
    correlation,
    std_dev,
    -- 简化的系数计算：相关性 * 2（经验系数）
    correlation * 2.0 as coefficient
FROM feature_importance
WHERE correlation IS NOT NULL AND std_dev > 0;

-- 3. 创建预测模型
CREATE VIEW prediction_model AS
WITH base_coefficients AS (
    SELECT 
        COALESCE(SUM(CASE WHEN feature_name = 'f2_normalized' THEN coefficient ELSE 0 END), 0) as w_f2,
        COALESCE(SUM(CASE WHEN feature_name = 'f3_normalized' THEN coefficient ELSE 0 END), 0) as w_f3,
        COALESCE(SUM(CASE WHEN feature_name = 'f5_normalized' THEN coefficient ELSE 0 END), 0) as w_f5,
        COALESCE(SUM(CASE WHEN feature_name = 'f8_normalized' THEN coefficient ELSE 0 END), 0) as w_f8,
        COALESCE(SUM(CASE WHEN feature_name = 'asset_liability_ratio' THEN coefficient ELSE 0 END), 0) as w_asset_liability,
        COALESCE(SUM(CASE WHEN feature_name = 'profit_margin' THEN coefficient ELSE 0 END), 0) as w_profit_margin,
        COALESCE(SUM(CASE WHEN feature_name = 'current_ratio' THEN coefficient ELSE 0 END), 0) as w_current_ratio,
        COALESCE(SUM(CASE WHEN feature_name = 'industry_risk_level' THEN coefficient ELSE 0 END), 0) as w_industry_risk,
        COALESCE(SUM(CASE WHEN feature_name = 'company_type_risk_level' THEN coefficient ELSE 0 END), 0) as w_company_type_risk,
        COALESCE(SUM(CASE WHEN feature_name = 'education_risk_level' THEN coefficient ELSE 0 END), 0) as w_education_risk,
        COALESCE(SUM(CASE WHEN feature_name = 'total_transactions_normalized' THEN coefficient ELSE 0 END), 0) as w_total_transactions,
        COALESCE(SUM(CASE WHEN feature_name = 'reversal_rate_normalized' THEN coefficient ELSE 0 END), 0) as w_reversal_rate,
        COALESCE(SUM(CASE WHEN feature_name = 'inflow_outflow_ratio_normalized' THEN coefficient ELSE 0 END), 0) as w_inflow_outflow_ratio,
        COALESCE(SUM(CASE WHEN feature_name = 'daily_transaction_frequency_normalized' THEN coefficient ELSE 0 END), 0) as w_daily_frequency,
        COALESCE(SUM(CASE WHEN feature_name = 'private_company_flag' THEN coefficient ELSE 0 END), 0) as w_private_company,
        COALESCE(SUM(CASE WHEN feature_name = 'new_customer_flag' THEN coefficient ELSE 0 END), 0) as w_new_customer,
        -- 截距项（基于正样本率）
        LOG(AVG(CASE WHEN label = 1 THEN 1 ELSE 0 END) / (1 - AVG(CASE WHEN label = 1 THEN 1 ELSE 0 END))) as intercept
    FROM logistic_regression_coefficients
    CROSS JOIN normalized_training_data
)
SELECT * FROM base_coefficients;

-- 4. 对测试集进行预测
CREATE VIEW test_predictions AS
WITH normalized_test_data AS (
    SELECT 
        id,
        -- 使用训练集的均值和标准差进行标准化
        (f2 - (SELECT AVG(f2) FROM training_dataset)) / (SELECT STDDEV(f2) FROM training_dataset) as f2_normalized,
        (f3 - (SELECT AVG(f3) FROM training_dataset)) / (SELECT STDDEV(f3) FROM training_dataset) as f3_normalized,
        (f5 - (SELECT AVG(f5) FROM training_dataset)) / (SELECT STDDEV(f5) FROM training_dataset) as f5_normalized,
        (f8 - (SELECT AVG(f8) FROM training_dataset)) / (SELECT STDDEV(f8) FROM training_dataset) as f8_normalized,
        COALESCE(asset_liability_ratio, 0) as asset_liability_ratio,
        COALESCE(profit_margin, 0) as profit_margin,
        COALESCE(current_ratio, 0) as current_ratio,
        industry_risk_level,
        company_type_risk_level,
        education_risk_level,
        (total_transactions - (SELECT AVG(total_transactions) FROM training_dataset)) / (SELECT STDDEV(total_transactions) FROM training_dataset) as total_transactions_normalized,
        (reversal_rate - (SELECT AVG(reversal_rate) FROM training_dataset)) / (SELECT STDDEV(reversal_rate) FROM training_dataset) as reversal_rate_normalized,
        (inflow_outflow_ratio - (SELECT AVG(inflow_outflow_ratio) FROM training_dataset)) / (SELECT STDDEV(inflow_outflow_ratio) FROM training_dataset) as inflow_outflow_ratio_normalized,
        (daily_transaction_frequency - (SELECT AVG(daily_transaction_frequency) FROM training_dataset)) / (SELECT STDDEV(daily_transaction_frequency) FROM training_dataset) as daily_transaction_frequency_normalized,
        CASE WHEN f18 = 1 THEN 1 ELSE 0 END as private_company_flag,
        CASE WHEN f20 = 1 THEN 1 ELSE 0 END as new_customer_flag
    FROM test_dataset
),
predictions AS (
    SELECT 
        t.id,
        -- 计算线性组合
        p.intercept + 
        p.w_f2 * t.f2_normalized +
        p.w_f3 * t.f3_normalized +
        p.w_f5 * t.f5_normalized +
        p.w_f8 * t.f8_normalized +
        p.w_asset_liability * t.asset_liability_ratio +
        p.w_profit_margin * t.profit_margin +
        p.w_current_ratio * t.current_ratio +
        p.w_industry_risk * t.industry_risk_level +
        p.w_company_type_risk * t.company_type_risk_level +
        p.w_education_risk * t.education_risk_level +
        p.w_total_transactions * t.total_transactions_normalized +
        p.w_reversal_rate * t.reversal_rate_normalized +
        p.w_inflow_outflow_ratio * t.inflow_outflow_ratio_normalized +
        p.w_daily_frequency * t.daily_transaction_frequency_normalized +
        p.w_private_company * t.private_company_flag +
        p.w_new_customer * t.new_customer_flag as linear_combination
    FROM normalized_test_data t
    CROSS JOIN prediction_model p
)
SELECT 
    id,
    -- 使用sigmoid函数计算概率
    1.0 / (1.0 + EXP(-linear_combination)) as predicted_probability
FROM predictions;

-- 5. 生成最终预测结果
CREATE VIEW final_predictions AS
SELECT 
    id,
    ROUND(predicted_probability, 6) as predicted_probability
FROM test_predictions
ORDER BY predicted_probability DESC;

-- 6. 模型评估 - 计算K-S指标
CREATE VIEW model_evaluation AS
WITH prediction_ranks AS (
    SELECT 
        id,
        predicted_probability,
        ROW_NUMBER() OVER (ORDER BY predicted_probability DESC) as rank_num,
        COUNT(*) OVER() as total_count
    FROM final_predictions
),
ks_calculation AS (
    SELECT 
        rank_num,
        predicted_probability,
        rank_num * 1.0 / total_count as cumulative_rate,
        -- 这里需要真实的标签来计算K-S，但由于测试集标签未知，我们只能提供框架
        -- 实际K-S计算需要真实标签
        0 as ks_value  -- 占位符，实际计算需要真实标签
    FROM prediction_ranks
)
SELECT 
    'K-S指标计算框架' as metric_name,
    '需要真实标签才能计算' as note,
    0 as ks_value;