import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @State var posts: [DocRef<Post>] = []

    let columns = [
        GridItem(.flexible(), spacing: 16), // Adjust spacing between columns
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) { // Adjust spacing between rows
                    ForEach(posts) { post in
                        NavigationLink(value: post.id) {
                            ItemView(documentID: post.id)
                                .frame(height: 200) // Ensure a consistent height
                        }
                    }
                }
                .padding([.horizontal, .top], 16) // Add padding to the grid
                .refreshable {
                    posts = try! await Post.fetchFromFirestore()
                }
            }
            .task {
                posts = try! await Post.fetchFromFirestore()
            }
            .navigationDestination(for: String.self) {
                PostDetailsView(documentID: $0)
            }
        }
    }
}

#Preview {
    HomeView()
}

