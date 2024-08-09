import Foundation


class AppState: ObservableObject {
    @Published var dev = SensorDeviceManager()
    @Published var bookmark:[String] = (UserDefaults.standard.array(forKey: "bookmark") ?? []) as! [String]
}
