//
//  PostDetailsView.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/08/04.
//

import SwiftUI

struct PostDetailsView: View {
    var documentID: String;
    
    @State var post: Post?
    
    var body: some View {
        VStack {
            if let post = post {
                Text(post.user)
                Text(post.description)
            } else {
                Text("Loading")
            }
        }.task {
            post = try! await Post.load(documentID)
        }
    }
}
