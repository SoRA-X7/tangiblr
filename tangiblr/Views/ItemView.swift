//
//  ItemView.swift
//  tangiblr
//
//  Created by Daniel Ezomo on 2024/08/09.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ItemView: View {
    var documentID: String;
    
    @State var post: Post?
    @State var contactile: Contactile?
    @State var image: UIImage?
    
    @State var prevVal: Float? = nil
    
    var player = PlayHaptic()
    
    var body: some View {
        VStack {
            if let post = post {
                Text(post.user)
                Text(post.description)
                if let image = image {
                    Image(uiImage: image).resizable().frame(width: 100, height: 100).scaledToFit().clipped()
                }
                    
            } else {
                Text("Loading")
            }
        }.task {
            post = try! await Post.load(documentID)
//            print(post)
            if let post = post {
                contactile = try! Contactile.fromJSON(post.contactile)
            }
            
            guard let images = post?.images else {
                image = nil
                return
            }
            let storage = Storage.storage()
            storage.reference().child(images[0]).downloadURL(completion: {(url, _) in
//                print(url)
                if let url = url {
                    image = getImageByUrl(url: url)
                }
            })
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

//#Preview {
//    ItemView(documentID: <#String#>)
//}
