//
//  CategoryDetailView.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 21/10/2024.
//

import SwiftUI
import CloudKit

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
                        HStack {
                            VStack{
                                Text("Incomes")
                                    .font(.title3)
                                    .bold()
                                    .padding(.bottom, 10)
                                HStack {
                                    Image(systemName: "arrow.up.circle")
                                    Text("\(category.incomes.formatted(.currency(code: vm.currency)))")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .contentTransition(.numericText())
                                }
                                .font(.title2)
                                .fontWeight(.heavy)
                                .foregroundStyle(.green)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0)
                            )
                            .padding(10)
                            
                            VStack {
                                Text("Expenses")
                                    .font(.title3)
                                    .bold()
                                    .padding(.bottom, 10)
                                HStack {
                                    Image(systemName: "arrow.down.circle")
                                    Text("\(category.expenses.formatted(.currency(code: vm.currency)))")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .contentTransition(.numericText())
                                }
                                .font(.title2)
                                .fontWeight(.heavy)
                                .foregroundStyle(.red)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0)
                            )
                            .padding(10)
                        }
                        
                        HStack {
                            Text("Total: \(category.amount.formatted(.currency(code: vm.currency)))")
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(uiColor: .secondarySystemBackground))
                                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0)
                        )
                        .padding()
                    }
                    
                    
                    Text("Transactions")
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

