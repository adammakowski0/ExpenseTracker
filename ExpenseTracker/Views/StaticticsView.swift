//
//  StaticticsView.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 01/11/2024.
//

import SwiftUI
import Charts

struct StaticticsView: View {
    
    @EnvironmentObject var vm: HomeViewModel
    
    var body: some View {
        
        VStack{
            Text("")
        }
        
        Chart {
            ForEach(vm.transactionsList) { transaction in
                BarMark(
                    x: .value("Month", transaction.date, unit: .month),
                    y: .value("Amount", transaction.amount))
                .foregroundStyle(.blue.gradient)
                .cornerRadius(4)
            }
        }
        .chartXScale(domain: Calendar.current.date(byAdding: .month, value: -11, to: Date())!...Calendar.current.date(byAdding: .month, value: 2, to: Date())!)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisValueLabel(format: .dateTime.month())
            }
        }
        .frame(height: 160)
        .padding()
    }
}

#Preview {
    StaticticsView()
        .environmentObject(HomeViewModel())
}
