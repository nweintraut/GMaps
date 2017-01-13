//
//  RVImage.swift
//  GMaps
//
//  Created by Neil Weintraut on 1/12/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVImage: RVBaseModel {
    override class var absoluteModelType: RVModelType { return RVModelType.Image }
    var uiImage: UIImage?
    override init() {
        super.init()
        self.modelType = RVImage.absoluteModelType
    }
    override init(objects: [String: AnyObject], id: String? = nil) {
        super.init(objects: objects , id: id)
    }
    var height: CGFloat? {
        get { return getNSNumber(key: .height) as CGFloat? }
        set { updateNumber(key: .height, value: newValue as NSNumber?, setDirties: true)}
    }
    var width: CGFloat? {
        get { return getNSNumber(key: .width) as CGFloat? }
        set { updateNumber(key: .width, value: newValue as NSNumber?, setDirties: true)}
    }
    var photo_reference: String? {
        get { return getString(key: .photo_reference) }
        set { updateString(key: .photo_reference, value: newValue, setDirties: true)}
    }
    var url: URL? {
        get {
            if let raw = getString(key: .url) {
                return URL(string: raw)
            } else {
                return nil
            }
            
        }
        set {
            if let url = newValue {
                updateString(key: .url, value: url.absoluteString, setDirties: true)
            } else {
                updateString(key: .url, value: nil, setDirties: true)
            }
            
        }
    }
    func toString() -> String {
        var output = ""
        if let value = self.height {
            output = "\(output) height = \(value), "
        } else {
            output = "\(output) <no height>, "
        }
        if let value = self.width {
            output = "\(output) width = \(value)"
        } else {
            output = "\(output) <no width>, "
        }
        if let value = self.photo_reference {
            output = "\(output) Photo_reference = \(value), "
        } else {
            output = "\(output) <no photo_reference>\n"
        }
        return output
    }
}
