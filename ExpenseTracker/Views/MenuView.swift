//
//  MenuView.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 29/10/2024.
//

import SwiftUI

struct MenuView: View {
    
    var body: some View {
        Color(.secondarySystemBackground).opacity(0.95)
            .ignoresSafeArea()
            .frame(width: UIScreen.main.bounds.width/2)
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
    }
}

#Preview {
    MenuView()
}
