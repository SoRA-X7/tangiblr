import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ItemView: View {
    var documentID: String
    
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
            do {
                post = try await Post.load(documentID)
                if let post = post {
                    contactile = try Contactile.fromJSON(post.contactile)
                }
                
                guard let images = post?.images else {
                    image = nil
                    return
                }
                
                let storage = Storage.storage()
                let storageRef = storage.reference().child(images[0])
                
                storageRef.downloadURL { url, error in
                    if let url = url {
                        loadImageAsync(from: url)
                    } else if let error = error {
                        print("Error fetching image URL: \(error.localizedDescription)")
                    }
                }
            } catch {
                print("Error loading post: \(error.localizedDescription)")
            }
        }
    }
    
    func loadImageAsync(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            } else if let error = error {
                print("Error loading image: \(error.localizedDescription)")
            }
        }.resume()
    }
}

//#Preview {
//    ItemView(documentID: <#String#>)
//}

