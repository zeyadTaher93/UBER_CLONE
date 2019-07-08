//
//  RoundedImageView.swift
//  Uber_Clone
//
//  Created by zeyad on 5/31/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {

    override func awakeFromNib() {
        setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }

}
