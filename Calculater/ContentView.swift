import SwiftUI

struct Expense: Identifiable {
    let id = UUID()
    let cate: String
    let price: String
}

class ExpenseStore: ObservableObject {
    @Published var expenses: [Expense] = []
    
    // 총 지출 금액을 계산하는 프로퍼티
    var totalAmount: String {
        let total = expenses.reduce(0) { $0 + (Double($1.price) ?? 0) }
        return String(format: "%.0f", total)  // 원 단위로 표현
    }
}

struct ContentView: View {
    
    @State var price:String=""
    @State private var cate: Option = .운동
    @StateObject private var expenseStore = ExpenseStore()
    @State private var shouldNavigate = false

    enum Option : String, CaseIterable, Identifiable {
        case 운동, 여가, 식비, 의료비, 생활비, 고정지출, 기타
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                
                VStack(alignment: .leading) {
                    
                    
                    
                    Text("카테고리를 선택해주세요")
                        .padding(.top, 20)
                    
                    Picker("카테고리를 선택해주세요", selection: $cate) {
                        ForEach(Option.allCases) { category in
                            Text(category.rawValue)
                                .frame(maxWidth: .infinity, alignment: .leading) // 텍스트를 왼쪽 정렬
                                .tag(category)
                        }
                        
                    }
                    .pickerStyle(MenuPickerStyle())
                    .labelsHidden()
                    .clipped()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.white)
                            .shadow(color: .gray, radius: 3)
                    )
                    .padding(.bottom, 20)
                    
                    Text("지출 금액을 입력해주세요")
                    
                    TextField("", text: $price)
                        .frame(width: 300, height: 30)
                        .background{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.white)
                                .shadow(color: .gray, radius: 3)
                            
                        }.frame(width: 300, height: 30)
                    
                    Spacer()
                        .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    
                }.padding()
                
                Button(action: {
                    guard !price.isEmpty, let _ = Double(price) else {
                        return
                    }
                    let newExpense = Expense(cate: cate.rawValue, price: price)
                    expenseStore.expenses.append(newExpense)
                    price = ""  // 입력 필드 초기화
                    cate = .운동  // 카테고리 초기화
                    shouldNavigate = true
                }) {
                    Text("계산하기")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 3)
                    
                }
                .padding(.top, 20)
                .navigationDestination(isPresented: $shouldNavigate) {
                    ResultView(expenseStore: expenseStore)
                }
            }
            .padding()
            .navigationTitle("지출 계산기")
        }
    }
}

struct ResultView: View {
    
    @ObservedObject var expenseStore: ExpenseStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    var body: some View {
        VStack (spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("총 지출  >")
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(expenseStore.totalAmount)원")
                        .font(.system(size: 30, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                .padding()
                .frame(width: 330, height: 100)
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.gray.opacity(0.2)))
             
                
                VStack(spacing: 10) {
                    ForEach(expenseStore.expenses) { expense in
                        HStack {
                            Text(expense.cate)
                            Spacer()
                            Text("\(expense.price)원")
                        }
                        .padding(20)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.white).shadow(color: .gray, radius: 3))
                    }
                }.padding(.top, 10)
            }
            .padding(.horizontal)
            Spacer()
            
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("추가하기")
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(color: .gray, radius: 3)
            }
                
        }
        .padding()
        .navigationTitle("지출 계산기")
        
    }
}
#Preview {
    ContentView()
}
