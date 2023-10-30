import Foundation
import UIKit
import MapKit

class IdahMapViewController: UIViewController {
    
    private var mapView: MKMapView = MKMapView()

    var targetStoreName: String = ""

    private var centerLocation: CLLocationCoordinate2D
    
    init(targetLatitude: Double, targetLontitude: Double) {
        self.centerLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(targetLatitude), longitude: targetLontitude)
        super.init(nibName: nil, bundle: nil)
        mapView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBarRightButton()
        mapView.frame = self.view.bounds
        view.addSubview(mapView)

        guard CLLocationCoordinate2DIsValid(self.centerLocation) else {
            IdahProgressHUD.show(style: .showError("坐标无效"))
            return
        }

        self.mapView.region = MKCoordinateRegion(center: self.centerLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.addAnnotationToMap(coordinate: self.centerLocation, title: self.targetStoreName, subtitle: "")
    }
    
    func setUpNavBarRightButton() {
        let rightButton = UIButton()
        rightButton.setTitle("导航", for: .normal)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        rightButton.setTitleColor(.blue, for: .normal)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        let rightButtonbarItem = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightButtonbarItem
    }
    
    @objc func rightButtonTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "高德地图", style: .default) { _ in
            self.openGaodeMap(latitude: self.centerLocation.latitude, longitude: self.centerLocation.longitude, name: self.targetStoreName)
        })
        alertController.addAction(UIAlertAction(title: "苹果地图", style: .default) { _ in
            self.openMapWithLocation(latitude: self.centerLocation.latitude, longitude: self.centerLocation.longitude, name: self.targetStoreName)
        })
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func addAnnotationToMap(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        annotation.title = title
        annotation.subtitle = subtitle
        mapView.addAnnotation(annotation)
    }
    
    // 设置地图可视区域
    func setMapVisibleRegion(currentCoordinate: CLLocationCoordinate2D, annotationCoordinate: CLLocationCoordinate2D) {
        let mapPadding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50) // 地图边界内边距
        
        var zoomRect = MKMapRect.null
        let pointRect = MKMapRect(origin: MKMapPoint(annotationCoordinate), size: MKMapSize(width: 0, height: 0))
        let currentRect = MKMapRect(origin: MKMapPoint(currentCoordinate), size: MKMapSize(width: 0, height: 0))
        
        zoomRect = zoomRect.union(pointRect)
        zoomRect = zoomRect.union(currentRect)
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: mapPadding, animated: true)
    }
    
    // 打开高德地图
    func openGaodeMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String) {
        UIApplication.shared.open(URL(string: "iosamap://viewMap?sourceApplication=\("PMM")&poiname=\(targetStoreName)&lat=\(latitude)&lon=\(longitude)&dev=0")!)
    }
    
    // 打开自带地图
    func openMapWithLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        
        mapItem.openInMaps(launchOptions: nil)
    }
}

extension IdahMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseIdentifier = "markerAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}
