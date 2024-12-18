//
//  TransactionRowView.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 25/10/2024.
//

import SwiftUI
import CloudKit

struct TransactionRowView: View {
    
    @EnvironmentObject var vm: HomeViewModel
    
    let transaction: TransactionModel
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(transaction.name)
                    .font(.headline)
                Text(transaction.category.name)
                    .foregroundStyle(transaction.category.color)
                Text(transaction.date, formatter: dateFormatter)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if transaction.type == .income {
                Text("\(transaction.amount.formatted(.currency(code: vm.currency)))")
                    .foregroundStyle(.green)
            }
            else if transaction.type == .expense {
                Text("-\(transaction.amount.formatted(.currency(code: vm.currency)))")
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 2)
        .padding(.horizontal, 5)
        .transition(AnyTransition.transactionListTransition(selectedType: vm.selectedType))
        .contextMenu {
            Button {
                withAnimation {
                    vm.deleteTransaction(transaction: transaction)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

extension AnyTransition {
    static func transactionListTransition(selectedType: TransactionType) -> AnyTransition {
        if selectedType == .expense {
            return AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
        }
        if selectedType == .income {
            return AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
        }
        else {
            return AnyTransition.slide
        }
    }
}

#Preview {
    TransactionRowView(transaction: TransactionModel(name: "Test", amount: 100, date: Date(), category: TransactionCategory(name: "General", amount: 150, incomes: 200, expenses: 50, colorHex: "#000000", symbolRawValue: "cart.fill", record: CKRecord(recordType: "Categories")), type: .expense, record: CKRecord(recordType: "Transactions")))
        .environmentObject(HomeViewModel())
}
