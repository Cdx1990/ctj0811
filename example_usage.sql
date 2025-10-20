-- 客户逾期风险预测模型使用示例
-- Example Usage of Credit Risk Prediction Model

-- ===========================================
-- 步骤1: 数据准备和表创建
-- ===========================================

-- 创建训练数据表（示例数据）
INSERT INTO risk_train (id, label, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28, f29)
VALUES 
('CUST001', 0, '2023-12-31', 10000000, 5000000, 200000, 1000000, 8000000, 500000, 500000, 1000000, 3000000, 2000000, 'A0100', 100, 'A', '2010-01-01', '202301', 'C', 0, 1, 0, '2023-01-01', 45, 1, '1978-01-01', 6, 500000, 450000, 100000, 300000),
('CUST002', 1, '2023-12-31', 5000000, 4000000, 100000, 200000, 3000000, 200000, -100000, 500000, 1500000, 1200000, 'B0100', 50, 'H', '2015-01-01', '202301', 'F', 1, 0, 1, '2023-01-01', 35, 2, '1988-01-01', 3, 100000, 80000, 50000, 150000),
('CUST003', 0, '2023-12-31', 20000000, 8000000, 500000, 2000000, 15000000, 1000000, 1000000, 2000000, 6000000, 4000000, 'A0100', 200, 'A', '2005-01-01', '202301', 'D', 0, 1, 0, '2023-01-01', 50, 1, '1973-01-01', 7, 1000000, 900000, 200000, 600000);

-- 创建测试数据表（示例数据）
INSERT INTO risk_test (id, label, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28, f29)
VALUES 
('TEST001', NULL, '2023-12-31', 8000000, 6000000, 300000, 500000, 6000000, 400000, 200000, 800000, 2500000, 1800000, 'B0100', 80, 'H', '2012-01-01', '202301', 'C', 1, 0, 0, '2023-01-01', 40, 1, '1983-01-01', 5, 300000, 250000, 80000, 240000),
('TEST002', NULL, '2023-12-31', 15000000, 10000000, 600000, 1200000, 12000000, 800000, 800000, 1500000, 5000000, 3500000, 'A0100', 150, 'A', '2008-01-01', '202301', 'I', 0, 1, 0, '2023-01-01', 48, 2, '1975-01-01', 6, 800000, 700000, 150000, 450000);

-- 创建交易数据表（示例数据）
INSERT INTO market_train (id, label, f1, f2, f3, f4, f5, f6, f7, f8, f9)
VALUES 
('CUST001', 'C', 'INV', '2023-12-01', 'T001', '存款', 100000, '01', 'CNY', '总行', 0),
('CUST001', 'D', 'LON', '2023-12-02', 'T002', '贷款', 50000, '01', 'CNY', '总行', 0),
('CUST001', 'C', 'INV', '2023-12-03', 'T003', '转账', 200000, '10', 'CNY', '总行', 0),
('CUST002', 'C', 'INV', '2023-12-01', 'T001', '存款', 50000, '01', 'CNY', '总行', 0),
('CUST002', 'D', 'LON', '2023-12-02', 'T002', '贷款', 30000, '01', 'CNY', '总行', 1),
('CUST002', 'C', 'INV', '2023-12-03', 'T003', '转账', 80000, '10', 'CNY', '总行', 0),
('CUST003', 'C', 'INV', '2023-12-01', 'T001', '存款', 200000, '01', 'CNY', '总行', 0),
('CUST003', 'D', 'LON', '2023-12-02', 'T002', '贷款', 100000, '01', 'CNY', '总行', 0),
('CUST003', 'C', 'INV', '2023-12-03', 'T003', '转账', 300000, '10', 'CNY', '总行', 0),
('TEST001', 'C', 'INV', '2023-12-01', 'T001', '存款', 80000, '01', 'CNY', '总行', 0),
('TEST001', 'D', 'LON', '2023-12-02', 'T002', '贷款', 40000, '01', 'CNY', '总行', 0),
('TEST001', 'C', 'INV', '2023-12-03', 'T003', '转账', 120000, '10', 'CNY', '总行', 0),
('TEST002', 'C', 'INV', '2023-12-01', 'T001', '存款', 150000, '01', 'CNY', '总行', 0),
('TEST002', 'D', 'LON', '2023-12-02', 'T002', '贷款', 80000, '01', 'CNY', '总行', 0),
('TEST002', 'C', 'INV', '2023-12-03', 'T003', '转账', 200000, '10', 'CNY', '总行', 0);

