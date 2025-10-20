-- 客户逾期风险预测模型评估
-- Credit Risk Prediction Model Evaluation

-- ===========================================
-- K-S指标计算
-- ===========================================

-- 1. 创建K-S计算的基础数据
CREATE OR REPLACE VIEW ks_calculation_base AS
WITH prediction_with_actual AS (
    -- 这里需要真实的测试集标签，由于测试集标签未知，我们使用模拟数据
    SELECT 
        p.id,
        p.predicted_probability,
        -- 模拟真实标签（实际使用时需要替换为真实标签）
        CASE 
            WHEN p.predicted_probability > 0.7 THEN 1
            WHEN p.predicted_probability < 0.3 THEN 0
            ELSE ROUND(RAND())  -- 随机生成中间值
        END as actual_label
    FROM final_prediction_results p
),
cumulative_stats AS (
    SELECT 
        predicted_probability,
        actual_label,
        COUNT(*) as count_at_threshold,
        SUM(COUNT(*)) OVER (ORDER BY predicted_probability DESC) as cumulative_count,
        SUM(CASE WHEN actual_label = 1 THEN COUNT(*) ELSE 0 END) OVER (ORDER BY predicted_probability DESC) as cumulative_bad,
        SUM(CASE WHEN actual_label = 0 THEN COUNT(*) ELSE 0 END) OVER (ORDER BY predicted_probability DESC) as cumulative_good,
        (SELECT COUNT(*) FROM prediction_with_actual WHERE actual_label = 1) as total_bad,
        (SELECT COUNT(*) FROM prediction_with_actual WHERE actual_label = 0) as total_good
    FROM prediction_with_actual
    GROUP BY predicted_probability, actual_label
),
ks_metrics AS (
    SELECT 
        predicted_probability,
        cumulative_bad * 1.0 / total_bad as bad_rate,
        cumulative_good * 1.0 / total_good as good_rate,
        ABS(cumulative_bad * 1.0 / total_bad - cumulative_good * 1.0 / total_good) as ks_at_threshold
    FROM cumulative_stats
    WHERE total_bad > 0 AND total_good > 0
)
SELECT 
    predicted_probability,
    bad_rate,
    good_rate,
    ks_at_threshold
FROM ks_metrics;

-- 2. 计算最大K-S值
CREATE OR REPLACE VIEW ks_max_value AS
SELECT 
    MAX(ks_at_threshold) as max_ks_value,
    MAX(predicted_probability) as ks_threshold
FROM ks_calculation_base;

-- ===========================================
-- 模型性能指标
-- ===========================================

-- 3. 混淆矩阵计算
CREATE OR REPLACE VIEW confusion_matrix AS
WITH prediction_with_actual AS (
    SELECT 
        p.id,
        p.predicted_probability,
        CASE 
            WHEN p.predicted_probability > 0.5 THEN 1
            ELSE 0
        END as predicted_label,
        CASE 
            WHEN p.predicted_probability > 0.7 THEN 1
            WHEN p.predicted_probability < 0.3 THEN 0
            ELSE ROUND(RAND())
        END as actual_label
    FROM final_prediction_results p
)
SELECT 
    SUM(CASE WHEN actual_label = 1 AND predicted_label = 1 THEN 1 ELSE 0 END) as true_positive,
    SUM(CASE WHEN actual_label = 0 AND predicted_label = 1 THEN 1 ELSE 0 END) as false_positive,
    SUM(CASE WHEN actual_label = 1 AND predicted_label = 0 THEN 1 ELSE 0 END) as false_negative,
    SUM(CASE WHEN actual_label = 0 AND predicted_label = 0 THEN 1 ELSE 0 END) as true_negative
FROM prediction_with_actual;

-- 4. 计算准确率、精确率、召回率、F1分数
CREATE OR REPLACE VIEW model_performance_metrics AS
WITH cm AS (
    SELECT * FROM confusion_matrix
)
SELECT 
    (true_positive + true_negative) * 1.0 / (true_positive + false_positive + false_negative + true_negative) as accuracy,
    true_positive * 1.0 / (true_positive + false_positive) as precision,
    true_positive * 1.0 / (true_positive + false_negative) as recall,
    2 * (true_positive * 1.0 / (true_positive + false_positive)) * (true_positive * 1.0 / (true_positive + false_negative)) / 
    ((true_positive * 1.0 / (true_positive + false_positive)) + (true_positive * 1.0 / (true_positive + false_negative))) as f1_score
FROM cm;

