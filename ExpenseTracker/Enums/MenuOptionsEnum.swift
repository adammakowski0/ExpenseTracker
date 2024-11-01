//
//  MenuOptionsEnum.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 31/10/2024.
//

import SwiftUI

enum MenuOptions: Int, CaseIterable, Identifiable {
    //TODO: Add more screens
    case home
    case statistics
//    case settings
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .statistics: return "Statistics"
//        case .settings: return "Settings"
        }
    }
    
    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .statistics: return "chart.bar.fill"//chart.bar.xaxis
//        case .settings: return "gearshape.fill"
        }
    }
}
