//
//  DriverAnnotation.swift
//  Uber_Clone
//
//  Created by zeyad on 6/15/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import MapKit

class DriverAnnotation: NSObject , MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(withCoordinate coordinate: CLLocationCoordinate2D , key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
    
    func update(AnnotationLocation annotation: DriverAnnotation , withCoordinate coordainate: CLLocationCoordinate2D){
        var location = self.coordinate
        location.latitude = coordainate.latitude
        location.longitude = coordainate.longitude
        UIView.animate(withDuration: 0.2) {
            self.coordinate = location
        }
        
    }
    

}
