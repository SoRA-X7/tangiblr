import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import Charts

struct RecordData {
    let time: Float
    let contactile: Float
}

struct CreatePostView: View {
    @EnvironmentObject var global: AppState
    
    @State private var user = ""
    @State private var desc = ""
    @State private var image: UIImage? = nil
    @State private var contactile: Contactile? = nil
    
    @State private var showCameraView = false
    @State private var showRecSheet = false
    @State private var recTime: Float? = nil
    
    @State private var isShowAlert = false
    @State private var submitState = 0
    
    @State private var recordDatas: [RecordData] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("投稿を作成")
                    .font(.headline)
                
                userInputSection
                
                cameraSection
                
                hapticRecordingSection
                
                submitButton
                    .alert("送信されました", isPresented: $isShowAlert) {
                        Button("OK", action: clear)
                    } message: {
                        Text("正常に送信されました")
                    }
            }
            .padding()
            .fullScreenCover(isPresented: $showCameraView) {
                CameraView(image: $image).ignoresSafeArea()
            }
            .sheet(isPresented: $showRecSheet) {
                recordingSheetView
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    private var userInputSection: some View {
        VStack(spacing: 8) {
            CheckmarkTextField(
                placeholder: "User",
                text: $user,
                isValid: !user.isEmpty
            )
            CheckmarkTextField(
                placeholder: "Description",
                text: $desc,
                isValid: !desc.isEmpty
            )
        }
        .padding(.horizontal)
    }
    
    private var cameraSection: some View {
        VStack(spacing: 8) {
            Button("カメラ") {
                showCameraView = true
            }
            
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
            }
        }
        .padding(.horizontal)
    }
    
    private var hapticRecordingSection: some View {
        VStack(spacing: 8) {
            Button("触覚を記録") {
                showRecSheet = true
                recordDatas = []
            }
        }
        .padding(.horizontal)
    }
    
    private var submitButton: some View {
        Button("Submit") {
            submitPost()
            isShowAlert = true
        }
        .disabled(user.isEmpty || desc.isEmpty || image == nil || contactile == nil)
        .padding()
        .background((user.isEmpty || desc.isEmpty || image == nil || contactile == nil) ? Color.gray  :Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
    
    private var recordingSheetView: some View {
        VStack(spacing: 16) {
            if global.dev.isConnected() {
                if recTime == nil {
                    Button("記録開始", action: record)
                        .font(.system(size: 25))
                        .fontWeight(.ultraLight)
                        .foregroundColor(.red)
                        .padding()
                        .border(.red, width: 0.5)
                    
                    Text("ボタンを押して5秒間")
                    Text("対象物をなぞり続けてください")
                } else {
                    Text("計測中...")
                        .fontWeight(.heavy)
                        .foregroundColor(.red)
                    Text("残り \(String(format: "%.2f", 5 - (recTime ?? 0)))")
                    Image(systemName: "record.circle.fill")
                        .foregroundColor(.red)
                    
                    Chart {
                        ForEach(recordDatas, id: \.time) { recordData in
                            LineMark(
                                x: .value("time", recordData.time),
                                y: .value("contactile", recordData.contactile)
                            )
                        }
                    }
                    .frame(width: 300, height: 500)
                }
            } else {
                Text("デバイスが接続されていません")
            }
        }
        .padding()
    }
    
    private func record() {
        Task {
            recTime = 0
            defer { recTime = nil }
            var arr: [Float] = []
            for i in 0..<500 {
                let val = Float(global.dev.getValue() ?? 0) / 4096.0
                arr.append(val)
                recordDatas.append(RecordData(time: recTime ?? 0, contactile: val))
                try await Task.sleep(nanoseconds: 10 * 1000 * 1000) // 100Hz
                recTime = Float(i) / 100.0
            }
            showRecSheet = false
            contactile = Contactile(data1D: arr)
        }
    }
    
    private func submitPost() {
        Task {
            guard let contactile = contactile else { return }
            
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
            
            let firestore = Firestore.firestore()
            let result = try await firestore.collection("posts").addDocument(data: [
                "user": user,
                "description": desc,
                "images": [imageRef.fullPath],
                "contactile": contactile.toString(),
                "timestamp": Date()
            ])
            print("Document added with ID: \(result.documentID)")
        }
    }
    
    private func clear() {
        user = ""
        desc = ""
        image = nil
        contactile = nil
        showCameraView = false
        showRecSheet = false
        recTime = nil
        isShowAlert = false
        submitState = 0
        recordDatas = []
    }
}

struct CheckmarkTextField: View {
    let placeholder: String
    @Binding var text: String
    let isValid: Bool
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
            if isValid {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
}

#Preview {
    CreatePostView()
}

