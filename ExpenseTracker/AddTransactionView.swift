//
//  AddTransactionView.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 20/10/2024.
//

import SwiftUI

struct AddTransactionView: View {
    
    @EnvironmentObject var vm: HomeViewModel
    @State var title: String = ""
    @State var amount: Double? = nil
    @State var date: Date = Date()
    @State var selectedCategory: TransactionCategory?
    
    @Namespace var namespace
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        VStack {
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
                Text("Add transaction")
                
                    .font(.title3)
                    .fontWeight(.heavy)
                Spacer()
                Button {
                    if let selectedCategory {
                        withAnimation {
                            vm.addTransaction(title: title, amount: amount ?? 0.0, date: date, category: selectedCategory, selectedType: vm.selectedType)
                        }
                        dismiss()
                    }
                } label: {
                    Text("Save")
                        .font(.headline)
                        .padding(.trailing, 20)
                        .foregroundStyle(
                            ((title.isEmpty || amount == nil || selectedCategory == nil) ? .gray : selectedCategory?.color)!)
                }
                .disabled(title.isEmpty || amount == nil || selectedCategory == nil)
            }
            .padding(.vertical, 20)
            .background(Color(uiColor: .secondarySystemBackground))
            ScrollView{
                HStack(spacing: 15) {
                    TextField("Title", text: $title)
                        .padding(10)
                        .background(Color(uiColor: .secondarySystemBackground), in: .rect(cornerRadius: 10))
                        .padding(.leading)
                    
                    TextField("Amount", value: $amount, format: .number)
                        .padding(10)
                        .background(Color(uiColor: .secondarySystemBackground), in: .rect(cornerRadius: 10))
                        .frame(width: UIScreen.main.bounds.width/3.5)
                        .keyboardType(.numberPad)
                    
                    Text(vm.currency)
                        .padding(.trailing)
                        .padding(.leading, -10)
                }
                .padding(.top, 10)
                
                SegmentedControl()
                    .padding()
                HStack{
                    Text("Category")
                        .padding(.leading)
                    
                    Spacer()

                    Menu {
                        ForEach(vm.transactionsCategories) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                Label(category.name, systemImage: category.symbol.rawValue)
                            }

                        }
                    } label: {
                        if let selectedCategory {
                            Label(selectedCategory.name, systemImage: selectedCategory.symbol.rawValue)
                                .padding(10)
                        }
                        else{
                            Label("Choose Category", systemImage: "")
                                .padding(10)
                        }
                        
                    }
                }
                .padding(10)
                .background(Color(uiColor: .secondarySystemBackground), in: .rect(cornerRadius: 10))
                .padding(.horizontal)
                
                
                DatePicker("", selection: $date, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .background(Color(uiColor: .secondarySystemBackground), in: .rect(cornerRadius: 10))
                    .padding()
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .tint(selectedCategory?.color)
    }
    var amountFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    @ViewBuilder
    func SegmentedControl() -> some View {
        HStack{
            ForEach(TransactionType.allCases, id: \.rawValue) { type in
                Text(type.rawValue)
                    .font(.headline)
                    .padding(12)
                    .frame(maxWidth: UIScreen.main.bounds.width / 2)
                    .background {
                        if type == vm.selectedType {
                            Capsule()
                                .fill(.background.shadow(.inner(color: .black.opacity(0.2), radius: 1)))
                                .matchedGeometryEffect(id: "segmentedControl", in: namespace)
                                .padding(5)
                                .shadow(radius: 2)
                        }
                    }
                    .contentShape(.capsule)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            vm.selectedType = type
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            Capsule()
                .fill(Color(uiColor: .secondarySystemBackground).shadow(.inner(color: .black.opacity(0.1), radius: 2)))
        )
    }
}

#Preview {
    AddTransactionView()
        .environmentObject(HomeViewModel())
}
