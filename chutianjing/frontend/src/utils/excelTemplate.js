import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

// Excel模板生成器
export class DataQualityExcelTemplate {
  constructor() {
    this.workbook = XLSX.utils.book_new()
  }

  // 生成完整的Excel报告
  generateFullReport(data) {
    // 1. 概览工作表
    this.createOverviewSheet(data)
    
    // 2. 详细数据工作表
    this.createDetailSheet(data)
    
    // 3. 质量维度分析工作表
    this.createDimensionAnalysisSheet(data)
    
    // 4. 问题分析工作表
    this.createIssueAnalysisSheet(data)
    
    // 5. 趋势分析工作表
    this.createTrendAnalysisSheet(data)
    
    // 6. 建议改进工作表
    this.createRecommendationSheet(data)

    return this.workbook
  }

  // 创建概览工作表
  createOverviewSheet(data) {
    const overviewData = [
      ['数据资产质量分析报告'],
      [''],
      ['报告生成时间', new Date().toLocaleString('zh-CN')],
      ['数据统计周期', '本月'],
      [''],
      ['关键指标概览'],
      ['指标名称', '当前值', '上期值', '变化幅度', '状态'],
      ['整体质量评分', `${data.overallScore}%`, '85.2%', '+2.3%', '优秀'],
      ['数据总量', data.dataVolume, '2.1TB', '+5.2%', '良好'],
      ['质量问题数', data.issuesCount, '178', '-12.5%', '改善'],
      ['合规率', `${data.complianceRate}%`, '92.4%', '+1.8%', '优秀'],
      [''],
      ['质量等级分布'],
      ['等级', '数量', '占比'],
      ['优秀 (90%+)', '15', '37.5%'],
      ['良好 (80-90%)', '18', '45.0%'],
      ['一般 (70-80%)', '5', '12.5%'],
      ['较差 (<70%)', '2', '5.0%'],
      [''],
      ['数据源质量排名'],
      ['排名', '数据源', '质量评分', '主要问题'],
      ['1', '监管报送数据', '97%', '无'],
      ['2', '风险评级数据', '95%', '少量格式错误'],
      ['3', '客户基础信息', '92%', '部分数据缺失'],
      ['4', '财务核算数据', '90%', '计算精度问题'],
      ['5', '交易流水数据', '88%', '重复数据较多']
    ]

    const ws = XLSX.utils.aoa_to_sheet(overviewData)
    
    // 设置样式
    this.applyOverviewStyles(ws)
    
    // 设置列宽
    ws['!cols'] = [
      { wch: 20 }, // 第一列
      { wch: 15 }, // 第二列
      { wch: 15 }, // 第三列
      { wch: 15 }, // 第四列
      { wch: 15 }  // 第五列
    ]

    XLSX.utils.book_append_sheet(this.workbook, ws, '概览')
  }

  // 创建详细数据工作表
  createDetailSheet(data) {
    const detailData = [
      ['数据资产详细质量报告'],
      [''],
      ['数据资产', '质量评分', '完整性', '准确性', '一致性', '及时性', '有效性', '问题数', '状态', '最后更新']
    ]

    // 添加数据行
    data.tableData.forEach(item => {
      detailData.push([
        item.name,
        `${item.score}%`,
        `${item.completeness}%`,
        `${item.accuracy}%`,
        `${item.consistency}%`,
        `${item.timeliness}%`,
        `${item.validity || 88}%`,
        item.issues,
        item.status,
        new Date().toLocaleDateString('zh-CN')
      ])
    })

    const ws = XLSX.utils.aoa_to_sheet(detailData)
    
    // 设置列宽
    ws['!cols'] = [
      { wch: 25 }, // 数据资产
      { wch: 12 }, // 质量评分
      { wch: 12 }, // 完整性
      { wch: 12 }, // 准确性
      { wch: 12 }, // 一致性
      { wch: 12 }, // 及时性
      { wch: 12 }, // 有效性
      { wch: 10 }, // 问题数
      { wch: 10 }, // 状态
      { wch: 15 }  // 最后更新
    ]

    XLSX.utils.book_append_sheet(this.workbook, ws, '详细数据')
  }

