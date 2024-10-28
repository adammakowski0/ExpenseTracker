//
//  HomeViewModel.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 20/10/2024.
//

import Foundation
import SwiftUI
import CloudKit

class HomeViewModel: ObservableObject {
    @Published var transactionsList: [TransactionModel] = []
    @Published var transactionsCategories: [TransactionCategory] = []
    @Published var totalAmount: Double = 0.0
    @Published var totalIncomes: Double = 0.0
    @Published var totalExpenses: Double = 0.0
    
    @Published var currency: String = "PLN"
    @Published var selectedType: TransactionType = .expense
    
    @Published var iCloudSignIn: Bool = false
    @Published var dataLoaded: Bool = false
    
    init() {
        getiCloudStatus()
        fetchCategories()
    }
    
    func getiCloudStatus() {
        CKContainer.default().accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    print("iCloud is available")
                    self?.iCloudSignIn = true
                case .noAccount:
                    print("iCloud is not available")
                case .couldNotDetermine:
                    print("iCloud could not be determined")
                case .restricted:
                    print("iCloud is restricted")
                default:
                    print("Unknown error")
                }
            }
        }
    }
    
    func fetchCategories() {
        dataLoaded = false
        transactionsCategories.removeAll()
        
        var categories: [TransactionCategory] = []
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Categories", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                guard let id = record["id"] as? String else { return }
                guard let name = record["name"] as? String else { return }
                guard let amount = record["amount"] as? Double else { return }
                guard let incomes = record["incomes"] as? Double else { return }
                guard let expenses = record["expenses"] as? Double else { return }
                guard let colorHex = record["color"] as? String else { return }
                guard let symbolRawValue = record["symbol"] as? String else { return }
                
                let category = TransactionCategory(id: UUID(uuidString: id) ?? UUID(), name: name, amount: amount, incomes: incomes, expenses: expenses, colorHex: colorHex, symbolRawValue: symbolRawValue, record: record)
                categories.append(category)
    
            case .failure(let error):
                print(error)
            }
        }
        
        queryOperation.queryResultBlock = { [weak self] result in
            DispatchQueue.main.async {
                self?.transactionsCategories = categories
                self?.fetchTransactions()
            }
        }
        self.addOperation(operation: queryOperation)
    }
    
    func fetchTransactions() {
        transactionsList.removeAll()
        totalAmount = 0.0
        totalIncomes = 0.0
        totalExpenses = 0.0
        
        var transactions: [TransactionModel] = []
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Transactions", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                guard let id = record["id"] as? String else { return }
                guard let name = record["name"] as? String else { return }
                guard let amount = record["amount"] as? Double else { return }
                guard let date = record["date"] as? Date else { return }
                guard let category = record["category"] as? String else { return }
                guard let type = record["type"] as? String else { return }
                
                guard let transactionCategory = self.transactionsCategories.first(where: { $0.id.uuidString == category }) else { return }

                if type == "Income" {
                    let transaction = TransactionModel(id: UUID(uuidString: id) ?? UUID(), name: name, amount: amount, date: date, category: transactionCategory, type: .income, record: record)
                    
                    transactions.append(transaction)
                }
                else if type == "Expense" {
                    let transaction = TransactionModel(id: UUID(uuidString: id) ?? UUID(), name: name, amount: amount, date: date, category: transactionCategory, type: .expense, record: record)
                    
                    transactions.append(transaction)
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
        queryOperation.queryResultBlock = { [weak self] result in
            DispatchQueue.main.async {
                self?.transactionsList = transactions
                withAnimation {
                    self?.updateTotalAmount()
                }
            }
        }
        self.addOperation(operation: queryOperation)
    }
    
    func addOperation(operation: CKDatabaseOperation) {
        CKContainer(identifier: "iCloud.adammakowski.ExpenseTracker").privateCloudDatabase.add(operation)
    }
    
    func updateTotalAmount() {
        for transaction in self.transactionsList {
            if transaction.type == .income {
                totalAmount += transaction.amount
                totalIncomes += transaction.amount
            }
            else if selectedType == .expense {
                totalAmount -= transaction.amount
                totalExpenses += transaction.amount
            }
        }
        dataLoaded = true
    }
    
    func addTransaction(title: String, amount: Double?, date: Date, category: TransactionCategory, selectedType: TransactionType) {

        let newTransactionRecord = CKRecord(recordType: "Transactions")
        newTransactionRecord["id"] = UUID().uuidString
        newTransactionRecord["name"] = title
        newTransactionRecord["amount"] = amount
        newTransactionRecord["date"] = date
        newTransactionRecord["category"] = category.id.uuidString
        newTransactionRecord["type"] = selectedType.rawValue
        
        let transaction = TransactionModel(id: UUID(uuidString: newTransactionRecord["id"] as! String) ?? UUID(), name: title, amount: amount ?? 0.0, date: date, category: category, type: selectedType, record: newTransactionRecord)
        guard let categoryIndex = transactionsCategories.firstIndex(of: category) else { return }
        if selectedType == .expense {
            totalAmount -= transaction.amount
            totalExpenses += transaction.amount
            transactionsCategories[categoryIndex].amount -= transaction.amount
            transactionsCategories[categoryIndex].expenses += transaction.amount
        }
        else if selectedType == .income {
            totalAmount += transaction.amount
            totalIncomes += transaction.amount
            transactionsCategories[categoryIndex].amount += transaction.amount
            transactionsCategories[categoryIndex].incomes += transaction.amount
        }
        updateCategory(category: self.transactionsCategories[categoryIndex])
        saveRecord(record: newTransactionRecord)
        transactionsList.append(transaction)
    }
    
    func addCategory(name: String, color: Color, symbol: CategorySymbolsEnum) {
        guard let hexColor = color.hex else { return }

        let newCategoryRecord = CKRecord(recordType: "Categories")
        newCategoryRecord["id"] = UUID().uuidString
        newCategoryRecord["name"] = name
        newCategoryRecord["amount"] = 0.0
        newCategoryRecord["incomes"] = 0.0
        newCategoryRecord["expenses"] = 0.0
        newCategoryRecord["color"] = hexColor
        newCategoryRecord["symbol"] = symbol.rawValue
        
        let category = TransactionCategory(id: UUID(uuidString: newCategoryRecord["id"] as! String) ?? UUID(), name: name, amount: 0.0, incomes: 0.0, expenses: 0.0, colorHex: hexColor, symbolRawValue: symbol.rawValue, record: newCategoryRecord)
        
        saveRecord(record: newCategoryRecord)
        transactionsCategories.append(category)
    }
    
    func editCategory(category: TransactionCategory, name: String, color: Color, symbol: CategorySymbolsEnum) {
        guard let categoryIndex = transactionsCategories.firstIndex(of: category) else { return }
        guard let hexColor = color.hex else { return }
        
        let updatedRecord = category.record
        
        transactionsCategories[categoryIndex].name = name
        transactionsCategories[categoryIndex].colorHex = hexColor
        transactionsCategories[categoryIndex].symbolRawValue = symbol.rawValue
        
        updatedRecord["name"] = name
        updatedRecord["color"] = hexColor
        updatedRecord["symbol"] = symbol.rawValue
        saveRecord(record: updatedRecord)
    }
    
    func updateTransaction(transaction: TransactionModel) {
        let updatedRecord = transaction.record
        updatedRecord["id"] = transaction.id.uuidString
        updatedRecord["name"] = transaction.name
        updatedRecord["amount"] = transaction.amount
        updatedRecord["date"] = transaction.date
        updatedRecord["category"] = transaction.category.id.uuidString
        updatedRecord["type"] = transaction.type.rawValue
        saveRecord(record: updatedRecord)
    }
    
    func updateCategory(category: TransactionCategory) {
        let updatedRecord = category.record
        updatedRecord["id"] = category.id.uuidString
        updatedRecord["name"] = category.name
        updatedRecord["amount"] = category.amount
        updatedRecord["incomes"] = category.incomes
        updatedRecord["expenses"] = category.expenses
        updatedRecord["color"] = category.color.hex
        updatedRecord["symbol"] = category.symbol.rawValue
        saveRecord(record: updatedRecord)
    }
    
    func saveRecord(record: CKRecord) {
        CKContainer(identifier: "iCloud.adammakowski.ExpenseTracker").privateCloudDatabase.save(record) { returnedRecord, error in
//            print(returnedRecord ?? "")
//            print(error ?? "")
        }
    }
    
    func deleteTransaction(transaction: TransactionModel) {
        
        guard let transactionIndex = transactionsList.firstIndex(where: {$0.id == transaction.id}) else { return }
        guard let categoryIndex = transactionsCategories.firstIndex(where: {$0.id == transaction.category.id}) else { return }
        
        CKContainer(identifier: "iCloud.adammakowski.ExpenseTracker").privateCloudDatabase.delete(withRecordID: transaction.record.recordID) { [weak self] returnedRecord, error in
            DispatchQueue.main.async {
                if transaction.type == .income {
                    self?.totalAmount -= transaction.amount
                    self?.transactionsCategories[categoryIndex].amount -= transaction.amount
                    self?.totalIncomes -= transaction.amount
                    self?.transactionsCategories[categoryIndex].incomes -= transaction.amount
                }
                else if transaction.type == .expense {
                    self?.totalAmount += transaction.amount
                    self?.transactionsCategories[categoryIndex].amount += transaction.amount
                    self?.totalExpenses -= transaction.amount
                    self?.transactionsCategories[categoryIndex].expenses -= transaction.amount
                }

                self?.transactionsList.remove(at: transactionIndex)
            }
            guard let transactionRecord = self?.transactionsList[transactionIndex].record else { return }
            self?.saveRecord(record: transactionRecord)
        }
    }
    
    func deleteCategory(category: TransactionCategory) {
        
        guard let categoryIndex = transactionsCategories.firstIndex(of: category) else { return }
        
        CKContainer(identifier: "iCloud.adammakowski.ExpenseTracker").privateCloudDatabase.delete(withRecordID: category.record.recordID) { [weak self] returnedRecord, error in
            DispatchQueue.main.async {
                self?.totalAmount -= category.amount
                self?.totalIncomes -= category.incomes
                self?.totalExpenses -= category.expenses
                
                for transaction in self?.transactionsList ?? [] {
                    if transaction.category.id == category.id {
                        CKContainer(identifier: "iCloud.adammakowski.ExpenseTracker").privateCloudDatabase.delete(withRecordID: transaction.record.recordID) { [weak self] returnedRecord, error in
                            DispatchQueue.main.async {
                                self?.transactionsList.removeAll(where: { $0.id == transaction.id })
                            }
                        }
                    }
                }
                self?.transactionsCategories.remove(at: categoryIndex)
            }
        }
    }
}
