import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var error: Error?
    @Published var city: String?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        requestLocation()
    }

    public func requestLocation() {
        Task {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestLocation()
            }
        }
    }
    
    private func getGeoInfo(_ location: CLLocation) {
        var url = URL(string: "https://geoapi.heartrails.com/api/json")!
        url.append(queryItems: [
            URLQueryItem(name: "method", value: "searchByGeoLocation"),
            URLQueryItem(name: "x", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "y", value: String(location.coordinate.latitude))
        ])
        print(url.absoluteString)
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
            guard let data = data else { return }
            do {
                let locationResponse = try JSONDecoder().decode(LocationResponse.self, from: data)
                Task.detached { @MainActor in
                    if let loc = locationResponse.response.location.first {
                        self.city = loc.prefecture + loc.city + loc.town
                    }
//                    print(self.city)
                }
                
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }

    // 位置情報が更新された時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        if let location = location {
            getGeoInfo(location)
        }
    }

    // 位置情報の取得に失敗した時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }

    // JSONデータの構造に対応する構造体を定義
    struct LocationResponse: Codable {
        let response: Response
    }

    struct Response: Codable {
        let location: [Location]
    }

    struct Location: Codable {
        let city: String
        let cityKana: String
        let town: String
        let townKana: String
        let x: String
        let y: String
        let distance: Double
        let prefecture: String
        let postal: String

        // プロパティ名とJSONキーが異なる場合、CodingKeysを使用
        enum CodingKeys: String, CodingKey {
            case city
            case cityKana = "city_kana"
            case town
            case townKana = "town_kana"
            case x
            case y
            case distance
            case prefecture
            case postal
        }
    }
}
