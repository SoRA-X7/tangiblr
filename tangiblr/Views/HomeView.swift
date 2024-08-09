//
//  HomeView.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/07/29.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @State var posts: [DocRef<Post>] = []
    
    var body: some View {
        NavigationStack {
            VStack() {
                List(posts) { post in
                    NavigationLink(value: post.id) {
                        ItemView(documentID: post.id)
                    }
                }.refreshable {
                    posts = try! await Post.fetchFromFirestore()
                }
            }.task {
                posts = try! await Post.fetchFromFirestore()
            }.navigationDestination(for: String.self) {
                PostDetailsView(documentID: $0)
            }
        }
    }
}

#Preview {
    HomeView()
}
