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
}
