-- 客户逾期风险预测模型
-- Credit Risk Prediction Model using SQL

-- 1. 创建训练数据表结构
CREATE TABLE risk_train (
    id VARCHAR(50) PRIMARY KEY,
    label INT,  -- 1-坏客户，0-好客户
    f1 DATE,   -- 财务报表日期
    f2 DECIMAL(15,2),  -- 资产总额
    f3 DECIMAL(15,2),  -- 负债总额
    f4 DECIMAL(15,2),  -- 所得税
    f5 DECIMAL(15,2),  -- 净利润
    f6 DECIMAL(15,2),  -- 主营业务收入
    f7 DECIMAL(15,2),  -- 存货
    f8 DECIMAL(15,2),  -- 现金流量净额
    f9 DECIMAL(15,2),  -- 应收账款
    f10 DECIMAL(15,2), -- 流动资产合计
    f11 DECIMAL(15,2), -- 流动负债合计
    f12 VARCHAR(10),   -- 企业经济成分
    f13 INT,           -- 企业从业人数
    f14 VARCHAR(5),    -- 企业性质
    f15 DATE,          -- 成立日期
    f16 VARCHAR(7),    -- 首次建立信贷关系年月
    f17 VARCHAR(5),    -- 行业分类
    f18 INT,           -- 民营企业标识
    f19 INT,           -- 上市公司标志
    f20 INT,           -- 新客户标识
    f21 DATE,          -- 开户日期
    f22 INT,           -- 公司法人年龄
    f23 INT,           -- 公司法人性别
    f24 DATE,          -- 公司法人出生日期
    f25 INT,           -- 公司法人最高学历
    f26 DECIMAL(15,2), -- 公司法人客户月日均金融资产（前1月）
    f27 DECIMAL(15,2), -- 公司法人客户月日均金融资产（前3个月）
    f28 DECIMAL(15,2), -- 公司法人最近1个月总流入金额
    f29 DECIMAL(15,2)  -- 公司法人最近3个月总流入金额
);

-- 2. 创建测试数据表结构
CREATE TABLE risk_test (
    id VARCHAR(50) PRIMARY KEY,
    label INT,  -- 空值，需要预测
    f1 DATE,
    f2 DECIMAL(15,2),
    f3 DECIMAL(15,2),
    f4 DECIMAL(15,2),
    f5 DECIMAL(15,2),
    f6 DECIMAL(15,2),
    f7 DECIMAL(15,2),
    f8 DECIMAL(15,2),
    f9 DECIMAL(15,2),
    f10 DECIMAL(15,2),
    f11 DECIMAL(15,2),
    f12 VARCHAR(10),
    f13 INT,
    f14 VARCHAR(5),
    f15 DATE,
    f16 VARCHAR(7),
    f17 VARCHAR(5),
    f18 INT,
    f19 INT,
    f20 INT,
    f21 DATE,
    f22 INT,
    f23 INT,
    f24 DATE,
    f25 INT,
    f26 DECIMAL(15,2),
    f27 DECIMAL(15,2),
    f28 DECIMAL(15,2),
    f29 DECIMAL(15,2)
);

-- 3. 创建交易数据表结构
CREATE TABLE market_train (
    id VARCHAR(50),
    label VARCHAR(1),  -- D-流出，C-流入
    f1 VARCHAR(10),    -- 账户类型代码
    f2 DATE,           -- 交易日期
    f3 VARCHAR(10),    -- 交易类型代码
    f4 VARCHAR(100),   -- 交易类型描述
    f5 DECIMAL(15,2),  -- 交易金额
    f6 VARCHAR(10),    -- 交易渠道代码
    f7 VARCHAR(10),    -- 交易币种代码
    f8 VARCHAR(100),   -- 交易机构名称
    f9 INT             -- 冲正类型代码
);

