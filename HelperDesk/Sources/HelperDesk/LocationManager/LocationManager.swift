import Foundation
import UIKit
import Combine
import CoreLocation

class LocationManager: NSObject {

    enum LocationError: Error {
        case accessDenied

        var localizedDescription: String {
            switch self {
            case .accessDenied: return "无定位权限"
            }
        }
    }
    
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    var onLocationUpdate: ((CLLocation, String?) -> Void)?

    private var oneTimeLocationPublisher: PassthroughSubject<CLLocation, Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 3
    }
    
    public func requestLocation() {
        AuthorizationManager.shared.requestLocationAccess { permision in
            if permision {
                self.locationManager.requestLocation()
                self.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    public func startUpdateingLocation() {
        AuthorizationManager.shared.requestLocationAccess { permision in
            if permision {
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    public func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    
    public func distanceBettwen(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        return from.distance(from: to)
    }

    public func getOneTimeLocation() -> AnyPublisher<CLLocation, Error> {
        let oneTimeLocationPublisher = PassthroughSubject<CLLocation, Error>()
        self.oneTimeLocationPublisher = oneTimeLocationPublisher

        AuthorizationManager.shared.requestLocationAccess { permision in
            if permision {
                self.locationManager.stopUpdatingLocation()
                self.locationManager.requestLocation()
            } else {
                oneTimeLocationPublisher.send(completion: .failure(LocationError.accessDenied))
            }
        }

        return oneTimeLocationPublisher.eraseToAnyPublisher()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        if let oneTimeLocationPublisher = self.oneTimeLocationPublisher {
            oneTimeLocationPublisher.send(location)
            oneTimeLocationPublisher.send(completion: .finished)
            self.oneTimeLocationPublisher = nil
        }

        getAddressFromLocation(location) { address in
            self.onLocationUpdate?(location, address)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)

        if let oneTimeLocationPublisher = self.oneTimeLocationPublisher {
            oneTimeLocationPublisher.send(completion: .failure(error))
            self.oneTimeLocationPublisher = nil
        }
    }
    
    func getAddressFromLocation(_ location: CLLocation, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemark found")
                completion(nil)
                return
            }
            let addressDictionary = placemark.addressDictionary ?? ["":""]
            
            var addressComponents: [String] = []
            
            if let administrativeArea = placemark.administrativeArea {
                addressComponents.append(administrativeArea)
            }
            
            if let locality = placemark.locality {
                addressComponents.append(locality)
            }
            
            if let subLocality = placemark.subLocality {
                addressComponents.append(subLocality)
            }
            
            if let thoroughfare = addressDictionary["Street"] {
                addressComponents.append(thoroughfare as? String ?? "")
            }
            
            let address = addressComponents.joined(separator: "")
            completion(address)
        }
    }
}
