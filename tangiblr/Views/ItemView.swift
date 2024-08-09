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
        VStack(alignment: .leading, spacing: 10) {
            if let post = post {
                
                Text(post.user)
                    .font(.headline)
                    .foregroundColor(.white)
                
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .clipped()
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
            } else {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(Color.gray)
        .cornerRadius(15)
        .shadow(radius: 5)
        .task {
            loadData()
        }
    }
    
    func loadData() {
        Task {
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

#Preview {
    ItemView(documentID: "sampleID")
}