-- 4. 特征工程：从交易数据中提取特征
CREATE VIEW transaction_features AS
SELECT 
    id,
    -- 基础交易统计特征
    COUNT(*) as total_transactions,
    COUNT(CASE WHEN label = 'C' THEN 1 END) as inflow_count,
    COUNT(CASE WHEN label = 'D' THEN 1 END) as outflow_count,
    
    -- 交易金额特征
    SUM(CASE WHEN label = 'C' THEN f5 ELSE 0 END) as total_inflow_amount,
    SUM(CASE WHEN label = 'D' THEN f5 ELSE 0 END) as total_outflow_amount,
    AVG(CASE WHEN label = 'C' THEN f5 END) as avg_inflow_amount,
    AVG(CASE WHEN label = 'D' THEN f5 END) as avg_outflow_amount,
    STDDEV(CASE WHEN label = 'C' THEN f5 END) as inflow_amount_std,
    STDDEV(CASE WHEN label = 'D' THEN f5 END) as outflow_amount_std,
    
    -- 交易频率特征
    COUNT(CASE WHEN f2 >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 1 END) as transactions_last_30_days,
    COUNT(CASE WHEN f2 >= DATE_SUB(CURDATE(), INTERVAL 90 DAY) THEN 1 END) as transactions_last_90_days,
    
    -- 渠道多样性
    COUNT(DISTINCT f6) as channel_diversity,
    
    -- 账户类型特征
    COUNT(CASE WHEN f1 = 'INV' THEN 1 END) as deposit_transactions,
    COUNT(CASE WHEN f1 = 'LON' THEN 1 END) as loan_transactions,
    
    -- 交易时间特征
    MIN(f2) as first_transaction_date,
    MAX(f2) as last_transaction_date,
    DATEDIFF(MAX(f2), MIN(f2)) as transaction_span_days,
    
    -- 冲正率
    COUNT(CASE WHEN f9 = 1 THEN 1 END) * 1.0 / COUNT(*) as reversal_rate,
    
    -- 最近交易活跃度
    COUNT(CASE WHEN f2 >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN 1 END) as transactions_last_7_days,
    
    -- 大额交易特征
    COUNT(CASE WHEN f5 > 100000 THEN 1 END) as large_transaction_count,
    SUM(CASE WHEN f5 > 100000 AND label = 'C' THEN f5 ELSE 0 END) as large_inflow_amount,
    SUM(CASE WHEN f5 > 100000 AND label = 'D' THEN f5 ELSE 0 END) as large_outflow_amount,
    
    -- 交易金额分布特征
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f5) as median_transaction_amount,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY f5) as p95_transaction_amount,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY f5) as p99_transaction_amount
    
FROM market_train
GROUP BY id;

-- 5. 创建增强特征视图
CREATE VIEW enhanced_features AS
SELECT 
    t.*,
    -- 财务比率特征
    CASE WHEN f3 > 0 THEN f2 / f3 ELSE NULL END as asset_liability_ratio,
    CASE WHEN f6 > 0 THEN f5 / f6 ELSE NULL END as profit_margin,
    CASE WHEN f10 > 0 THEN f9 / f10 ELSE NULL END as receivables_ratio,
    CASE WHEN f11 > 0 THEN f10 / f11 ELSE NULL END as current_ratio,
    CASE WHEN f2 > 0 THEN f8 / f2 ELSE NULL END as cash_flow_ratio,
    
    -- 时间特征
    DATEDIFF(CURDATE(), f15) as company_age_days,
    DATEDIFF(CURDATE(), f21) as account_age_days,
    DATEDIFF(CURDATE(), f24) as legal_person_age_days,
    
    -- 企业规模特征
    CASE 
        WHEN f13 < 50 THEN 'small'
        WHEN f13 < 200 THEN 'medium'
        WHEN f13 < 1000 THEN 'large'
        ELSE 'enterprise'
    END as company_size_category,
    
    -- 行业风险等级（基于历史经验）
    CASE f17
        WHEN 'A' THEN 1  -- 农、林、牧、渔业 - 高风险
        WHEN 'B' THEN 2  -- 采矿业 - 高风险
        WHEN 'C' THEN 3  -- 制造业 - 中等风险
        WHEN 'D' THEN 1  -- 电力、燃气及水 - 低风险
        WHEN 'E' THEN 2  -- 建筑业 - 高风险
        WHEN 'F' THEN 3  -- 批发和零售业 - 中等风险
        WHEN 'G' THEN 2  -- 交通运输、仓储和邮政业 - 高风险
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
    CASE f14
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
    CASE f25
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

