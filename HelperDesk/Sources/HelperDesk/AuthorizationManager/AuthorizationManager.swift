import UIKit
import AVFoundation
import Photos
import CoreLocation

final class AuthorizationManager: NSObject {

    static let shared = AuthorizationManager()

    private var locationRequestCallback: ((Bool) -> Void)?

    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()

    func requestCameraAccess(completion: @escaping ((Bool) -> Void)) {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (result) in
                completion(result)
            }
        default:
            completion(false)
        }
    }
    
    func requestLocationAccess(completion: @escaping ((Bool) -> Void)) {
        switch locationManager.authorizationStatus {
            case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationRequestCallback = completion
            case .restricted:
                completion(false)
            case .denied:
                completion(false)
            case .authorizedAlways:
                completion(true)
            case .authorizedWhenInUse:
                completion(true)
            @unknown default:
                completion(false)
        }
    }

    func requestAudioAccess(completion: @escaping ((Bool) -> Void)) {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { (result) in
                completion(result)
            }
        default:
            completion(false)
        }
    }

    func requestPhotoAccess(completion: @escaping ((Bool) -> Void)) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == PHAuthorizationStatus.authorized {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        default:
            completion(false)
        }
    }
}

extension AuthorizationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else {
            return
        }

        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            locationRequestCallback?(true)
        } else {
            locationRequestCallback?(false)
        }
        locationRequestCallback = nil
    }
}
