//
//  SideMenu.swift
//  Uber_Clone
//
//  Created by zeyad on 6/9/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import Firebase

class LeftSidePanelVC: UIViewController {
    
    let currentUserId =  Auth.auth().currentUser?.uid
    let appDelegate = AppDelegate.getAppDelegate()
    
    @IBOutlet weak var loginOutBtn: UIButton!
    @IBOutlet weak var accountTypeLbl: UILabel!
    @IBOutlet weak var profileImg: RoundedImageView!
    @IBOutlet weak var pickModeLbl: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var emailLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        switchBtn.isHidden = true
        pickModeLbl.isHidden = true
        observeUsersAndDrivers()
        switchBtn.isOn = false
        
        if Auth.auth().currentUser == nil {
            profileImg.isHidden = true
            accountTypeLbl.text = ""
            emailLbl.text = ""
            loginOutBtn.setTitle("SIGN UP / SIGN IN", for: .normal)
        }else{
            profileImg.isHidden = false
            emailLbl.text = Auth.auth().currentUser?.email
            accountTypeLbl.text = ""
            loginOutBtn.setTitle("LOG OUT", for: .normal)
        }
    }
    @IBAction func switchToggeled(_ sender: Any) {
        if switchBtn.isOn {
            pickModeLbl.text = "PICK UP MODE ENABLED"
            appDelegate.containerVC.toggleSideMenu()
            DataService.instance.REF_DRIVERS.child(currentUserId!).updateChildValues(["isPickUpEnabled" : true])
        }else{
            pickModeLbl.text = "PICK UP MODE DIABLED"
            appDelegate.containerVC.toggleSideMenu()
            DataService.instance.REF_DRIVERS.child(currentUserId!).updateChildValues(["isPickUpEnabled" : false])
        }
    }
    
    func observeUsersAndDrivers(){
        DataService.instance.REF_USERS.observeSingleEvent(of: .value,with:  { (snapShot) in
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot] {
                for snap in snapShot {
                    if snap.key == Auth.auth().currentUser?.uid {
                        self.accountTypeLbl.text = "Passenger"
                        
                    }
                }
            }
        })
        
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value ,with:  { (snapShot) in
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot] {
                for snap in snapShot {
                    if snap.key == Auth.auth().currentUser?.uid {
                        self.accountTypeLbl.text = "Driver"
                        self.accountTypeLbl.isHidden = false
                        self.switchBtn.isEnabled = true
                        self.switchBtn.isHidden = false
                        let switchStatus = snap.childSnapshot(forPath: "isPickUpEnabled").value as? Bool
                        self.switchBtn.isOn = switchStatus!
                        self.pickModeLbl.isHidden = false
                        
                    }
                }
            }
        })
        
    }
    
    
    @IBAction func signupBtnPressed(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            present(loginVC, animated: true, completion: nil)
        }else {
            do{
                try Auth.auth().signOut()
                profileImg.isHidden = true
                switchBtn.isHidden = true
                emailLbl.text = ""
                pickModeLbl.isHidden = true
                accountTypeLbl.isHidden = true
                loginOutBtn.setTitle("SIGN UP / SIGN IN", for: .normal)
            }catch(let error){
                print(error)
            }
        }
  
        
    }
    
}
