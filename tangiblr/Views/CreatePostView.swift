import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import Charts
import CoreLocation

struct RecordData {
    let time: Float
    let contactile: Float
}

struct CreatePostView: View {
    @EnvironmentObject var global: AppState
    
    @State private var user = ""
    @State private var desc = ""
    @State private var city = ""
    @State private var image: UIImage? = nil
    @State private var contactile: Contactile? = nil
    
    @State private var showCameraView = false
    @State private var showRecSheet = false
    @State private var recTime: Float? = nil
    
    @State private var isShowAlert = false
    @State private var submitState = 0
    
    @State private var recordDatas: [RecordData] = []
    
    @StateObject private var locationManager = LocationManager()
    
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
                        Button("OK", action: {})
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
            .onAppear {
                locationManager.requestLocation()
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
                isValid: true
            )
            CheckmarkTextField(placeholder: "Location", text: $city, isValid: !city.isEmpty)
        }
        .padding(.horizontal)
        .onChange(of: locationManager.city) { newState in
            city = newState ?? ""
        }
        .onChange(of: global.auth.user) { newState in
            user = newState?.uid ?? ""
        }
        .onAppear {
            city = locationManager.city ?? ""
            user = global.auth.user?.uid ?? ""
        }
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
        .disabled(user.isEmpty || image == nil || contactile == nil)
        .padding()
        .background((user.isEmpty || image == nil || contactile == nil) ? Color.gray : Color.blue)
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
            global.dev.start()
            defer {
                recTime = nil
                global.dev.stop()
            }
            var arr: [Float] = []
            var prevValue: Int32 = 0
            for i in 0..<500 {
                var values = global.dev.getValues() ?? []
                if values.isEmpty {
                    values.append(prevValue)
                }
                let sum = values.reduce(0, +)
                let val = Float(sum) / Float(values.count)
                print(val / 4096.0)
                arr.append(val / 4096.0)
                prevValue = Int32(val)
                recordDatas.append(RecordData(time: recTime ?? 0, contactile: val / 4096.0))
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
                "timestamp": Date(),
                "city": city
            ])
            print("Document added with ID: \(result.documentID)")
            clear()
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

