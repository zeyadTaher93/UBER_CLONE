//
//  gradiantView.swift
//  Uber_Clone
//
//  Created by zeyad on 5/30/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit

class gradiantView: UIView {

    let gradiantLayer = CAGradientLayer()
   

    
    
    override func awakeFromNib() {
        setupGradientLayer()

    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradiantLayer.frame = self.bounds
    }
    
    func setupGradientLayer() {
        gradiantLayer.frame = self.bounds
        gradiantLayer.colors = [UIColor.white.cgColor , UIColor.init(white: 1.0, alpha: 0.0).cgColor]
        gradiantLayer.startPoint = CGPoint.zero
        gradiantLayer.endPoint = CGPoint(x: 0, y: 1)
        gradiantLayer.locations = [0.8 , 1.0]
        self.layer.addSublayer(gradiantLayer)
        
    }
    
}
