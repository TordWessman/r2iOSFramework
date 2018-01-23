//
//  GardenController+Extensions.swift
//  GardenController
//
//  Created by Tord Wessman on 29/07/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var moistValue:CGFloat {
        get {
            return Int(self)!.moistValue
        }
    }
}

extension Int {
    var moistValue:CGFloat {
        get {
            _ =  ((1100 - CGFloat(self)) / 10) - 50.0
            
            return CGFloat(self) //(val < 0 ? 1 : val) * 3.0
        }
    }
}
