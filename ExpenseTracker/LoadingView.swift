//
//  LoadingView.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 27/10/2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack{
            Text("Loading data...")
            ProgressView()
        }
        .padding(20)
        .padding(.horizontal, 20)
        .background(Color(uiColor: .secondarySystemBackground).opacity(0.95), in: .rect(cornerRadius: 10))
    }
}

#Preview {
    LoadingView()
}

