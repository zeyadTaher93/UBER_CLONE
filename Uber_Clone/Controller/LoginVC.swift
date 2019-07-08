//
//  LoginVC.swift
//  Uber_Clone
//
//  Created by zeyad on 6/9/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import Firebase
class LoginVC: UIViewController ,Alertable {

    @IBOutlet weak var emailTxt: RoundedCornerTextField!
    @IBOutlet weak var passwordTxt: RoundedCornerTextField!
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var authBtn: RoundedSadowButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bindToKeyboard()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func authBtnPressed(_ sender: Any) {
        if emailTxt.text != nil && passwordTxt.text != nil {
            //authBtn.isEnabled = true
            authBtn.animateButton(shouldLoad: true, withMessage: nil)
            if let email = emailTxt.text , let password = passwordTxt.text {
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if error == nil {
                        if let user = user {
                            if self.segmented.selectedSegmentIndex == 0 {
                                let UserData = ["provider": user.additionalUserInfo!.providerID] as [String : Any]
                                DataService.instance.createUser(uid: user.user.uid , userData: UserData, isDriver: false)
                            }else{
                                let UserData = ["provider": user.additionalUserInfo!.providerID , "userIsDriver": true , "isPickUpEnabled": false , "driverOnTrip": false] as [String : Any]
                                DataService.instance.createUser(uid: user.user.uid , userData: UserData, isDriver: true)
                            }
                        }
                        self.dismiss(animated: true, completion: nil)
                        print("succesfully signed in")
                    }else {
                        if let errorCode = AuthErrorCode(rawValue: error!._code){
                            switch errorCode {
                            case .wrongPassword:
                                self.showAlert("wrong password")
                            default:
                                self.showAlert("unexpected error please try again")
                            }
                        }
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                if let errorCode = AuthErrorCode(rawValue: error!._code){
                                    switch errorCode {
                                    case .invalidEmail:
                                        self.showAlert("Invaild email")
                                        
                                    default:
                                        self.showAlert("unexpected error please try again")
                                        
                                    }
                                }
                            }else{
                                if let user = user {
                                    if self.segmented.selectedSegmentIndex == 0 {
                                        let userData = ["provider":user.additionalUserInfo!.providerID] as [String:Any]
                                        DataService.instance.createUser(uid: user.user.uid, userData: userData, isDriver: false)
                                    }else{
                                        let userData = ["provider":user.additionalUserInfo!.providerID ,"userIsDriver": true , "isPickUpEnabled": false , "driverOnTrip": false] as [String : Any]
                                        DataService.instance.createUser(uid: user.user.uid , userData: userData, isDriver: true)
                                    }
                                }
                                print("created new user successfully")
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    }
                }
            }
            
            
        }
    }
    
}