  // 创建质量维度分析工作表
  createDimensionAnalysisSheet(data) {
    const dimensionData = [
      ['质量维度分析报告'],
      [''],
      ['维度', '平均得分', '最高得分', '最低得分', '标准差', '改进建议'],
      ['完整性', '91.2%', '99%', '75%', '6.8%', '加强数据采集流程'],
      ['准确性', '86.8%', '96%', '70%', '8.2%', '优化数据验证规则'],
      ['一致性', '89.5%', '98%', '80%', '5.9%', '统一数据标准'],
      ['及时性', '82.3%', '94%', '65%', '9.1%', '提升数据处理效率'],
      ['有效性', '88.1%', '95%', '78%', '5.7%', '完善业务规则'],
      [''],
      ['维度权重配置'],
      ['维度', '权重', '说明'],
      ['完整性', '25%', '数据完整程度'],
      ['准确性', '30%', '数据准确程度'],
      ['一致性', '20%', '数据一致程度'],
      ['及时性', '15%', '数据及时程度'],
      ['有效性', '10%', '数据有效程度']
    ]

    const ws = XLSX.utils.aoa_to_sheet(dimensionData)
    
    // 设置列宽
    ws['!cols'] = [
      { wch: 15 }, // 维度
      { wch: 12 }, // 平均得分
      { wch: 12 }, // 最高得分
      { wch: 12 }, // 最低得分
      { wch: 12 }, // 标准差
      { wch: 30 }  // 改进建议
    ]

    XLSX.utils.book_append_sheet(this.workbook, ws, '维度分析')
  }

  // 创建问题分析工作表
  createIssueAnalysisSheet(data) {
    const issueData = [
      ['质量问题分析报告'],
      [''],
      ['问题类型', '数量', '占比', '影响程度', '主要数据源', '解决方案'],
      ['数据缺失', '55', '35.3%', '高', '客户基础信息', '完善数据采集流程'],
      ['格式错误', '39', '25.0%', '中', '交易流水数据', '优化数据格式验证'],
      ['重复数据', '31', '19.9%', '中', '交易流水数据', '实施去重机制'],
      ['过期数据', '23', '14.7%', '低', '产品配置信息', '建立数据更新机制'],
      ['逻辑错误', '8', '5.1%', '高', '财务核算数据', '加强业务规则验证'],
      [''],
      ['问题趋势分析'],
      ['月份', '问题总数', '新增问题', '解决问题', '净变化'],
      ['1月', '180', '25', '20', '+5'],
      ['2月', '175', '22', '18', '+4'],
      ['3月', '170', '20', '15', '+5'],
      ['4月', '165', '18', '12', '+6'],
      ['5月', '160', '15', '10', '+5'],
      ['6月', '156', '12', '8', '+4']
    ]

    const ws = XLSX.utils.aoa_to_sheet(issueData)
    
    // 设置列宽
    ws['!cols'] = [
      { wch: 15 }, // 问题类型
      { wch: 10 }, // 数量
      { wch: 12 }, // 占比
      { wch: 12 }, // 影响程度
      { wch: 20 }, // 主要数据源
      { wch: 25 }  // 解决方案
    ]

    XLSX.utils.book_append_sheet(this.workbook, ws, '问题分析')
  }

  // 创建趋势分析工作表
  createTrendAnalysisSheet(data) {
    const trendData = [
      ['质量趋势分析报告'],
      [''],
      ['月份', '整体质量评分', '完整性', '准确性', '一致性', '及时性', '有效性'],
      ['1月', '82.0%', '88%', '83%', '86%', '78%', '85%'],
      ['2月', '84.0%', '89%', '84%', '87%', '80%', '86%'],
      ['3月', '86.0%', '90%', '85%', '88%', '82%', '87%'],
      ['4月', '85.0%', '91%', '86%', '89%', '81%', '88%'],
      ['5月', '87.0%', '92%', '87%', '90%', '83%', '89%'],
      ['6月', '87.5%', '92%', '87%', '89%', '82%', '88%'],
      [''],
      ['预测分析'],
      ['预测月份', '预测质量评分', '置信区间', '影响因素'],
      ['7月', '88.2%', '87.0%-89.4%', '数据治理项目启动'],
      ['8月', '89.1%', '88.0%-90.2%', '自动化质量检测上线'],
      ['9月', '90.0%', '89.0%-91.0%', '数据标准统一完成']
    ]

    const ws = XLSX.utils.aoa_to_sheet(trendData)
    
    // 设置列宽
    ws['!cols'] = [
      { wch: 12 }, // 月份
      { wch: 15 }, // 整体质量评分
      { wch: 12 }, // 完整性
      { wch: 12 }, // 准确性
      { wch: 12 }, // 一致性
      { wch: 12 }, // 及时性
      { wch: 12 }  // 有效性
    ]

    XLSX.utils.book_append_sheet(this.workbook, ws, '趋势分析')
  }