-- 6. 创建完整的特征集（包含交易特征）
CREATE VIEW full_feature_set AS
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
    COALESCE(tf.channel_diversity, 0) as channel_diversity,
    COALESCE(tf.deposit_transactions, 0) as deposit_transactions,
    COALESCE(tf.loan_transactions, 0) as loan_transactions,
    COALESCE(tf.transaction_span_days, 0) as transaction_span_days,
    COALESCE(tf.reversal_rate, 0) as reversal_rate,
    COALESCE(tf.transactions_last_7_days, 0) as transactions_last_7_days,
    COALESCE(tf.large_transaction_count, 0) as large_transaction_count,
    COALESCE(tf.large_inflow_amount, 0) as large_inflow_amount,
    COALESCE(tf.large_outflow_amount, 0) as large_outflow_amount,
    COALESCE(tf.median_transaction_amount, 0) as median_transaction_amount,
    COALESCE(tf.p95_transaction_amount, 0) as p95_transaction_amount,
    COALESCE(tf.p99_transaction_amount, 0) as p99_transaction_amount,
    
    -- 交易行为特征
    CASE WHEN tf.total_transactions > 0 THEN tf.inflow_count * 1.0 / tf.total_transactions ELSE 0 END as inflow_ratio,
    CASE WHEN tf.total_transactions > 0 THEN tf.outflow_count * 1.0 / tf.total_transactions ELSE 0 END as outflow_ratio,
    CASE WHEN tf.total_outflow_amount > 0 THEN tf.total_inflow_amount / tf.total_outflow_amount ELSE 0 END as inflow_outflow_ratio,
    CASE WHEN tf.transaction_span_days > 0 THEN tf.total_transactions * 1.0 / tf.transaction_span_days ELSE 0 END as daily_transaction_frequency,
    CASE WHEN tf.total_transactions > 0 THEN tf.large_transaction_count * 1.0 / tf.total_transactions ELSE 0 END as large_transaction_ratio

FROM enhanced_features e
LEFT JOIN transaction_features tf ON e.id = tf.id;

-- 7. 创建训练数据集（用于模型训练）
CREATE VIEW training_dataset AS
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
    transactions_last_30_days, transactions_last_90_days, channel_diversity,
    deposit_transactions, loan_transactions, transaction_span_days, reversal_rate,
    transactions_last_7_days, large_transaction_count, large_inflow_amount, large_outflow_amount,
    median_transaction_amount, p95_transaction_amount, p99_transaction_amount,
    inflow_ratio, outflow_ratio, inflow_outflow_ratio, daily_transaction_frequency, large_transaction_ratio
FROM full_feature_set
WHERE label IS NOT NULL;

-- 8. 创建测试数据集（用于预测）
CREATE VIEW test_dataset AS
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
    transactions_last_30_days, transactions_last_90_days, channel_diversity,
    deposit_transactions, loan_transactions, transaction_span_days, reversal_rate,
    transactions_last_7_days, large_transaction_count, large_inflow_amount, large_outflow_amount,
    median_transaction_amount, p95_transaction_amount, p99_transaction_amount,
    inflow_ratio, outflow_ratio, inflow_outflow_ratio, daily_transaction_frequency, large_transaction_ratio
FROM full_feature_set
WHERE label IS NULL;