//
//  CreatePostView.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/07/29.
//

import SwiftUI
import FirebaseFirestore
struct CreatePostView: View {
    @State var user = ""
    @State var desc = ""
    @State var image: UIImage? = nil
    
    @State var showCameraView = false
    
    
    var body: some View {
        VStack {
            Text("投稿を作成")
            VStack {
            TextField("User", text: $user).textFieldStyle(.roundedBorder)
                TextField("Description", text: $desc).textFieldStyle(.roundedBorder)}.padding()
            VStack {
                Button(action: {
                    showCameraView = true
                }) {
                    Text("カメラ")
                }
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                }
            }.padding()
            Button(action: submitPost) {
                Text("Submit")
            }
        }.padding().fullScreenCover(isPresented: $showCameraView) {
            CameraView(image: $image).ignoresSafeArea()
        }
    }
    
    func submitPost() {
        Task {
            let firestore = Firestore.firestore()
            let result = try await firestore.collection("posts").addDocument(data: [
                "user": $user.wrappedValue,
                "description": $desc.wrappedValue
            ])
            print("document added with ID: \(result.documentID)")
        }
        
    }

}

#Preview {
    CreatePostView()
}
