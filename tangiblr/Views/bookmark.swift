//
//  bookmark.swift
//  tangiblr
//
//  Created by Daniel Ezomo on 2024/08/09.
//

import SwiftUI

struct bookmark: View {
    @EnvironmentObject var global: AppState
    
    let columns = [
        GridItem(.flexible(), spacing: 16), // Adjust spacing between columns
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) { // Adjust spacing between rows
                    ForEach(global.bookmark,id: \.self) { post_id  in
                        NavigationLink(value: post_id) {
                            ItemView(documentID: post_id)
                                .frame(height: 200) // Ensure a consistent height
                        }
                    }
                }
                .padding([.horizontal, .top], 16) // Add padding to the grid

            }
    
            .navigationDestination(for: String.self) {
                PostDetailsView(documentID: $0)
            }
        }
    }
}

#Preview {
    bookmark()
}


