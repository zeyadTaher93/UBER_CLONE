//
//  UIViewControllerExt.swift
//  Uber_Clone
//
//  Created by zeyad on 6/21/19.
//  Copyright © 2019 zeyad. All rights reserved.
//


import UIKit
extension UIViewController {
    
    func shouldPresrntLoadingView(_ status: Bool){
        var fadeView :UIView?
        if status{
            fadeView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            fadeView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            fadeView?.alpha = 0.0
            fadeView?.tag = 99
            
            let spinner = UIActivityIndicatorView()
            spinner.color = .white
            spinner.style = .whiteLarge
            
            view.addSubview(fadeView!)
            fadeView?.addSubview(spinner)
            spinner.center = view.center
            spinner.startAnimating()
            
            fadeView?.fadeTo(alphaValue: 0.7, with: 0.2)
            
        }else{
            for subview in view.subviews {
                if subview.tag == 99 {
                    UIView.animate(withDuration: 0.2, animations: {
                        subview.alpha = 0.0
                    }) { (finished) in
                        if finished{
                            subview.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
}
