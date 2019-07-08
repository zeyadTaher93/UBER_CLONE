//
//  UserAnnotation.swift
//  Uber_Clone
//
//  Created by zeyad on 6/20/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import Foundation
import MapKit
class PassengerAnnotation: NSObject , MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(coordinate: CLLocationCoordinate2D , key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
}
