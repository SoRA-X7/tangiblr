import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    var filter: (String, Any)?
    @State var posts: [DocRef<Post>] = []
    
    let columns = [
        GridItem(.flexible(), spacing: 16), // Adjust spacing between columns
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack {
            if let filter = filter {
                HStack {
                    Text(filter.1 as? String ?? "").bold().font(.headline).padding()
                    Spacer()
                }
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) { // Adjust spacing between rows
                    ForEach(posts) { post in
                        NavigationLink {
                            PostDetailsView(documentID: post.id)
                        } label: {
                            ItemView(documentID: post.id)
                                .frame(height: 200) // Ensure a consistent height
                        }
                    }
                }
                .padding([.horizontal, .top], 16) // Add padding to the grid
                .refreshable {
                    if let filter = filter {
                        posts = try! await Post.fetchFromFirestore(filterFieldEq: filter.0, filterValue: filter.1)
                    } else {
                        posts = try! await Post.fetchFromFirestore()
                    }
                }
            }
            .task {
                if let filter = filter {
                    posts = try! await Post.fetchFromFirestore(filterFieldEq: filter.0, filterValue: filter.1)
                } else {
                    posts = try! await Post.fetchFromFirestore()
                }
            }
        }
        
        
    }
}

#Preview {
    HomeView(filter: nil)
}

