//
//  RVLocation.swift
//  GMaps
//
//  Created by Neil Weintraut on 1/12/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import CoreLocation
class RVLocation: RVBaseModel {
    override class var absoluteModelType: RVModelType { return RVModelType.Image }
    private var rawPlaces = [String: AnyObject]()
    init(rawPlaces: [String: AnyObject]) {
        super.init()
        self.modelType = RVLocation.absoluteModelType
        print("In RVLocation, Neil, need to create id creationg")
        absorbPlaces(rawPlaces: rawPlaces)
        print("IN RVLocation, need to create ID create for rawPlaces init")
    }
    private func absorbPlaces(rawPlaces: [String: AnyObject]) {
        self.rawPlaces = rawPlaces
        if let geometry = rawPlaces[RVGooglePlace.Keys.geometry.rawValue] as? [String : AnyObject] {
            if let location = geometry[RVGooglePlace.Keys.location.rawValue] as? [String : NSNumber] {
                if let latitude = location[RVGooglePlace.Keys.lat.rawValue] {
                    if let longitude = location[RVGooglePlace.Keys.lng.rawValue] {
                        self.latitude = latitude.doubleValue
                        self.longitude = longitude.doubleValue
                    }
                }
            }
        }
        if let string = rawPlaces[RVGooglePlace.Keys.reference.rawValue] as? String { self.reference = string }
        if let string = rawPlaces[RVGooglePlace.Keys.icon.rawValue] as? String {
            if let url = URL(string: string) { self.iconURL = url }
        }
        if let string = rawPlaces[RVGooglePlace.Keys.vicinity.rawValue] as? String { self.address = string }
        if let string = rawPlaces[RVGooglePlace.Keys.name.rawValue] as? String { self.title = string }
        if let string = rawPlaces[RVGooglePlace.Keys.place_id.rawValue] as? String { self.place_id = string }
        if let string = rawPlaces[RVGooglePlace.Keys.id.rawValue] as? String { self.record_id = string }
        if let types = rawPlaces[RVGooglePlace.Keys.types.rawValue] as? [String] { self.types = types }
        if let photos = rawPlaces[RVGooglePlace.Keys.photos.rawValue] as? [[String : AnyObject]] {
            if let photo = photos.first {
                print("---------- In RVLocation.absorbPlaces..... have photo 8888888888")
                let image = RVImage()
                if let height = photo[RVGooglePlace.Keys.height.rawValue] as? NSNumber { image.height = CGFloat(height.doubleValue) }
                if let width = photo[RVGooglePlace.Keys.width.rawValue] as? NSNumber { image.width = CGFloat(width.doubleValue) }
                if let string = photo[RVGooglePlace.Keys.photo_reference.rawValue] as? String { image.photo_reference = string }
                self.image = image
            } else {

            }
        }
        
        self.dirties = [String: AnyObject]()
        
    }
    var coordinate: CLLocationCoordinate2D? {
        get {
            if let latitude = self.latitude {
                if let longitude = self.longitude {
                    return CLLocationCoordinate2DMake(latitude , longitude)
                }
            }
            return nil
        }
        set {
            if let coordinate = newValue {
                self.latitude = coordinate.latitude
                self.longitude = coordinate.longitude
            } else {
                self.latitude = nil
                self.longitude = nil
            }
        }
    }
    var latitude: CLLocationDegrees? {
        get { return getNSNumber(key: .latitude) as? CLLocationDegrees }
        set {
            if let value = newValue {
                updateNumber(key: .latitude, value: NSNumber(value: Double(value)) , setDirties: true)
            } else {
                updateNumber(key: .latitude, value: nil , setDirties: true)
            }
        }
    }
    var longitude: CLLocationDegrees? {
        get { return getNSNumber(key: .longitude) as? CLLocationDegrees }
        set {
            if let value = newValue {
                updateNumber(key: .longitude, value: NSNumber(value: Double(value)) , setDirties: true)
            } else {
                updateNumber(key: .longitude, value: nil , setDirties: true)
            }
        }
    }
    var address: String? {
        get { return getString(key: .address) }
        set { updateString(key: .address, value: newValue, setDirties: true)}
    }
    var place_id: String? {
        get { return getString(key: .place_id) }
        set { updateString(key: .place_id, value: newValue, setDirties: true)}
    }

    var record_id: String? {
        get { return getString(key: .record_id) }
        set { updateString(key: .record_id, value: newValue, setDirties: true)}
    }
    var reference: String? {
        get { return getString(key: .reference) }
        set { updateString(key: .reference, value: newValue, setDirties: true)}
    }
    var iconURL: URL? {
        get {
            if let raw = getString(key: .iconURL) {
                return URL(string: raw)
            } else {
                return nil
            }
        
        }
        set {
            if let url = newValue {
                updateString(key: .iconURL, value: url.absoluteString, setDirties: true)
            } else {
                updateString(key: .iconURL, value: nil, setDirties: true)
            }
            
        }
    }
    var types: [String]? {
        get {
            if let array = objects[RVKeys.types.rawValue] as? [String] { return array }
            return nil
        }
        set {
            updateAnyObject(key: .types, value: newValue as AnyObject , setDirties: true)
        }
    }
    func toString() -> String {
        var output = ""
        if let value = self.title {
            output = "\(output) Title = \(value), "
        } else {
            output = "\(output) <no title>, "
        }
        if let value = self.address {
            output = "\(output) address = \(value), "
        } else {
            output = "\(output) <no address>, "
        }
        if let latitude = self.latitude {
            output = "\(output) Latitude = \(latitude), "
        } else {
            output = "\(output) <no latitude>, "
        }
        if let value = self.longitude {
            output = "\(output) Longitude = \(value), "
        } else {
            output = "\(output) <no longitude>,"
        }
        
        if let value = self.iconURL {
            output = "\(output) IconURL = \(value.absoluteString), "
        } else {
            output = "\(output) <no iconURL>\n"
        }
        if let image = self.image {
            output = "\(output) -- ImageObject: \(image.toString())"
        } else {
            output = "\(output) < no image>"
        }
        return output
    }
}