-- ===========================================
-- 步骤2: 执行完整的模型流程
-- ===========================================

-- 执行特征工程和模型训练
-- 注意：这里需要先执行 complete_credit_risk_model.sql 中的相关部分

-- ===========================================
-- 步骤3: 查看模型结果
-- ===========================================

-- 查看特征重要性
SELECT 
    feature_name,
    correlation,
    abs_correlation,
    importance_rank
FROM model_feature_analysis
ORDER BY importance_rank
LIMIT 10;

-- 查看风险分布
SELECT 
    risk_level,
    customer_count,
    percentage
FROM risk_distribution_analysis
ORDER BY customer_count DESC;

-- 查看最终预测结果
SELECT 
    id,
    predicted_probability,
    risk_rank,
    CASE 
        WHEN predicted_probability >= 0.8 THEN '极高风险'
        WHEN predicted_probability >= 0.6 THEN '高风险'
        WHEN predicted_probability >= 0.4 THEN '中等风险'
        WHEN predicted_probability >= 0.2 THEN '低风险'
        ELSE '极低风险'
    END as risk_level
FROM final_prediction_results
ORDER BY predicted_probability DESC;

-- ===========================================
-- 步骤4: 模型验证和调试
-- ===========================================

-- 查看训练集上的模型表现（如果有真实标签）
SELECT 
    label,
    COUNT(*) as actual_count,
    AVG(predicted_probability) as avg_predicted_prob
FROM training_dataset t
LEFT JOIN test_predictions p ON t.id = p.id
WHERE t.label IS NOT NULL
GROUP BY label;

-- 查看特征分布
SELECT 
    '资产总额' as feature_name,
    MIN(f2) as min_value,
    MAX(f2) as max_value,
    AVG(f2) as avg_value,
    STDDEV(f2) as std_value
FROM training_dataset
UNION ALL
SELECT 
    '负债总额',
    MIN(f3),
    MAX(f3),
    AVG(f3),
    STDDEV(f3)
FROM training_dataset
UNION ALL
SELECT 
    '净利润',
    MIN(f5),
    MAX(f5),
    AVG(f5),
    STDDEV(f5)
FROM training_dataset;

-- ===========================================
-- 步骤5: 业务应用示例
-- ===========================================

-- 高风险客户识别
SELECT 
    id,
    predicted_probability,
    '需要重点关注' as action_required
FROM final_prediction_results
WHERE predicted_probability >= 0.6
ORDER BY predicted_probability DESC;

-- 中等风险客户识别
SELECT 
    id,
    predicted_probability,
    '建议定期监控' as action_required
FROM final_prediction_results
WHERE predicted_probability >= 0.4 AND predicted_probability < 0.6
ORDER BY predicted_probability DESC;

-- 低风险客户识别
SELECT 
    id,
    predicted_probability,
    '正常监控' as action_required
FROM final_prediction_results
WHERE predicted_probability < 0.4
ORDER BY predicted_probability DESC;

-- ===========================================
-- 步骤6: 模型性能监控
-- ===========================================

-- 模型预测分布统计
SELECT 
    COUNT(*) as total_customers,
    AVG(predicted_probability) as avg_risk_score,
    MIN(predicted_probability) as min_risk_score,
    MAX(predicted_probability) as max_risk_score,
    STDDEV(predicted_probability) as risk_score_std
FROM final_prediction_results;

-- 风险等级客户数量统计
SELECT 
    risk_level,
    customer_count,
    ROUND(percentage, 2) as percentage,
    CASE 
        WHEN risk_level = '极高风险' THEN '立即采取行动'
        WHEN risk_level = '高风险' THEN '加强监控'
        WHEN risk_level = '中等风险' THEN '定期检查'
        WHEN risk_level = '低风险' THEN '正常监控'
        ELSE '保持现状'
    END as recommended_action
FROM risk_distribution_analysis
ORDER BY 
    CASE risk_level
        WHEN '极高风险' THEN 1
        WHEN '高风险' THEN 2
        WHEN '中等风险' THEN 3
        WHEN '低风险' THEN 4
        ELSE 5
    END;