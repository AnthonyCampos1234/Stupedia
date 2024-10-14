import SwiftUI

struct ProfileView: View {
    let name: String
    let summary: String
    let reviews: [Review]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "1E90FF"))
                
                Text(summary)
                    .font(.body)
                    .foregroundColor(.white)
                
                Text("Contributions")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "1E90FF"))
                
                ForEach(reviews) { review in
                    ReviewCell(review: review)
                }
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(
            name: "John Doe",
            summary: "A passionate contributor to Stupedia",
            reviews: [
                Review(content: "Great article on Swift!", timestamp: "2h ago"),
                Review(content: "Interesting take on SwiftUI", timestamp: "1d ago")
            ]
        )
    }
}
