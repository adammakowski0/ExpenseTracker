//
//  TransactionsChartView.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 02/11/2024.
//

import SwiftUI
import Charts

struct TransactionsChartView: View {
    let chartData: [ChartData]
    let color: Color
    
    var body: some View {

            Chart(chartData) { data in
                BarMark(
                    x: .value("Month", data.date, unit: .month),
                    y: .value("Amount", data.value)
                )
                .foregroundStyle(color.gradient)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { date in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .padding()
            .aspectRatio(1.8, contentMode: .fit)
            .padding()
    }
}

#Preview {
    TransactionsChartView(chartData: [
        ChartData(value: 400, date: Date.from(year: 2024, month: 2, day: 2)),
    
 
        ChartData(value: 10, date: Date.from(year: 2024, month: 4, day: 2)),
    ], color: .blue)
}
