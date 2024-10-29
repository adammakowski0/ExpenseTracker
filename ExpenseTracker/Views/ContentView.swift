//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 20/08/2024.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var vm: HomeViewModel
    
    @State var addTransaction: Bool = false
    @State var addCategory: Bool = false
    @State var selectedCategory: TransactionCategory? = nil
    @State var showMenu: Bool = false
    
    @Namespace var namespace
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var filteredTransactions: [TransactionModel] {
        return vm.transactionsList.filter({ $0.type == vm.selectedType})
    }
    
    var body: some View {
        ZStack {
            if !vm.dataLoaded{
                LoadingView()
                    .zIndex(1)
            }
            if showMenu {
                //TODO: Make navigation buttons in menu view and add dismiss button
                MenuView()
                    .zIndex(2)
                    .transition(.move(edge: .leading))
                    .onTapGesture {
                        withAnimation {
                            showMenu = false
                        }
                    }
            }
            
            ScrollView {
                LazyVStack(alignment: .center, spacing: 15, pinnedViews: [.sectionHeaders]) {
                    
                    headerView
                    
                    circleMainView
                    
                    HStack{
                        HStack {
                            Image(systemName: "arrow.up.circle")
                            Text("\(vm.totalIncomes.formatted(.currency(code: vm.currency)))")
                                .lineLimit(1)
                                .contentTransition(.numericText())
                        }
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(.green)
                        .frame(maxWidth: UIScreen.main.bounds.width / 2, alignment: .center)
                        
                        HStack {
                            Image(systemName: "arrow.down.circle")
                            Text("\(vm.totalExpenses.formatted(.currency(code: vm.currency)))")
                                .lineLimit(1)
                                .contentTransition(.numericText())
                        }
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(.red)
                        .frame(maxWidth: UIScreen.main.bounds.width / 2)
                    }
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 10)
                    
                    categoriesPreview
                    
                    Section {
                        if vm.transactionsList.isEmpty {
                            VStack {
                                Text("No transactions yet")
                                    .padding(.vertical)
                                Text("Add first with \(Image(systemName: "plus.circle.fill")) button")
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                        }
                        ForEach(filteredTransactions) { transaction in
                            TransactionRowView(transaction: transaction)
                        }
                        Divider()
                            .opacity(0.0)
                            .padding(200)
                    } header: {
                        VStack{
                            HStack {
                                Text(vm.selectedType.rawValue + "s")
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .padding(.bottom, 10)
                                    .animation(.none, value: vm.selectedType)
                                Spacer()
                                Button {
                                    addTransaction = true
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                        .tint(.primary)
                                        .padding(.trailing)
                                }
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            SegmentedControl()
                        }
                        .background()
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding()
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $addTransaction) {
            AddTransactionView()
        }
        .sheet(isPresented: $addCategory) {
            AddCategoryView()
        }
        .sheet(item: $selectedCategory) { category in
            CategoryDetailView(category: category)
        }
    }
    
    @ViewBuilder
    func SegmentedControl() -> some View {
        HStack{
            ForEach(TransactionType.allCases, id: \.rawValue) { type in
                Text(type.rawValue + "s")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: UIScreen.main.bounds.width / 2)
                    .background {
                        if type == vm.selectedType {
                            Capsule()
                                .fill(.background.shadow(.inner(color: .black.opacity(0.2), radius: 2, x: 0, y: 0)))
                                .matchedGeometryEffect(id: "segmentedControl", in: namespace)
                                .padding(5)
                                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 0)
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
                .fill(Color(uiColor: .secondarySystemBackground).shadow(.inner(color: .black.opacity(0.2), radius: 3, x: 0, y: 0)))
        )
    }
}

extension ContentView {
    
    var headerView: some View {
        HStack {
            Button {
                // TODO: Show menu
                withAnimation {
                    showMenu.toggle()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .tint(.primary)
                    .padding()
                    .background(.black.gradient.opacity(0.15), in: .circle)
                    .padding(.leading, 10)
                    
            }
            Spacer()
            Button {
                // TODO: Profile view and settings
            } label: {
                Image(systemName: "person.fill")
                    .tint(.primary)
                    .padding(12)
                    .background(.black.gradient.opacity(0.15), in: .circle)
                    .padding(.trailing, 10)
            }
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(Color(uiColor: .secondarySystemBackground).opacity(0.95), in: .rect(cornerRadius: 10))
    }
    
    var circleMainView: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.2), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(maxWidth: 270)
                ForEach(Array(vm.transactionsCategories.enumerated()), id: \.offset) { index, category in
                    let sum = vm.transactionsCategories.prefix(index).reduce(0) { $0 + $1.incomes }
                    CircleView(max: $vm.totalAmount, angle: sum/vm.totalAmount*360, category: category)
                }
                
                Text("\(vm.totalAmount.formatted(.currency(code: vm.currency)))")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .contentTransition(.numericText())
                    .frame(maxWidth: 220)
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
            }
        }
        .padding()
    }
    
    var categoriesPreview: some View {
        VStack{
            HStack {
                Text("Categories")
                    .font(.title)
                    .fontWeight(.heavy)
                    .padding(.bottom, 10)
                    .animation(.none, value: vm.selectedType)
                Spacer()
                Button {
                    addCategory = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .tint(.primary)
                        .padding(.trailing)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if vm.transactionsCategories.isEmpty {
                Text("Add first category with \(Image(systemName: "plus.circle.fill")) button")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            ScrollView(.horizontal){
                HStack {
                    ForEach(vm.transactionsCategories) { category in
                        VStack {
                            HStack {
                                Image(systemName: category.symbol.rawValue)
                                Spacer()
                                Text(category.name)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .font(.headline)
                            .fontWeight(.heavy)
                            .foregroundStyle(category.color)
                            .padding(.top, 10)
                            .padding(.bottom, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Image(systemName: "arrow.up.circle")
                                Text("\(category.incomes.formatted(.currency(code: vm.currency)))")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .contentTransition(.numericText())
                            }
                            .font(.footnote)
                            .foregroundStyle(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                Text("\(category.expenses.formatted(.currency(code: vm.currency)))")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .contentTransition(.numericText())
                            }
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            HStack {
                                Image(systemName: "plusminus.circle")
                                    .font(.footnote)
                                Text("Total: \(category.amount.formatted(.currency(code: vm.currency)))")
                                    .font(.subheadline)
                                    .bold()
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .contentTransition(.numericText())
                            }
                            .padding(.top, 1)
                        }
                        .padding([.bottom, .horizontal])
                        .frame(maxWidth: 180, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(uiColor: .secondarySystemBackground))
                                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0)
                        )
                        .onTapGesture {
                            selectedCategory = category
                        }
                        .contextMenu {
                            Button {
                                withAnimation {
                                    vm.deleteCategory(category: category)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }
}

extension AnyTransition {
    static func transactionListTransition(selectedType: TransactionType) -> AnyTransition {
        if selectedType == .income {
            return AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing))
        }
        else if selectedType == .expense {
            return AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading))
        }
        else {
            return AnyTransition.identity
        }
    }
}


struct CircleView: View {
    
    @Binding var max: Double
    var angle: Double = 0
    
    var category: TransactionCategory
    var body: some View {
        Circle()
            .trim(from: 0, to: category.amount/max)
            .stroke(category.color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
            .rotationEffect(Angle(degrees: 270+angle))
            .frame(maxWidth: 270)
            .shadow(color: category.color.opacity(0.2), radius: 5)
    }
}

#Preview {
    ContentView()
        .environmentObject(HomeViewModel())
}
