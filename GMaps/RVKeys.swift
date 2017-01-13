//
//  RVKeys.swift
//  GMaps
//
//  Created by Neil Weintraut on 1/12/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
enum RVKeys: String {
    case modelType = "modelType"
    case _id = "_id"
    case title = "title"
    case createdAt = "createdAt"
    case updatedAt = "updatedAt"
    case image = "image"

    
    // Image
    case height = "height"
    case width = "width"
    case photo_reference = "photo_reference"
    case url = "url"
    
    // location
    case latitude = "latitude"
    case longitude = "longitude"
    case address   = "address"
    case reference = "reference"
    case iconURL = "iconURL"
    case record_id = "record_id"
    case place_id = "place_id"
    case types = "types"
}