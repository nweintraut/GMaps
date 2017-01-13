//
//  RVError.swift
//  GMaps
//
//  Created by Neil Weintraut on 1/13/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVError: Error {
    var sourceError: Error?
    var message: String = ""
    init(message: String = "", sourceError: Error? = nil) {
        self.sourceError = sourceError
        self.message = message
    }
}
