//
//  MenuView.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 29/10/2024.
//

import SwiftUI

struct MenuView: View {
    
    @Binding var showMenu: Bool
    @Binding var selectedView: Int
    
    var body: some View {
        ZStack{
            if showMenu{
                
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showMenu = false
                        }
                    }
                HStack {
                    VStack(alignment: .leading) {
                        //TODO: Add user login
//                        HStack(spacing: 15) {
//                            Image(systemName: "person")
//                                .padding(10)
//                                .foregroundStyle(.blue)
//                                .background(.blue.opacity(0.3), in: .circle)
//                            Text("Username")
//                                .font(.callout)
//                                .fontWeight(.semibold)
//                        }
//                        .padding(.horizontal)
                        
                        Divider()
                        
                        ForEach(MenuOptions.allCases) { option in
                            Button {
                                withAnimation {
                                    selectedView = option.rawValue
                                    showMenu = false
                                }
                            } label: {
                                Label {
                                    Text(option.title)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                } icon: {
                                    Image(systemName: option.symbol)
                                }
                                
                            }
                            .foregroundStyle(selectedView == option.rawValue ? .blue : .primary)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(selectedView == option.rawValue ? .blue.opacity(0.3) : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
   
                        }
                        Spacer()
                    }
                    .frame(width: 230, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    
                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
        }
    }
}

#Preview {
    MenuView(showMenu: .constant(true),selectedView: .constant(0))
}
