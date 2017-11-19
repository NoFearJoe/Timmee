//
//  TaskLocationEditor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import MapKit

protocol TaskLocationEditorInput: class {
    func setLocation(_ location: CLLocation)
}

protocol TaskLocationEditorOutput: class {
    func didSelectLocation(_ location: CLLocation)
}

final class TaskLocationEditor: UIViewController {

    @IBOutlet fileprivate weak var mapView: MKMapView!
    @IBOutlet fileprivate weak var errorPlaceholder: UIView!
    
    weak var output: TaskLocationEditorOutput?
    
    fileprivate let locationManager = CLLocationManager()
    
    fileprivate var isLocationSet = false
    
    fileprivate var placemark: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.layer.masksToBounds = true
        
        addTapGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAuthorization()
    }

}

extension TaskLocationEditor: TaskLocationEditorInput {

    func setLocation(_ location: CLLocation) {
        if !isLocationSet {
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
            mapView.setRegion(region, animated: true)
        } else {
            var region = mapView.region
            region.center = location.coordinate
            mapView.setRegion(region, animated: true)
        }
        
        isLocationSet = true
        
        if let placemark = placemark {
            mapView.removeAnnotation(placemark)
        }
        placemark = MKPointAnnotation()
        placemark!.coordinate = location.coordinate
        mapView.addAnnotation(placemark!)
    }

}

extension TaskLocationEditor: MKMapViewDelegate {

    

}

extension TaskLocationEditor: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            setErrorPlaceholderVisible(false)
            mapView.showsUserLocation = true
            
            if let location = manager.location {
                if !isLocationSet {
                    setLocation(location)
                    output?.didSelectLocation(location)
                }
            }
        default:
            setErrorPlaceholderVisible(true)
        }
    }

}

extension TaskLocationEditor: TaskParameterEditorInput {
    
    var requiredHeight: CGFloat {
        return UIScreen.main.bounds.height - 64
    }
    
}

fileprivate extension TaskLocationEditor {

    func checkAuthorization() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            if let location = locationManager.location {
                if !isLocationSet {
                    setLocation(location)
                    output?.didSelectLocation(location)
                }
            }
        } else {
            setErrorPlaceholderVisible(true)
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func setErrorPlaceholderVisible(_ isVisible: Bool) {
        errorPlaceholder.isHidden = !isVisible
    }
    
    func addTapGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTapToMap(recognizer:)))
        mapView.addGestureRecognizer(recognizer)
    }
    
    @objc func onTapToMap(recognizer: UITapGestureRecognizer) {
        let touchLocation = recognizer.location(in: mapView)
        let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        mapView.setCenter(coordinate, animated: true)
        
        let location = CLLocation(coordinate: coordinate,
                                  altitude: 0,
                                  horizontalAccuracy: 0,
                                  verticalAccuracy: 0,
                                  course: 0,
                                  speed: 0,
                                  timestamp: Date())
        setLocation(location)
        output?.didSelectLocation(location)
    }

}
