import SwiftUI
import FirebaseStorage

struct PostDetailsView: View {
    @EnvironmentObject var global: AppState
    var documentID: String
    
    @State var post: Post?
    @State var contactile: Contactile?
    @State var image: UIImage?
    
    @State var prevVal: Float? = nil
    

    
    
    var player = PlayHaptic()
    
    var body: some View {
        VStack {
            if let post = post {
                HStack(alignment: .center, spacing: 8) {
                    
                    
                    VStack(alignment: .leading) {
                        Text(post.user)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(date2str(date: post.timestamp))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer() // スペースを使って要素を左寄せにする
                }
                .padding(.horizontal)
                .padding(.top)
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .gesture(dragGesture)
                }
                
                HStack {
                    Text(post.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    Button(action: {
                        if global.bookmark.contains(documentID) {
                            global.bookmark.removeAll { $0 == documentID }
                        } else {
                            global.bookmark.append(documentID)
                        }
                        UserDefaults.standard.set(global.bookmark, forKey: "bookmark")
                    
                    }) {
                        VStack {
                            Image(systemName: global.bookmark.contains(documentID) ? "bookmark.fill" : "bookmark")
                                .foregroundColor(.blue)
                                .font(.system(size: 50)) // Adjust the size as needed
                            Text("bookmark")
                            
                        }
                    }
                    .accentColor(.white)

                    
                    Spacer()
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .task {
            await loadPost()
        }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { e in
                let pos = min(500 - 1, max(0, Int(e.location.y)))
                if let contactile = contactile {
                    let val = contactile.ext[0].data[pos]
                    if let pv = prevVal {
                        if abs(val - pv) > 0.2 {
                            do {
                                try player.play(intensity: max(1, abs(val - pv) * 1.4))
                            } catch {
                                print("CH error: \(error)")
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
    
    func loadPost() async {
        do {
            post = try await Post.load(documentID)
            if let post = post {
                contactile = try Contactile.fromJSON(post.contactile)
            }
            if let images = post?.images, !images.isEmpty {
                let storage = Storage.storage()
                let url = try await storage.reference().child(images[0]).downloadURL()
                image = getImageByUrl(url: url)
            } else {
                image = nil
            }
        } catch {
            print("Error loading post: \(error.localizedDescription)")
        }
    }
    
    func getImageByUrl(url: URL) -> UIImage {
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data) ?? UIImage()
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            return UIImage()
        }
    }
    
    func date2str(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

