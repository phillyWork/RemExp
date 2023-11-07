//
//  StatVC.swift
//  RemExp
//
//  Created by Heedon on 2023/05/09.
//

import UIKit
import Firebase
import Charts

//DB에서 user 가져오기, App에서 iterate 하면서 통계 뽑기 (device에서 처리)

final class StatVC: UIViewController {

    //MARK: - Properties
    
    let dataManager = DataManager.shared
    
    private let statChart1: BarChartView = {
        let chart = BarChartView()
        
        chart.chartDescription.enabled = false
        chart.dragEnabled = true
        chart.setScaleEnabled(true)
        chart.pinchZoomEnabled = false
        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        chart.rightAxis.enabled = false
        
        chart.drawBarShadowEnabled = false
        chart.drawValueAboveBarEnabled = false
        
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
       
        let leftAxis = chart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 0
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        
        let rightAxis = chart.rightAxis
        rightAxis.enabled = false
        
        //default data (no data)
        chart.noDataText = "통계 데이터가 없습니다."
        chart.noDataFont = .systemFont(ofSize: 20)
        chart.noDataTextColor = viewTextColor!
        chart.backgroundColor = cellColor
        
        let l = chart.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = UIFont.systemFont(ofSize: 11)
        l.xEntrySpace = 4
        
        return chart
    }()
    
    private let statChart2: LineChartView = {
        let chart = LineChartView()
        
        chart.chartDescription.enabled = false
        chart.dragEnabled = true
        chart.setScaleEnabled(true)
        chart.pinchZoomEnabled = true
            
        let limitLineAxis = ChartLimitLine(limit: 1)
        limitLineAxis.lineWidth = 4
        limitLineAxis.lineDashLengths = [10, 10, 0]
        limitLineAxis.labelPosition = .rightBottom
        limitLineAxis.valueFont = .systemFont(ofSize: 10)
        
        let xAxis = chart.xAxis
//        xAxis.labelPosition = .topInside
//        xAxis.labelFont = UIFont.systemFont(ofSize: 10, weight: .light)
//        xAxis.drawAxisLineEnabled = true
//        xAxis.drawGridLinesEnabled = true
//        xAxis.centerAxisLabelsEnabled = true
        xAxis.gridLineDashLengths = [10, 10]
        xAxis.gridLineDashPhase = 0
        
        let leftAxis = chart.leftAxis
//        leftAxis.drawGridLinesEnabled = true
//        leftAxis.granularityEnabled = true
        leftAxis.axisMaximum = 20
        leftAxis.axisMinimum = 0
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        chart.rightAxis.enabled = false
        
        //default data (no data)
        chart.noDataText = "통계 데이터가 없습니다."
        chart.noDataFont = .systemFont(ofSize: 20)
        chart.noDataTextColor = viewTextColor!
        chart.backgroundColor = cellColor
        
        chart.legend.form = .line
        chart.animate(xAxisDuration: 2.5)
        
        return chart
    }()

    
    //MARK: - Setup UI
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavController()
        
        configureUI()
        
