//
//  RVLocation.swift
//  GMaps
//
//  Created by Neil Weintraut on 1/11/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

extension RVMyLocation {
    func myPlace(callback: @escaping(_ location: [RVLocation], _ error: RVError?)-> Void) {
        var locations = [RVLocation]()
        if self.authorized {
            placesClient.currentPlace(callback: { (placeLikelihoodList: GMSPlaceLikelihoodList?, error) in

                if let error = error {
                    let rvError = RVError(message: "In \(self.classForCoder).myPlace, got Google error", sourceError: error)
                    callback(locations, rvError)
                    return
                } else if let placeLikelihoodList = placeLikelihoodList {

                    for likelihood: GMSPlaceLikelihood in placeLikelihoodList.likelihoods {
                        let place: GMSPlace = likelihood.place
                      //  print("In \(self.classForCoder).myPlace, likelihood = \(likelihood.likelihood), name = \(place.name), address = \(place.formattedAddress), \(place.coordinate.latitude) \(place.coordinate.longitude), ")
                        locations.append(RVLocation(googlePlace: place))
                    }
                    callback(locations, nil)
                    return 
                } else {
                    callback(locations, nil)
                }
            })
            return
        } else {
            print("-------------------- In \(self.classForCoder).myPlace, not authorized to get location")
            let error = RVError(message: "In \(self.classForCoder).myPlace, not authorized to get location")
            callback(locations, error)
        }
    }
}

class RVMyLocation: NSObject {
    private var delegates = [RVMyLocationDelegate]()
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation? = nil
    private var lastHeading: CLHeading? = nil
    private let timeInterval: TimeInterval = 10.0
    var authorized: Bool = false
    let placesClient = GMSPlacesClient()
    static let sharedInstance: RVMyLocation = {
        let rvLocation = RVMyLocation()
        rvLocation.locationManager.delegate = rvLocation
        //rvLocation.locationManager.requestWhenInUseAuthorization()
        rvLocation.locationManager.requestAlwaysAuthorization()
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
