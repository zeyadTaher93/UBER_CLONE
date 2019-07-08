//
//  RoundedCornerTextField.swift
//  Uber_Clone
//
//  Created by zeyad on 6/9/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit

class RoundedCornerTextField: UITextField {
    var textOffset: CGFloat = 20
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = (self.frame.height / 2)
        self.clipsToBounds = true
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0 + textOffset , y: 0 + (textOffset / 2), width: self.frame.width - textOffset, height: self.frame.height - textOffset )
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0 + textOffset , y: 0 + (textOffset / 4), width: self.frame.width - textOffset, height: self.frame.height - textOffset )
    }

}
