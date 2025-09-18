import SwiftUI

struct CategoryDetailView: View {
    let categoryId: String
    let categoryName: String
    let categoryColor: Color
    
    var body: some View {
        ZStack {
            categoryColor
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(categoryName)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                
                // TODO: 添加详情内容
                
                Spacer()
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CategoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryDetailView(
                categoryId: "cat_1",
                categoryName: "示例分类",
                categoryColor: .blue
            )
        }
    }
}