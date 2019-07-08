//
//  DataService.swift
//  Uber_Clone
//
//  Created by zeyad on 6/10/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE: DatabaseReference = Database.database().reference()

class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_DRIVERS = DB_BASE.child("drivers")
    private var _REF_TRIPS = DB_BASE.child("trips")
    
    var REF_BASE : DatabaseReference {
        return _REF_BASE
    }
    var REF_USERS : DatabaseReference {
        return _REF_USERS
    }
    var REF_DRIVERS : DatabaseReference {
        return _REF_DRIVERS
    }
    var REF_TRIPS : DatabaseReference {
        return _REF_TRIPS
    }
    
    func createUser(uid: String , userData: Dictionary<String , Any> , isDriver: Bool){
        if isDriver {
            REF_DRIVERS.child(uid).updateChildValues(userData)
        } else {
            REF_USERS.child(uid).updateChildValues(userData)
        }
    }
    func driverIsAvaliable(key: String? ,handler: @escaping( _ status: Bool?) -> Void){
        if key != nil {
            DataService.instance._REF_DRIVERS.observeSingleEvent(of: .value) { (snapshot) in
                if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for driver in driverSnapshot {
                        if driver.key == key {
                            if driver.childSnapshot(forPath: "isPickUpEnabled").value as! Bool {
                                if driver.childSnapshot(forPath: "driverOnTrip").value as! Bool {
                                    handler(false)
                                }else{
                                    handler(true)
                                }
                            }
                        }
                    }
                }
            }
        }else{
            return
        }
       
    }
    
    func driverIsOnAtrip(driverKey: String? , handler: @escaping( _ status : Bool? , _ driverKey: String? , _ tripKey: String?)-> Void){
        if driverKey != nil {
            DataService.instance.REF_DRIVERS.child(driverKey!).child("driverOnTrip").observe(.value) { (snapshot) in
                if let driverStatusSnapshot = snapshot.value as? Bool {
                    if driverStatusSnapshot {
                        DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with: { (tripSnapshot) in
                            if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot]{
                                for trip in tripSnapshot {
                                    if trip.childSnapshot(forPath: "DriverKey").value as? String == driverKey {
                                        handler(true , driverKey ,trip.key)
                                    }else{
                                        return
                                    }
                                }
                            }
                        })
                    }else{
                        handler(false , nil , nil)
                    }
                }
            }
        }else{
            return
        }
       
    }
    func passengerIsOnTrip(passangerKey: String? , handler: @escaping(_ status: Bool?, _ DriverKey: String? , _ tripKey:String?)-> Void){
        if passangerKey != nil {
            DataService.instance.REF_TRIPS.observeSingleEvent(of: .value) { (tripSnapshot) in
                if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot]{
                    for trip in tripSnapshot {
                        if trip.key == passangerKey {
                            if trip.childSnapshot(forPath: "TripIsAccepted").value as? Bool == true {
                                let driverkey = trip.childSnapshot(forPath: "DriverKey").value as? String
                                handler(true , driverkey , trip.key)
                            }else{
                                handler(false , nil, nil)
                            }
                        }
                    }
                }
            }
        }else {
            return
        }
     
    }
    
    func userIsDriver(userKey: String? , handler: @escaping(_ status : Bool)-> Void){
        if userKey != nil {
            DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value) { (driverSnapshot) in
                if let driverSnapshot = driverSnapshot.children.allObjects as? [DataSnapshot]{
                    for driver in driverSnapshot{
                        if driver.key == userKey {
                            handler(true)
                        }else{
                            handler(false)
                        }
                    }
                }
            }
        }else{
            return
        }
      
    }
    
}
