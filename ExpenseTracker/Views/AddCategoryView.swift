//
//  AddCategoryView.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 21/10/2024.
//

import SwiftUI

struct AddCategoryView: View {
    
    @EnvironmentObject var vm: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = ""
    @State var color: Color = Color(.blue)
    @State var selectedSymbol: CategorySymbolsEnum = .groceries
    
    @State var editMode: Bool = false
    var category: TransactionCategory?
    
    var body: some View {
        VStack{
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
                Text("Add category")
                    .font(.title3)
                    .fontWeight(.heavy)
                Spacer()
                Button {
                    if editMode{
                        if let category {
                            withAnimation {
                                vm.editCategory(category: category, name: name, color: color, symbol: selectedSymbol)
                            }
                        }
                        dismiss()
                    }
                    else {
                        withAnimation {
                            vm.addCategory(name: name, color: color, symbol: selectedSymbol)
                        }
                        dismiss()
                    }
                } label: {
                    Text("Save")
                        .font(.headline)
                        .padding(.trailing, 20)
                        .foregroundStyle((name.isEmpty ? .gray : color))
                }
                .disabled(name.isEmpty)
            }
            .padding(.vertical, 20)
            .background(Color(uiColor: .secondarySystemBackground))
            ScrollView{
                TextField("Category Name", text: $name)
                    .padding(15)
                    .background(Color(uiColor: .secondarySystemBackground), in: .rect(cornerRadius: 10))
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                
                
                ColorPicker("Select Category Color", selection: $color)
                    .padding(15)
                    .background(Color(uiColor: .secondarySystemBackground), in: .rect(cornerRadius: 10))
                    .padding(.horizontal)

                ScrollView {
                    LazyVGrid(columns: [
                                  .init(.fixed(50), spacing: 10),
                                  .init(.adaptive(minimum: 50), spacing: 10)
                              ],
                              spacing: 10) {
                        ForEach(CategorySymbolsEnum.allCases, id: \.self) { symbol in
                            Image(systemName: symbol.rawValue)
                                .padding()
                                .background(selectedSymbol == symbol ? color : Color(uiColor: .secondarySystemBackground), in: Circle())
                                .onTapGesture {
                                    withAnimation {
                                        selectedSymbol = symbol
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .tint(color)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    AddCategoryView()
        .environmentObject(HomeViewModel())
}
