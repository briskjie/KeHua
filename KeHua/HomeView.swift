import SwiftUI

struct HomeView: View {
    @State private var categories: [CategoryItem] = []
    @State private var isLoading = true
    @State private var showError = false
    
    // 颜色数组对应Android版本的颜色
    private let colors: [Color] = [
        .orange, .green, .blue, .purple,
        .yellow, .pink, .teal, .indigo,
        .orange, .blue
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 网格布局
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                        ForEach(categories) { category in
                            CategoryCard(category: category)
                                .frame(height: geometry.size.width / 4 - 20)
                                .onTapGesture {
                                    // 点击跳转到详情页
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first {
                                        window.rootViewController?.present(
                                            UIHostingController(rootView: CategoryDetailView(
                                                categoryId: category.id,
                                                categoryName: category.name,
                                                categoryColor: category.color
                                            )),
                                            animated: true
                                        )
                                    }
                                }
                        }
                    }
                    .padding()
                }
                
                // 加载指示器
                if isLoading {
                    ProgressView()
                        .scaleEffect(2)
                }
            }
            .onAppear {
                loadData()
            }
            .alert("数据加载失败，请重试", isPresented: $showError) {
                Button("确定", role: .cancel) { }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .statusBarHidden(true) // 隐藏状态栏
    }
    
    private func loadData() {
        isLoading = true
        
        // 模拟数据加载
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // 这里应该替换为实际的数据加载逻辑
            // 模拟创建10个分类项
            categories = (0..<10).map { index in
                CategoryItem(
                    id: "cat_\(index)",
                    name: "分类 \(index + 1)",
                    color: colors[index % colors.count],
                    imageName: "category_\(index % 5 + 1)" // 假设有5张图片循环使用
                )
            }
            isLoading = false
        }
    }
}

struct CategoryItem: Identifiable {
    let id: String
    let name: String
    let color: Color
    let imageName: String?
}

struct CategoryCard: View {
    let category: CategoryItem
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(category.color)
            
            VStack {
                if let imageName = category.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
                
                Text(category.name)
                    .foregroundColor(.white)
                    .font(.headline)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}