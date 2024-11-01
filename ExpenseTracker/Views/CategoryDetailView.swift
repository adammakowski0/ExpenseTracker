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
                    VStack(spacing: 0){
                        HStack {
                            VStack(spacing: 0) {
                                Text("Incomes")
                                    .font(.headline)
                                HStack {
                                    Image(systemName: "arrow.up.circle")
                                    Text("\(category.incomes.formatted(.currency(code: vm.currency)))")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.4)
                                }
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)
                            }
                            .padding()
                            
                            VStack(spacing: 0) {
                                Text("Expenses")
                                    .font(.headline)
                                HStack {
                                    Image(systemName: "arrow.down.circle")
                                    Text("\(category.expenses.formatted(.currency(code: vm.currency)))")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                }
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.red)
                            }
                            .padding()
                        }
                        VStack(spacing: 0) {
                            Text("Total")
                                .font(.title3)
                                .fontWeight(.semibold)
                            HStack {
                                Text("\(category.amount.formatted(.currency(code: vm.currency)))")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                        }
                        .padding()
                    }
                    
                    Chart {
                        ForEach(vm.transactionsList) { transaction in
                            if transaction.category.id == category.id {
                                BarMark(
                                    x: .value("Month", transaction.date, unit: .month),
                                    y: .value("Amount", transaction.amount))
                                .foregroundStyle(category.color.gradient)
                                .cornerRadius(4)
                            }
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
                    
                    Divider()
                    
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
                    .fontWeight(.light)
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
