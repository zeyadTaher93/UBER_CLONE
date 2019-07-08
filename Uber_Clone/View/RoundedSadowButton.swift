//
//  RoundedSadowButton.swift
//  Uber_Clone
//
//  Created by zeyad on 5/31/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit

class RoundedSadowButton: UIButton {

    var originalSize: CGRect?
    
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView(){
        originalSize = self.frame
        self.layer.cornerRadius = 10.0
        self.layer.shadowOpacity = 3.0
        self.layer.shadowRadius = 5
        self.layer.shadowColor = UIColor.darkGray.cgColor
        
    }
    
    func animateButton(shouldLoad: Bool , withMessage message : String?){
        let spinner = UIActivityIndicatorView()
        spinner.style = .whiteLarge
        spinner.alpha = 0.0
        spinner.color = UIColor.darkGray
        spinner.hidesWhenStopped = true
        spinner.tag = 22
        
        if shouldLoad {
            self.setTitle("", for: .normal)
            UIView.animate(withDuration: 0.2, animations: {
                self.frame = CGRect(x: self.frame.midX - (self.frame.height/2), y: self.frame.midY - (self.frame.height/2), width: self.frame.height, height: self.frame.height)
                self.layer.cornerRadius = self.frame.height / 2
            }) { (finished) in
                if finished {
                    self.addSubview(spinner)
                    spinner.startAnimating()
                    spinner.center = CGPoint(x: (self.frame.width / 2)+1, y: self.frame.midY + 1)
                    spinner.fadeTo(alphaValue: 1.0, with: 0.2)
//                    UIView.animate(withDuration: 0.2, animations: {
//                        spinner.alpha = 1.0
//                    })
                    
                }
            }
            self.isUserInteractionEnabled = false
        }else{
            self.isUserInteractionEnabled = true
            for subView in self.subviews {
                if subView.tag == 22 {
                    subView.removeFromSuperview()
                }
                UIView.animate(withDuration: 0.2) {
                    self.layer.cornerRadius = 5.0
                    self.frame = self.originalSize!
                    self.setTitle(message, for: .normal)
                }
               
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
