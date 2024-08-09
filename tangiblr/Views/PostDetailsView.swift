//
//  PostDetailsView.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/08/04.
//

import SwiftUI
import FirebaseStorage

struct PostDetailsView: View {
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
                Text(date2str(date:post.timestamp))
                
                if let image = image {
                    Image(uiImage: image).resizable().frame(width: 350, height: 500).scaledToFit().clipped().gesture(dragGesture)
                }
                    
            } else {
                Text("Loading")
            }
        }.task {
            post = try! await Post.load(documentID)
            print(post)
            if let post = post {
                contactile = try! Contactile.fromJSON(post.contactile)
            }
            
            guard let images = post?.images else {
                image = nil
                return
            }
            let storage = Storage.storage()
            storage.reference().child(images[0]).downloadURL(completion: {(url, _) in
                print(url)
                if let url = url {
                    image = getImageByUrl(url: url)
                }
            })
        }
    }
    
    var dragGesture: some Gesture {
            DragGesture()
                .onChanged { e in
                    let pos = min(500-1, max(0, Int(e.location.y)))
                        if let contactile = contactile {
                            let val = contactile.ext[0].data[pos]
                            if let pv = prevVal {
                                if abs(val - pv) > 0.2 {
                                    do {
                                        try! player.play(intensity: max(1, abs(val - pv) * 1.4))
                                    } catch {
                                        print("CH error")
                                    }
                                }
                            }
                            prevVal = val
                        }
                        
                    
                }
                .onEnded { _ in
                    prevVal = nil
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
    
    func date2str(date:Date) -> String{
        let f = DateFormatter()
        f.timeStyle = .medium
        f.dateStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        
        return f.string(from: date)
    }
}