  // 创建建议改进工作表
  createRecommendationSheet(data) {
    const recommendationData = [
      ['数据质量改进建议'],
      [''],
      ['优先级', '改进项目', '预期效果', '实施周期', '所需资源', '负责人', '状态'],
      ['高', '建立数据质量监控平台', '提升质量评分5%', '3个月', '技术团队', '张经理', '规划中'],
      ['高', '完善数据采集流程', '减少数据缺失30%', '2个月', '业务团队', '李主管', '进行中'],
      ['中', '优化数据验证规则', '提升准确性8%', '1个月', '技术团队', '王工程师', '待启动'],
      ['中', '实施数据去重机制', '减少重复数据50%', '2个月', '技术团队', '陈工程师', '规划中'],
      ['低', '建立数据更新机制', '提升及时性10%', '1个月', '运维团队', '刘工程师', '待启动'],
      [''],
      ['改进效果评估'],
      ['改进项目', '实施前', '实施后', '改善幅度', '投资回报率'],
      ['数据质量监控平台', '85%', '90%', '+5%', '200%'],
      ['数据采集流程优化', '88%', '92%', '+4%', '150%'],
      ['数据验证规则优化', '86%', '89%', '+3%', '120%'],
      [''],
      ['风险控制措施'],
      ['风险类型', '风险描述', '影响程度', '控制措施', '责任人'],
      ['数据丢失', '系统故障导致数据丢失', '高', '建立备份机制', '运维团队'],
      ['数据泄露', '敏感数据泄露', '高', '加强权限控制', '安全团队'],
      ['性能下降', '质量检测影响系统性能', '中', '优化检测算法', '技术团队']
    ]

    const ws = XLSX.utils.aoa_to_sheet(recommendationData)
    
    // 设置列宽
    ws['!cols'] = [
      { wch: 10 }, // 优先级
      { wch: 25 }, // 改进项目
      { wch: 20 }, // 预期效果
      { wch: 12 }, // 实施周期
      { wch: 15 }, // 所需资源
      { wch: 12 }, // 负责人
      { wch: 10 }  // 状态
    ]

    XLSX.utils.book_append_sheet(this.workbook, ws, '改进建议')
  }

  // 应用概览工作表样式
  applyOverviewStyles(ws) {
    // 这里可以添加单元格样式设置
    // 由于XLSX库的限制，样式设置需要通过其他方式实现
  }

  // 导出Excel文件
  exportToFile(filename = null) {
    if (!filename) {
      const now = new Date()
      filename = `数据资产质量分析报告_${now.getFullYear()}${(now.getMonth()+1).toString().padStart(2,'0')}${now.getDate().toString().padStart(2,'0')}.xlsx`
    }

    const wbout = XLSX.write(this.workbook, { bookType: 'xlsx', type: 'array' })
    const blob = new Blob([wbout], { type: 'application/octet-stream' })
    saveAs(blob, filename)
  }
}

// 使用示例
export const generateDataQualityReport = (data) => {
  const template = new DataQualityExcelTemplate()
  template.generateFullReport(data)
  template.exportToFile()
}

// 生成简化版报告
export const generateSimpleReport = (data) => {
  const workbook = XLSX.utils.book_new()
  
  // 创建简化的工作表
  const simpleData = [
    ['数据资产质量分析报告'],
    [''],
    ['数据资产', '质量评分', '完整性', '准确性', '一致性', '及时性', '问题数', '状态'],
    ...data.tableData.map(item => [
      item.name,
      `${item.score}%`,
      `${item.completeness}%`,
      `${item.accuracy}%`,
      `${item.consistency}%`,
      `${item.timeliness}%`,
      item.issues,
      item.status
    ])
  ]

  const ws = XLSX.utils.aoa_to_sheet(simpleData)
  
  // 设置列宽
  ws['!cols'] = [
    { wch: 25 }, // 数据资产
    { wch: 12 }, // 质量评分
    { wch: 12 }, // 完整性
    { wch: 12 }, // 准确性
    { wch: 12 }, // 一致性
    { wch: 12 }, // 及时性
    { wch: 10 }, // 问题数
    { wch: 10 }  // 状态
  ]

  XLSX.utils.book_append_sheet(workbook, ws, '数据质量报告')

  // 导出文件
  const now = new Date()
  const filename = `数据质量报告_${now.getFullYear()}${(now.getMonth()+1).toString().padStart(2,'0')}${now.getDate().toString().padStart(2,'0')}.xlsx`
  
  const wbout = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' })
  const blob = new Blob([wbout], { type: 'application/octet-stream' })
  saveAs(blob, filename)
}