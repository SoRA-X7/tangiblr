//
//  CreatePostView.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/07/29.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import Charts


struct   RecordData{
    let time:Float
    let contactile: Float
}

struct CreatePostView: View {
    @EnvironmentObject var global: AppState
    
    @State var user = ""
    @State var desc = ""
    @State var image: UIImage? = nil
    @State var contactile: Contactile? = nil
    
    @State var showCameraView = false
    @State var showRecSheet = false
    @State var recTime: Float? = nil
    
    @State var isShowAlert = false
    @State var submit_state = 0;
    
    
    
    @State private var record_datas: [RecordData] = [
        
    ]
    
    var body: some View {
        ScrollView {
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
                VStack {
                    Button(action: {
                        showRecSheet = true
                        record_datas = []
                    }) {
                        Text("触覚を記録")
                        
                    }
                }.padding()
                Button(action:{
                    
                    submitPost()
                    isShowAlert.toggle()
                }){
                    Text("Submit")
                }.disabled(user.isEmpty || desc.isEmpty || image == nil || contactile == nil) .alert("Sumbited",isPresented:$isShowAlert,actions: {
                    Button(action: {
                        clear()
                    }){
                        Text("Ok")
                    }
                    
                },                                                                                               message: {
                    Text("正常に送信されました")
                })
                
                
            }.padding().fullScreenCover(isPresented: $showCameraView) {
                CameraView(image: $image).ignoresSafeArea()
                
            }
        }.scrollDismissesKeyboard(.immediately).sheet(isPresented: $showRecSheet) {
            VStack {
                if (global.dev.isConnected()) {
                    if (recTime == nil) {
                        
                        
                        Button(action: record){
                            Text("記録開始")
                                .font(.system(size: 25))
                                .fontWeight(.ultraLight)
                                .foregroundColor(.red)
                                .padding()
                                .border(.red, width: 0.5)
                        }.padding()
                        
                        
                        Text("ボタンを押して5秒間")
                        Text("対象物をなぞり続けてください")
                    } else {
                        
                        Text("計測中...")
                            .fontWeight(.heavy)
                            .foregroundColor(.red)
                        Text("残り \(String(format:"%.2f",5 - (recTime ?? 0)))")
                        Image(systemName: "record.circle.fill").foregroundColor(.red)
                        
                        
                        Chart {
                            ForEach(record_datas, id:\.time ) { record_data in
                                LineMark(
                                    x: .value("time", record_data.time),
                                    y: .value("contactile", record_data.contactile)
                                )
                            }
                        }
                        .frame(width: 300, height: 500)
                    }
                } else {
                    Text("デバイスが接続されていません")
                }
            }
        }
    }
    
    func record() {
        Task {
            recTime = 0;
            defer {
                recTime = nil
            }
            var arr: [Float] = []
            for i in 0..<500 {
                let val = Float(global.dev.getValue() ?? 0) / 4096.0
                arr.append(val)
                
                
                record_datas.append(RecordData(time: recTime ?? 0, contactile: val))
                try await Task.sleep(nanoseconds: 10 * 1000 * 1000) // 100Hz
                recTime = Float(i) / 100.0
            }
            showRecSheet = false
            contactile = Contactile(data1D: arr)
        }
    }
    
    func submitPost() {
        Task {
            guard let contactile = contactile else { return }
            //            let contactile = Contactile(data1D: Array(repeating: 0, count: 5000))
            
            let storage = Storage.storage()
            var imagePath = UUID().uuidString + ".jpg"
            var data = image?.jpegData(compressionQuality: 0.5)
            if data == nil {
                data = image?.pngData()
                imagePath = UUID().uuidString + ".png"
            }
            guard let data = data else { return }
            
            let imageRef = storage.reference().child("images").child(imagePath)
            let _ = try await imageRef.putDataAsync(data)
            
            let imageSavedTo = imageRef.fullPath
            
            let firestore = Firestore.firestore()
            let result = try await firestore.collection("posts").addDocument(data: [
                "user": user,
                "description": desc,
                "images": [
                    imageSavedTo
                ],
                "contactile": contactile.toString(),
                "timestamp":Date()
                
            ])
            print("document added with ID: \(result.documentID)")
        }
        
    }
    
    func clear(){
        user = ""
        desc = ""
        image = nil
        contactile = nil
        showCameraView = false
        showRecSheet = false
        recTime = nil
        isShowAlert = false
        submit_state = 0;
        record_datas = []
    }
    
}




#Preview {
    CreatePostView()
}
