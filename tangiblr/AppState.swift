import Foundation


class AppState: ObservableObject {
    @Published var dev = SensorDeviceManager()
}
