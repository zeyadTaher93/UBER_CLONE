//
//  RoundedMapView.swift
//  Uber_Clone
//
//  Created by zeyad on 6/22/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import MapKit

class RoundedMapView: MKMapView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.layer.borderWidth = 10.0
        self.clipsToBounds = true
    }
}
