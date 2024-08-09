//
//  HomeView.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/07/29.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct HomeView: View {
    @State var posts: [DocRef<Post>] = []
    
    var body: some View {
        NavigationStack {
            VStack() {
                ScrollView {
                    List(posts) { post in
                        Text("hello")
//                        NavigationLink(value: post.id) {
//                            ItemView(documentID: post.id)
//                        }
                    }.refreshable {
                        posts = try! await Post.fetchFromFirestore()
                    }
                }
            }.task {
                posts = try! await Post.fetchFromFirestore()
            }.navigationDestination(for: String.self) {
                PostDetailsView(documentID: $0)
            }
        }
    }
    

    
    func getImageByUrl(url: URL) -> UIImage{
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        return UIImage()
    }
    
    
}

#Preview {
    HomeView()
}
