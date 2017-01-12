//
//  RVGeocoder.swift
//  GMaps
//
//  Created by Neil Weintraut on 1/11/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import GoogleMaps
class RVGeocoder: GMSGeocoder {
    static var sharedInstance: RVGeocoder = {
        return RVGeocoder()
    }()
    
    func RVReverseGeocodeCoorindate(coordinate: CLLocationCoordinate2D, callback: @escaping(_ response: [GMSAddress], _ error: RVError?) -> Void) {
        super.reverseGeocodeCoordinate(coordinate) { (response: GMSReverseGeocodeResponse?, error: Error?) in
            if let error = error {
                let rvError = RVError(message: "In \(self.classForCoder).got GMaps error", sourceError: error)
                callback([GMSAddress](), rvError)
                return
            } else if let response = response {
                if let results: [GMSAddress] = response.results() {
                    if let address: GMSAddress = results.first {
                        if let lines: [String] = address.lines {
                            if lines.count > 1 {
                                // lines[1] // City, State, Zip
                            }
                        }
                    }
                    callback(results, nil)
                    return
                }
                callback([GMSAddress](), nil)
            } else {
                callback([GMSAddress](), nil)
            }
        }
    }
}
