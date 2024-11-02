//
//  ExpenseModel.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 20/10/2024.
//

import Foundation
import SwiftUI
import CloudKit


struct TransactionModel: Identifiable {
    let id: UUID
    let name: String
    let amount: Double
    let date: Date
    var category: TransactionCategory
    let type: TransactionType
    let record: CKRecord
    
    init(id: UUID = UUID(), name: String, amount: Double, date: Date, category: TransactionCategory, type: TransactionType, record: CKRecord) {
        self.id = id
        self.name = name
        self.amount = amount
        self.date = date
        self.category = category
        self.type = type
        self.record = record
    }
}

struct TransactionCategory: Identifiable, Equatable {
    static func == (lhs: TransactionCategory, rhs: TransactionCategory) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    var name: String
    var amount: Double
    var incomes: Double
    var expenses: Double
    var colorHex: String
    var symbolRawValue: String
    let record: CKRecord
    
    init(id: UUID = UUID(), name: String, amount: Double, incomes: Double, expenses: Double, colorHex: String, symbolRawValue: String, record: CKRecord) {
        self.id = id
        self.name = name
        self.amount = amount
        self.incomes = incomes
        self.expenses = expenses
        self.colorHex = colorHex
        self.symbolRawValue = symbolRawValue
        self.record = record
    }

    var color: Color {
        get {
            Color(hex: colorHex) ?? .blue
        }
        set {
            colorHex = newValue.hex ?? "#000000"
        }
    }

    var symbol: CategorySymbolsEnum {
        get {
            CategorySymbolsEnum(rawValue: symbolRawValue) ?? .groceries
        }
        set {
            symbolRawValue = newValue.rawValue
        }
    }
}

enum TransactionType: String, CaseIterable {
    case expense = "Expense"
    case income = "Income"
}


struct ChartData: Identifiable {
    var id: UUID = UUID()
    var value: Double
    var date: Date
}


extension Color {
    var hex: String? {
        guard let components = self.cgColor?.components, components.count >= 3 else {
            return nil
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
