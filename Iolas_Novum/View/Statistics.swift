//
//  Statistics.swift
//  Iolas_Novum
//
//  Created by Iolas on 16/07/2023.
//

import SwiftUI
import SwiftUICharts

struct Statistics: View {
    
    @StateObject var dailyStatModel: DailyActivityStatsViewModel = .init()
    @Environment(\.self) var env
    
    @State private var dailyStatsData: [(String, TimeInterval, String)] = []
    @State private var selectedDate: Date = Date().startOfDay
    @State private var chartData: DoughnutChartData = DoughnutChartData(dataSets: PieDataSet(dataPoints: [], legendTitle: ""), metadata: ChartMetadata(title: "", subtitle: ""), chartStyle: DoughnutChartStyle(), noDataText: Text(""))
    
    
    var body: some View {
        VStack {
            DoughnutChart(chartData: chartData)
                .touchOverlay(chartData: chartData)
                .headerBox(chartData: chartData)
                .legends(chartData: chartData, columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())])
                .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
                .id(chartData.id)
                .padding(.horizontal)
        }
        .padding()
        .onAppear {
            dailyStatsData = dailyStatModel.fetchDailyStatsData(for: selectedDate, context: env.managedObjectContext)
            makeData()
        }
    }
}

struct Statistics_Previews: PreviewProvider {
    static var previews: some View {
        Statistics()
    }
}

extension Statistics {
    private func makeData() {
        let dataPoints: [PieChartDataPoint] = dailyStatsData.map { (name, time, color) in
            PieChartDataPoint(value: time.asHours(), description: name, colour: Color(color), label: .label(text: "\(name): \(String(format: "%.2f", time.asHours()))h", rFactor: 0.8))
            
        }
        let dataSet = PieDataSet(dataPoints: dataPoints, legendTitle: "Activities")
        
        chartData = DoughnutChartData(dataSets: dataSet,
                                      metadata: ChartMetadata(title: "Daily Stats", subtitle: "For Activities"),
                                      chartStyle: DoughnutChartStyle(infoBoxPlacement: .header),
                                      noDataText: Text("No Data"))
    }
}
