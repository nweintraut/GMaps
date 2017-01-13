//
//  RVLocation.swift
//  GMaps
//
//  Created by Neil Weintraut on 1/11/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import CoreLocation

class RVMyLocation: NSObject {
    private var delegates = [RVMyLocationDelegate]()
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation? = nil
    private var lastHeading: CLHeading? = nil
    private let timeInterval: TimeInterval = 10.0
    private var authorized: Bool = false
    static let sharedInstance: RVMyLocation = {
        let rvLocation = RVMyLocation()
        rvLocation.locationManager.delegate = rvLocation
        rvLocation.locationManager.requestWhenInUseAuthorization()
        return rvLocation
    }()
    func addDelegate(delegate: RVMyLocationDelegate) {
        if let _ = findDelegate(delegate: delegate) {
            // do nothing
        } else {
            delegates.append(delegate)
        }
    }
    func removeDelegate(delegate: RVMyLocationDelegate) {
        for index in (0...delegates.count) {
            if delegates[index].identifier == delegate.identifier {
                delegates.remove(at: index)
                break
            }
        }
    }
    private func findDelegate(delegate: RVMyLocationDelegate) -> RVMyLocationDelegate? {
        for candidate in delegates {
            if delegate.identifier == candidate.identifier { return candidate }
        }
        return nil
    }
    func mostRecentLocation(callback: @escaping(_ location: CLLocation?) -> Void) -> Void {
        if let lastLocation = self.lastLocation {
            if Date().timeIntervalSince1970 - lastLocation.timestamp.timeIntervalSince1970 > timeInterval {
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
                print("In RVLocation.mostRecentLocation, Neil need to address this.")
            } else {
                callback(lastLocation)
                return
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            authorized = true
            locationManager.startUpdatingLocation()
            //locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingHeading()
        } else {
            authorized = false
            locationManager.stopUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location: CLLocation = locations.first {
            //
            lastLocation = location
            print("In RVLocation.didUpdateLocation with \(location)")
            for delegate in delegates {
                delegate.didUpdateLocation(location: location)
            }
            //mapView.camera = GMSCameraPosition(target: location, zoom: 11, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        lastHeading = newHeading
        print("In RVLocation.didUpdateHeading \(newHeading)")
        for delegate in delegates {
            delegate.didUpdateHeading(heading: newHeading)
        }
        locationManager.stopUpdatingHeading()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("In RVLocation.didFailWithError \(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("In RVLocation.didEnterRegion")
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("In RVLocation.didExitRegion")
    }
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("In RVLocation.didPaulLocationUpdates")
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("In RVLocation.didResumeLocationUpdates")
    }
    
}
extension RVMyLocation: CLLocationManagerDelegate {

}
protocol RVMyLocationDelegate: class {
    var identifier: TimeInterval { get }
    func didUpdateLocation(location: CLLocation)-> Void
    func didUpdateHeading(heading: CLHeading) -> Void
}