        setupStatData()
    }
    
    private func configureNavController() {
        let backButton = UIBarButtonItem()
        backButton.title = "계정으로"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = viewTextColor
    }
    
    private func configureUI() {
        view.backgroundColor = viewBackgroundColor
        tabBarController?.tabBar.isHidden = true
        
        let scrollView = UIScrollView()
        let contentView = UIStackView(arrangedSubviews: [statChart1, statChart2])
        contentView.axis = .vertical
        contentView.spacing = 20
        contentView.distribution = .fillEqually
        
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        scrollView.addSubview(contentView)
        contentView.anchor(top: scrollView.contentLayoutGuide.topAnchor, left: scrollView.contentLayoutGuide.leftAnchor, bottom: scrollView.contentLayoutGuide.bottomAnchor, right: scrollView.contentLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        //width 동일
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        //heigth 동일, priority 조정해서 scroll될 수 있도록
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    
    //MARK: - API

    //기본 설정
    private func setupStatData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let notUsedData = dataManager.getCurrentNotUsedUserProducts()
        let usedData = dataManager.getConfirmedUserProducts()
        
        var categoryDict: [String: Int] = [:]
        var dayAddedDict: [String: Int] = [:]
        
        let today = Date()
        
        for data in usedData {
            //1. 카테고리별 등록 아이템 개수 (dictionary로 각 카테고리 개수 확인)
            if categoryDict.contains(where: { $0.key == data.product.category }) {
                categoryDict[data.product.category]! += 1
            } else {
                categoryDict[data.product.category] = 1
            }
            //2. 최근 10일간 등록한 아이템 개수 (now ~ now - 10 사이 createdAt 존재 여부로 확인)
            let leftDays = numberOfDaysBetween(data.createdAt, and: today)
            if leftDays <= 10 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd" // 08/13
                let stringDate = dateFormatter.string(from: data.createdAt)
                
                if dayAddedDict.contains(where: { $0.key == stringDate }) {
                    dayAddedDict[stringDate]! += 1
                } else {
                    dayAddedDict[stringDate] = 1
                }
            }
        }
        
        for data in notUsedData {
            //1. 카테고리별 등록 아이템 개수 (dictionary로 각 카테고리 개수 확인)
            if categoryDict.contains(where: { $0.key == data.product.category }) {
                categoryDict[data.product.category]! += 1
            } else {
                categoryDict[data.product.category] = 1
            }
            //2. 최근 10일간 등록한 아이템 개수 (now ~ now - 10 사이 createdAt 존재 여부로 확인)
            let leftDays = numberOfDaysBetween(data.createdAt, and: today)
            if leftDays <= 10 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd" // 08/13
                let stringDate = dateFormatter.string(from: data.createdAt)
                
                if dayAddedDict.contains(where: { $0.key == stringDate }) {
                    dayAddedDict[stringDate]! += 1
                } else {
                    dayAddedDict[stringDate] = 1
                }
            }
        }
        
        let sortedCategoryDict = categoryDict.sorted { $0.key < $1.key }
        
        var categoryKeyData = [String]()
        var categoryCountData = [Double]()
        
        for (key, value) in sortedCategoryDict {
            categoryKeyData.append(key)
            categoryCountData.append(Double(value))
        }
        
        //bar chart
        self.statChart1.xAxis.valueFormatter = IndexAxisValueFormatter(values: categoryKeyData)
        self.statChart1.xAxis.setLabelCount(categoryCountData.count, force: false)
        self.setBarData(barChartView: self.statChart1, barChartDataEntries: self.entryDataForBarChart(values: categoryCountData))
        
        let sortedDayAddedDict = dayAddedDict.sorted { $0.key < $1.key }
        
        var dayKeyData = [String]()
        var dayCountData = [Double]()
        
        for (key, value) in sortedDayAddedDict {
            dayKeyData.append(key)
            dayCountData.append(Double(value))
        }
                
        //line chart
        self.statChart2.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayKeyData)
        self.statChart2.xAxis.setLabelCount(dayCountData.count, force: true)
        self.setLineData(lineChartView: self.statChart2, lineChartDataEntries: self.entryDataForLineChart(values: dayCountData))
    }
    
    private func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = Calendar(identifier: .gregorian) .startOfDay(for: from)
        let toDate = Calendar(identifier: .gregorian).startOfDay(for: to)
        let numberOfDays = Calendar(identifier: .gregorian).dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day!
    }
    
    
    //데이터 셋 설정, bar 차트에 적용
    private func setBarData(barChartView: BarChartView, barChartDataEntries: [BarChartDataEntry]) {
        //데이터 셋 만들기
        let barChartdataSet = BarChartDataSet(entries: barChartDataEntries, label: "카테고리 별 등록 개수")
        barChartdataSet.colors = [material1!, material2!, material3!, material4!, joyful1!, joyful2!, joyful3!, joyful4!, joyful5!, vordiplom1!, vordiplom2!, vordiplom3!, vordiplom4!, vordiplom5!, colorful1!, colorful2!, colorful3!, colorful4!, colorful5!, pastel1!, pastel2!, pastel3!, pastel4!, pastel5!]
        //차트 데이터 만들기
        let barChartData = BarChartData(dataSet: barChartdataSet)
        barChartData.barWidth = 0.9
        //데이터 차트에 적용
        barChartView.data = barChartData
    }
    
    //entry 만들기
    private func entryDataForBarChart(values: [Double]) -> [BarChartDataEntry] {
        //엔트리 생성
        var barDataEntries: [BarChartDataEntry] = []
        //데이터 값만큼
        for i in 0..<values.count {
            let barDataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            barDataEntries.append(barDataEntry)
        }
        return barDataEntries
    }
    
    private func setLineData(lineChartView: LineChartView, lineChartDataEntries: [ChartDataEntry]) {
        //데이터 셋 만들기
        let lineChartdataSet = LineChartDataSet(entries: lineChartDataEntries, label: "최근 10일 간 등록 건수")
//        lineChartdataSet.axisDependency = .left
        lineChartdataSet.lineDashLengths = nil
        lineChartdataSet.highlightLineDashLengths = nil
//        lineChartdataSet.drawIconsEnabled = false
        lineChartdataSet.setCircleColor(brandColor!)
        lineChartdataSet.setColor(brandColor!)
        lineChartdataSet.lineWidth = 3
        lineChartdataSet.drawCircleHoleEnabled = false
        lineChartdataSet.circleRadius = 5
        lineChartdataSet.valueFont = .systemFont(ofSize: 9)
        lineChartdataSet.formLineDashLengths = nil
        lineChartdataSet.formLineWidth = 1
        lineChartdataSet.formSize = 15
        //차트 데이터 만들기
        let lineChartData = LineChartData(dataSet: lineChartdataSet)
        //데이터 적용
        lineChartView.data = lineChartData
    }
    
    private func entryDataForLineChart(values: [Double]) -> [ChartDataEntry] {
        //엔트리 생성
        var lineDataEntries: [ChartDataEntry] = []
        //데이터 값만큼
        for i in 0..<values.count {
            let lineDataEntry = ChartDataEntry(x: Double(i), y: values[i])
            lineDataEntries.append(lineDataEntry)
        }
        return lineDataEntries
    }
    
}
