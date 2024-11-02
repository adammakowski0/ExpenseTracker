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
        ScrollView {
            VStack {
                VStack {
                    chartHeader(title: "Incomes", symbol: "arrow.up.circle", value: vm.totalIncomes)
                    TransactionsChartView(chartData: vm.transactionsList.monthlyChartData(type: .income), color: .green)
                }
                .background(Color(.secondarySystemBackground).opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 10)
                
                VStack {
                    chartHeader(title: "Expenses", symbol: "arrow.down.circle", value: vm.totalExpenses)
                    TransactionsChartView(chartData: vm.transactionsList.monthlyChartData(type: .expense), color: .red)
                }
                .background(Color(.secondarySystemBackground).opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 10)
                
                VStack {
                    chartHeader(title: "Total", symbol: nil, value: vm.totalAmount)
                    TransactionsChartView(chartData: vm.transactionsList.monthlyChartData(type: nil), color: .gray)
                }
                .background(Color(.secondarySystemBackground).opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 10)
            }
        }
        .padding()
        .scrollIndicators(.hidden)
    }
    
    private func chartHeader(title: String, symbol: String?, value: Double) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.title2)
                .fontWeight(.heavy)
            Spacer()
            HStack {
                if let symbol {
                    Image(systemName: symbol)
                }
                Text("\(value.formatted(.currency(code: vm.currency)))")
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
            }
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(title=="Incomes" ? .green : title=="Expenses" ? .red : .primary)
        }
        .padding()
    }
}

#Preview {
    StaticticsView()
        .environmentObject(HomeViewModel())
}