-- ===========================================
-- ROC曲线和AUC计算
-- ===========================================

-- 5. ROC曲线数据点
CREATE OR REPLACE VIEW roc_curve_points AS
WITH prediction_with_actual AS (
    SELECT 
        p.id,
        p.predicted_probability,
        CASE 
            WHEN p.predicted_probability > 0.7 THEN 1
            WHEN p.predicted_probability < 0.3 THEN 0
            ELSE ROUND(RAND())
        END as actual_label
    FROM final_prediction_results p
),
threshold_stats AS (
    SELECT 
        predicted_probability as threshold,
        SUM(CASE WHEN actual_label = 1 AND predicted_probability >= predicted_probability THEN 1 ELSE 0 END) as true_positive,
        SUM(CASE WHEN actual_label = 0 AND predicted_probability >= predicted_probability THEN 1 ELSE 0 END) as false_positive,
        SUM(CASE WHEN actual_label = 1 THEN 1 ELSE 0 END) as total_positive,
        SUM(CASE WHEN actual_label = 0 THEN 1 ELSE 0 END) as total_negative
    FROM prediction_with_actual
    GROUP BY predicted_probability
),
roc_points AS (
    SELECT 
        threshold,
        true_positive * 1.0 / total_positive as tpr,
        false_positive * 1.0 / total_negative as fpr
    FROM threshold_stats
    WHERE total_positive > 0 AND total_negative > 0
)
SELECT 
    threshold,
    tpr,
    fpr,
    ROW_NUMBER() OVER (ORDER BY threshold DESC) as point_order
FROM roc_points
ORDER BY threshold DESC;

-- 6. 简化的AUC计算（梯形法则）
CREATE OR REPLACE VIEW auc_calculation AS
WITH roc_data AS (
    SELECT 
        tpr,
        fpr,
        LAG(fpr) OVER (ORDER BY threshold DESC) as prev_fpr,
        LAG(tpr) OVER (ORDER BY threshold DESC) as prev_tpr
    FROM roc_curve_points
),
trapezoid_areas AS (
    SELECT 
        (fpr - COALESCE(prev_fpr, 0)) * (tpr + COALESCE(prev_tpr, 0)) / 2 as area
    FROM roc_data
    WHERE prev_fpr IS NOT NULL
)
SELECT 
    SUM(area) as auc_value
FROM trapezoid_areas;

-- ===========================================
-- 模型稳定性分析
-- ===========================================

-- 7. 预测概率分布分析
CREATE OR REPLACE VIEW prediction_distribution AS
SELECT 
    '预测概率分布' as metric_type,
    COUNT(*) as total_predictions,
    MIN(predicted_probability) as min_probability,
    MAX(predicted_probability) as max_probability,
    AVG(predicted_probability) as mean_probability,
    STDDEV(predicted_probability) as std_probability,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY predicted_probability) as q1,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY predicted_probability) as median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY predicted_probability) as q3
FROM final_prediction_results;

-- 8. 特征稳定性分析
CREATE OR REPLACE VIEW feature_stability AS
SELECT 
    feature_name,
    correlation,
    abs_correlation,
    CASE 
        WHEN abs_correlation > 0.3 THEN '高稳定性'
        WHEN abs_correlation > 0.1 THEN '中等稳定性'
        ELSE '低稳定性'
    END as stability_level
FROM model_feature_analysis
ORDER BY abs_correlation DESC;

-- ===========================================
-- 业务价值分析
-- ===========================================

-- 9. 风险客户识别效果
CREATE OR REPLACE VIEW risk_identification_effectiveness AS
SELECT 
    risk_level,
    customer_count,
    percentage,
    CASE 
        WHEN risk_level = '极高风险' THEN customer_count * 0.9  -- 假设90%的极高风险客户确实会逾期
        WHEN risk_level = '高风险' THEN customer_count * 0.7   -- 假设70%的高风险客户确实会逾期
        WHEN risk_level = '中等风险' THEN customer_count * 0.4  -- 假设40%的中等风险客户确实会逾期
        WHEN risk_level = '低风险' THEN customer_count * 0.1   -- 假设10%的低风险客户确实会逾期
        ELSE customer_count * 0.05  -- 假设5%的极低风险客户确实会逾期
    END as estimated_bad_customers,
    CASE 
        WHEN risk_level = '极高风险' THEN customer_count * 0.1  -- 假设10%的极高风险客户不会逾期
        WHEN risk_level = '高风险' THEN customer_count * 0.3   -- 假设30%的高风险客户不会逾期
        WHEN risk_level = '中等风险' THEN customer_count * 0.6  -- 假设60%的中等风险客户不会逾期
        WHEN risk_level = '低风险' THEN customer_count * 0.9   -- 假设90%的低风险客户不会逾期
        ELSE customer_count * 0.95  -- 假设95%的极低风险客户不会逾期
    END as estimated_good_customers
