# 客户逾期风险预测模型
## Credit Risk Prediction Model

### 项目概述
本项目基于SQL语言构建了一个客户逾期风险预测模型，用于预测公司贷款客户在未来3个月内出现5天及以上逾期的概率。模型结合了客户基础信息、财务数据和交易行为等多维度特征，实现了从"事后处置"向"事前预警、事中干预"的转变。

### 数据说明

#### 1. 训练样本集 (risk_train)
- **数据量**: 8万名公司贷款客户
- **特征数**: 29项客户特征变量
- **目标变量**: label (1-坏客户，0-好客户)

#### 2. 测试样本集 (risk_test)
- **数据量**: 2万名客户
- **特征数**: 29项客户特征变量（与训练集相同）
- **目标变量**: 空值（需要预测）

#### 3. 交易数据 (market_train)
- **数据范围**: 训练集和测试集中所有客户的历史交易数据
- **用途**: 衍生交易类特征变量，提升模型效果

### 模型架构

#### 特征工程
1. **财务比率特征**
   - 资产负债率 (asset_liability_ratio)
   - 利润率 (profit_margin)
   - 应收账款比率 (receivables_ratio)
   - 流动比率 (current_ratio)
   - 现金流量比率 (cash_flow_ratio)

2. **时间特征**
   - 公司成立天数 (company_age_days)
   - 账户开户天数 (account_age_days)
   - 法人年龄天数 (legal_person_age_days)

3. **风险等级特征**
   - 行业风险等级 (industry_risk_level)
   - 企业性质风险等级 (company_type_risk_level)
   - 学历风险等级 (education_risk_level)

4. **交易行为特征**
   - 交易频率和金额统计
   - 渠道多样性
   - 冲正率
   - 大额交易特征
   - 交易时间分布

#### 模型算法
- **算法**: 逻辑回归 (Logistic Regression)
- **实现方式**: SQL语言实现
- **特征标准化**: Z-score标准化
- **权重计算**: 基于特征与目标变量的相关性

### 文件结构

```
├── credit_risk_model.sql          # 基础数据表结构和特征工程
├── credit_risk_prediction_model.sql  # 逻辑回归模型实现
├── complete_credit_risk_model.sql    # 完整的端到端模型
└── README.md                      # 项目说明文档
```

### 使用方法

#### 1. 数据准备
```sql
-- 创建基础数据表
-- 执行 credit_risk_model.sql 中的表创建语句
```

#### 2. 特征工程
```sql
-- 执行特征提取和增强
-- 运行 complete_credit_risk_model.sql 中的特征工程部分
```

#### 3. 模型训练和预测
```sql
-- 执行模型训练和预测
-- 运行 complete_credit_risk_model.sql 中的模型部分
```

#### 4. 获取预测结果
```sql
-- 查看最终预测结果
SELECT id, predicted_probability 
FROM final_prediction_results 
ORDER BY predicted_probability DESC;
```

### 模型评估

#### 特征重要性分析
```sql
-- 查看特征重要性排序
SELECT feature_name, correlation, importance_rank
FROM model_feature_analysis
ORDER BY importance_rank;
```

#### 风险分布分析
```sql
-- 查看风险等级分布
SELECT risk_level, customer_count, percentage
FROM risk_distribution_analysis
ORDER BY customer_count DESC;
```

### 关键特征说明

#### 高重要性特征
1. **资产负债率** - 反映企业偿债能力
2. **行业风险等级** - 不同行业具有不同的风险特征
3. **企业性质风险等级** - 国有企业风险相对较低
4. **交易冲正率** - 反映交易质量
5. **现金流状况** - 直接影响还款能力

#### 风险等级划分
- **极高风险**: 预测概率 ≥ 0.8
- **高风险**: 预测概率 ≥ 0.6
- **中等风险**: 预测概率 ≥ 0.4
- **低风险**: 预测概率 ≥ 0.2
- **极低风险**: 预测概率 < 0.2

### 模型优势

1. **多维度特征**: 结合基础信息、财务数据和交易行为
2. **实时预测**: 基于SQL实现，支持实时计算
3. **可解释性**: 特征重要性清晰，便于业务理解
4. **可扩展性**: 易于添加新特征和调整模型参数
5. **业务友好**: 输出概率值，便于业务决策

### 注意事项

1. **数据质量**: 确保输入数据的完整性和准确性
2. **特征标准化**: 模型使用Z-score标准化，需要保持一致性
3. **模型更新**: 建议定期使用新数据重新训练模型
4. **阈值调整**: 可根据业务需求调整风险等级阈值

### 技术实现

- **数据库**: 支持MySQL、PostgreSQL等主流数据库
- **语言**: 纯SQL实现，无需额外依赖
- **算法**: 逻辑回归，适合二分类问题
- **特征工程**: 基于业务理解的规则式特征构建

### 联系方式

如有问题或建议，请联系项目团队。