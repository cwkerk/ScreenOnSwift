//
//  CoreLocationManager.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 3/7/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import Foundation
import CoreLocation

class CoreLocationManager: NSObject {
    
    static let shared = CoreLocationManager()
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        return locationManager
    }()
    
    var location: CLLocation?
    
    private override init() {
        super.init()
        locationManager.requestWhenInUseAuthorization()
    }
    
}

extension CoreLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
                break
            default:
                break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last
    }
    
}
