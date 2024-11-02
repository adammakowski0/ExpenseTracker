//
//  CategoryDetailView.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 21/10/2024.
//

import SwiftUI
import CloudKit
import Charts

struct CategoryDetailView: View {
    
    @EnvironmentObject var vm: HomeViewModel
    @Environment(\.dismiss) var dismiss
    var category: TransactionCategory
    
    @State var showEditView: Bool = false
    
    var filteredTransactions: [TransactionModel] {
        return vm.transactionsList.filter( {$0.category.id == category.id} )
    }
    
    var body: some View {
        ZStack {
            VStack {
                header
                ScrollView {
                    VStack {
                        VStack {
                            chartHeader(title: "Incomes", symbol: "arrow.up.circle", value: category.incomes)
                            TransactionsChartView(chartData: vm.transactionsList.monthlyCategoryChartData(for: category, type: .income), color: category.color)
                        }
                        .background(Color(.secondarySystemBackground).opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 10)
                        
                        VStack {
                            chartHeader(title: "Expenses", symbol: "arrow.down.circle", value: category.expenses)
                            TransactionsChartView(chartData: vm.transactionsList.monthlyCategoryChartData(for: category, type: .expense), color: category.color)
                        }
                        .background(Color(.secondarySystemBackground).opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 10)
                        
                        VStack {
                            chartHeader(title: "Total", symbol: nil, value: category.amount)
                            TransactionsChartView(chartData: vm.transactionsList.monthlyCategoryChartData(for: category, type: nil), color: category.color)
                        }
                        .background(Color(.secondarySystemBackground).opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 10)
                    }
                    
                    Divider()
                        .padding()
                    
                    Text("Transactions")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    VStack{
                        ForEach(filteredTransactions) { transaction in
                            TransactionRowView(transaction: transaction)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .tint(category.color)
            .frame(maxHeight: .infinity, alignment: .top)
            .sheet(isPresented: $showEditView) {
                AddCategoryView(name: category.name, color: category.color, selectedSymbol: category.symbol, editMode: true, category: category)
            }
        }
    }
}

extension CategoryDetailView {
    var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.headline)
                    .fontWeight(.regular)
                    .padding(.leading, 20)
            }
            Spacer()
            Image(systemName: category.symbol.rawValue)
                .foregroundStyle(category.color)
            Text(category.name)
                .font(.title3)
                .fontWeight(.heavy)
            Spacer()
            Button {
                withAnimation {
                    showEditView = true
                }
            } label: {
                Text("Edit")
                    .font(.headline)
                    .padding(.trailing, 20)
            }
        }
        .padding(.vertical, 20)
        .background(Color(uiColor: .secondarySystemBackground))
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

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }
}

#Preview {
    CategoryDetailView(category: TransactionCategory(name: "General", amount: 1543.32, incomes: 2000, expenses: 456.68, colorHex: "#000000", symbolRawValue: CategorySymbolsEnum.groceries.rawValue, record: CKRecord(recordType: "Categories")), showEditView: false)
        .environmentObject(HomeViewModel())
}


extension Array where Element == TransactionModel {
    func monthlyChartData(type: TransactionType?) -> [ChartData] {
        let calendar = Calendar.current
        let last12Months = calendar.date(byAdding: .month, value: -12, to: Date())!
        
        var recentTransactions: [TransactionModel] = []

        if type == .expense {
            recentTransactions = self.filter { $0.date >= last12Months && $0.type == .expense }
        }
        else if type == .income {
            recentTransactions = self.filter { $0.date >= last12Months && $0.type == .income }
        }
        else {
            recentTransactions = self.filter { $0.date >= last12Months }
        }

        let groupedByMonth = Dictionary(grouping: recentTransactions) { (transaction) -> Date in
            let components = calendar.dateComponents([.year, .month], from: transaction.date)
            return calendar.date(from: components)!
        }

        return groupedByMonth.map { (month, transactions) in
            let totalAmount = transactions.reduce(0) {
                if $1.type == .expense {
                    return $0 - $1.amount
                }
                else if $1.type == .income {
                    return $0 + $1.amount
                }
                return $0
            }
            return ChartData(value: totalAmount, date: month)
        }.sorted { $0.date < $1.date }
    }
}

extension Array where Element == TransactionModel {
    func monthlyCategoryChartData(for category: TransactionCategory, type: TransactionType?) -> [ChartData] {
        let calendar = Calendar.current
        let last12Months = calendar.date(byAdding: .month, value: -12, to: Date())!

        var recentTransactions: [TransactionModel] = []
        if type == .expense {
            recentTransactions = self.filter { $0.date >= last12Months && $0.category == category && $0.type == .expense }
        }
        else if type == .income {
            recentTransactions = self.filter { $0.date >= last12Months && $0.category == category && $0.type == .income }
        }
        else {
            recentTransactions = self.filter { $0.date >= last12Months && $0.category == category }
        }
        
        let groupedByMonth = Dictionary(grouping: recentTransactions) { transaction -> Date in
            let components = calendar.dateComponents([.year, .month], from: transaction.date)
            return calendar.date(from: components)!
        }
        
        return groupedByMonth.map { (month, transactions) in
            let totalAmount = transactions.reduce(0) {
                if $1.type == .expense {
                    return $0 - $1.amount
                }
                else if $1.type == .income {
                    return $0 + $1.amount
                }
                return $0
            }
            return ChartData(value: totalAmount, date: month)
        }.sorted { $0.date < $1.date }
    }
}

