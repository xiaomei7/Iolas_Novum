//
//  Statistics.swift
//  Iolas_Novum
//
//  Created by Iolas on 16/07/2023.
//

import SwiftUI
import SwiftUICharts

enum StatsRange: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

struct Statistics: View {
    
    @StateObject var dailyStatModel: DailyStatsViewModel = .init()
    @Environment(\.self) var env
    
    @State private var statsData: [(String, TimeInterval, String)] = []
    @State private var selectedDate: Date = Date().startOfDay
    @State private var chartData: DoughnutChartData = DoughnutChartData(dataSets: PieDataSet(dataPoints: [], legendTitle: ""), metadata: ChartMetadata(title: "", subtitle: ""), chartStyle: DoughnutChartStyle(), noDataText: Text(""))
    
    @State private var statRange: StatsRange = .daily
    
    var body: some View {
        ZStack {
            Color("Cream").opacity(0.7).ignoresSafeArea()
            
            VStack {
                Picker("", selection: $statRange) {
                    ForEach(StatsRange.allCases, id: \.rawValue) { range in
                        Text(range.rawValue)
                            .tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                
                if statRange == .daily {
                    DatePickerView
                } else if statRange == .weekly {
                    WeekPicker
                } else if statRange == .monthly {
                    MonthPicker
                }
                
                DoughnutChart(chartData: chartData)
                    .touchOverlay(chartData: chartData)
                    .headerBox(chartData: chartData)
                    .legends(chartData: chartData, columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())])
                    .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
                    .id(chartData.id)
                    .padding(.horizontal)
                
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            updateData()
        }
        .onChange(of: selectedDate) { _ in
            updateData()
        }
        .onChange(of: statRange) { _ in
            updateData()
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
        let dataPoints: [PieChartDataPoint] = statsData.map { (name, time, color) in
            PieChartDataPoint(value: time.asHours(), description: name, colour: Color(color), label: .label(text: "\(name): \(String(format: "%.2f", time.asHours()))h", rFactor: 0.8))
            
        }
        let dataSet = PieDataSet(dataPoints: dataPoints, legendTitle: "Activities")
        
        chartData = DoughnutChartData(dataSets: dataSet,
                                      metadata: ChartMetadata(title: "Stats", subtitle: "For Activities"),
                                      chartStyle: DoughnutChartStyle(infoBoxPlacement: .header),
                                      noDataText: Text("No Data"))
    }
    
    private var DatePickerView: some View {
        HStack {
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            }) {
                Image(systemName: "arrow.left")
            }
            
            Text(getDateString())
            
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            }) {
                Image(systemName: "arrow.right")
            }
        }
    }
    
    private func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        } else {
            return formatter.string(from: selectedDate)
        }
    }
    
    private var WeekPicker: some View {
        HStack {
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate) ?? selectedDate
            }) {
                Image(systemName: "arrow.left")
            }
            
            Text(getWeekString())
            
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate) ?? selectedDate
            }) {
                Image(systemName: "arrow.right")
            }
        }
    }
    
    private func getWeekString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let startOfWeek = selectedDate.startOfWeek()
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        return "\(formatter.string(from: startOfWeek)) to \(formatter.string(from: endOfWeek))"
    }
    
    private var MonthPicker: some View {
        HStack {
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
            }) {
                Image(systemName: "arrow.left")
            }
            
            Text(getMonthString())
            
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
            }) {
                Image(systemName: "arrow.right")
            }
        }
    }
    
    private func getMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private func updateData() {
        switch statRange {
        case .daily:
            statsData = dailyStatModel.fetchDailyStatsData(for: selectedDate, context: env.managedObjectContext)
        case .weekly:
            statsData = dailyStatModel.fetchWeeklyStatsData(for: selectedDate, context: env.managedObjectContext)
        case .monthly:
            let startOfMonth = selectedDate.startOfMonth()
            let endOfMonth = selectedDate.endOfMonth()
            statsData = dailyStatModel.fetchMonthlyStatsData(from: startOfMonth, to: endOfMonth, context: env.managedObjectContext)
        }
        makeData()
    }
}
