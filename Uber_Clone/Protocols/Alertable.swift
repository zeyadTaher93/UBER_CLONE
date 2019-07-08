//
//  Alertable.swift
//  Uber_Clone
//
//  Created by zeyad on 6/21/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
protocol Alertable {
}
extension Alertable where Self:UIViewController {
    func showAlert(_ msg: String){
        let alertController = UIAlertController(title: "error", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
}
