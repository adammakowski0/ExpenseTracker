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
    @State var selectedView = 0
    
    @Namespace var namespace
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
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
            }
            
            TabView(selection: $selectedView) {
                VStack(spacing: 0) {
                    headerView(title: "Home")
                    mainScrollView
                }
//                .toolbar(.hidden, for: .tabBar)
                .tag(0)
                
                VStack{
                    headerView(title: "Statistics")
                    StaticticsView()
                }
//                .toolbar(.hidden, for: .tabBar)
                .tag(1)
            }
//            .toolbar(.hidden, for: .tabBar)
            
            //TODO: Make navigation buttons in menu view and add dismiss button
            MenuView(showMenu: $showMenu, selectedView: $selectedView)
                .zIndex(1)
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
}

extension ContentView {
    
    private func headerView(title: String) -> some View {
        HStack {
            Button {
                withAnimation {
                    showMenu.toggle()
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .tint(.primary)
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground), in: .circle)
                    .padding(.leading, 10)
            }
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Spacer()
            
        }
        .padding(.bottom, -10)
    }
    
    private var categoriesPreview: some View {
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
                        categoryPreviewView(category: category)
                    }
                }
            }
        }
    }
    
    private func categoryPreviewView(category: TransactionCategory) -> some View {
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
    
    private var totalAmountTextView: some View {
        VStack {
            VStack {
                Text("\(vm.totalAmount.formatted(.currency(code: vm.currency)))")
                    .font(.system(size: 50))
                    .fontWeight(.heavy)
                    .contentTransition(.numericText())
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
            }
        }
        .padding()
    }
    
    private var incomesValueView: some View {
        
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "arrow.up.circle")
                Text("\(vm.totalIncomes.formatted(.currency(code: vm.currency)))")
                    .lineLimit(1)
                    .contentTransition(.numericText())
            }
            .minimumScaleFactor(0.4)
            .foregroundStyle(.green)
            .frame(maxWidth: UIScreen.main.bounds.width / 2 - 35)
            
            // Incomes bar chart
            HStack(spacing: 0) {
                ForEach(vm.transactionsCategories) { category in
                    Rectangle()
                        .fill(category.color)
                        .frame(width: vm.totalIncomes > 0 && category.incomes > 0 ? category.incomes/vm.totalIncomes * 150 : 0)
                }
            }
            .frame(height: 18)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
        }
        .frame(maxWidth: UIScreen.main.bounds.width / 2)
    }
    
    private var expensesValueView: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "arrow.down.circle")
                Text("\(vm.totalExpenses.formatted(.currency(code: vm.currency)))")
                    .lineLimit(1)
                    .contentTransition(.numericText())
            }
            .minimumScaleFactor(0.4)
            .foregroundStyle(.red)
            .frame(maxWidth: UIScreen.main.bounds.width / 2 - 35)
            
            // Expenses bar chart
            HStack(spacing: 0) {
                
                ForEach(vm.transactionsCategories) { category in
                    Rectangle()
                        .fill(category.color)
                        .frame(width: vm.totalExpenses > 0 && category.expenses > 0 ? category.expenses/vm.totalExpenses * 150 : 0)
                }
            }
            .frame(height: 18)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
        }
        .frame(maxWidth: UIScreen.main.bounds.width / 2)
    }
    
    private var mainScrollView: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 10, pinnedViews: [.sectionHeaders]) {
                
                totalAmountTextView
                
                HStack{
                    incomesValueView
                    expensesValueView
                }
                .font(.title3)
                .fontWeight(.bold)
                .padding(.bottom)
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
                    .padding(.bottom)
                    .background()
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding()
        .ignoresSafeArea(edges: .bottom)
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
                        withAnimation {
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

struct CircleView: View {
    
    @Binding var max: Double
    var angle: Double = 0
    
    var category: TransactionCategory
    var type: TransactionType
    
    var body: some View {
        Circle()
            .trim(from: 0, to: type == .income ? category.incomes/max : category.expenses/max)
            .stroke(category.color.opacity(0.8), style: StrokeStyle(lineWidth: 10, lineCap: .round))
            .rotationEffect(Angle(degrees: 270+angle))
            .frame(maxWidth: 150)
    }
}

#Preview {
    ContentView()
        .environmentObject(HomeViewModel())
}