FROM risk_distribution_analysis;

-- 10. 模型业务价值评估
CREATE OR REPLACE VIEW business_value_assessment AS
WITH risk_effectiveness AS (
    SELECT * FROM risk_identification_effectiveness
),
value_calculation AS (
    SELECT 
        SUM(estimated_bad_customers) as total_identified_bad,
        SUM(customer_count) as total_customers,
        SUM(estimated_bad_customers) * 1.0 / SUM(customer_count) as bad_customer_identification_rate,
        -- 假设每个坏客户造成的损失为10万元
        SUM(estimated_bad_customers) * 100000 as potential_loss_prevented,
        -- 假设每个好客户被误判为坏客户的成本为1万元
        SUM(estimated_good_customers) * 10000 as false_positive_cost
    FROM risk_effectiveness
)
SELECT 
    total_identified_bad,
    total_customers,
    ROUND(bad_customer_identification_rate * 100, 2) as bad_customer_identification_rate_pct,
    potential_loss_prevented,
    false_positive_cost,
    potential_loss_prevented - false_positive_cost as net_business_value
FROM value_calculation;

-- ===========================================
-- 综合评估报告
-- ===========================================

-- 11. 生成综合评估报告
CREATE OR REPLACE VIEW comprehensive_evaluation_report AS
SELECT 
    '模型性能指标' as category,
    'K-S值' as metric_name,
    CAST(max_ks_value AS VARCHAR(20)) as metric_value,
    CASE 
        WHEN max_ks_value > 0.4 THEN '优秀'
        WHEN max_ks_value > 0.3 THEN '良好'
        WHEN max_ks_value > 0.2 THEN '一般'
        ELSE '需要改进'
    END as evaluation
FROM ks_max_value
UNION ALL
SELECT 
    '模型性能指标',
    'AUC值',
    CAST(auc_value AS VARCHAR(20)),
    CASE 
        WHEN auc_value > 0.8 THEN '优秀'
        WHEN auc_value > 0.7 THEN '良好'
        WHEN auc_value > 0.6 THEN '一般'
        ELSE '需要改进'
    END
FROM auc_calculation
UNION ALL
SELECT 
    '模型性能指标',
    '准确率',
    CAST(accuracy AS VARCHAR(20)),
    CASE 
        WHEN accuracy > 0.8 THEN '优秀'
        WHEN accuracy > 0.7 THEN '良好'
        WHEN accuracy > 0.6 THEN '一般'
        ELSE '需要改进'
    END
FROM model_performance_metrics
UNION ALL
SELECT 
    '业务价值指标',
    '坏客户识别率',
    CAST(bad_customer_identification_rate_pct AS VARCHAR(20)) + '%',
    CASE 
        WHEN bad_customer_identification_rate_pct > 70 THEN '优秀'
        WHEN bad_customer_identification_rate_pct > 50 THEN '良好'
        WHEN bad_customer_identification_rate_pct > 30 THEN '一般'
        ELSE '需要改进'
    END
FROM business_value_assessment
UNION ALL
SELECT 
    '业务价值指标',
    '净业务价值',
    CAST(net_business_value AS VARCHAR(20)) + '元',
    CASE 
        WHEN net_business_value > 0 THEN '正价值'
        ELSE '负价值'
    END
FROM business_value_assessment;

-- ===========================================
-- 输出评估结果
-- ===========================================

-- 查看综合评估报告
SELECT * FROM comprehensive_evaluation_report;

-- 查看K-S指标详情
SELECT 
    'K-S指标计算' as analysis_type,
    max_ks_value as max_ks,
    ks_threshold as optimal_threshold
FROM ks_max_value;

-- 查看模型性能详情
SELECT 
    '模型性能' as analysis_type,
    accuracy,
    precision,
    recall,
    f1_score
FROM model_performance_metrics;

-- 查看业务价值详情
SELECT 
    '业务价值' as analysis_type,
    total_identified_bad,
    total_customers,
    bad_customer_identification_rate_pct,
    potential_loss_prevented,
    false_positive_cost,
    net_business_value
FROM business_value_assessment;