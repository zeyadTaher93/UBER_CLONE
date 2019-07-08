//
//  UIViewExt.swift
//  Uber_Clone
//
//  Created by zeyad on 6/9/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
extension UIView {
    func fadeTo(alphaValue: CGFloat , with Duration: TimeInterval){
        UIView.animate(withDuration: Duration) {
            self.alpha = alphaValue
        }
    }
    
    func bindToKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    @objc func keyBoardWillChange(_ notification: NSNotification){
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as!NSValue).cgRectValue
        let targFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as!NSValue).cgRectValue
        let deltY = targFrame.origin.y - curFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltY
        }, completion: nil)
        
    }
}
