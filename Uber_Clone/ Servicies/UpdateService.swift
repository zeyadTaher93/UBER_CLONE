//
//  UpdateService.swift
//  Uber_Clone
//
//  Created by zeyad on 6/15/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MapKit

class UpdateService{
    static var instance = UpdateService()
    
    func updateUserlocation(withCoordinate coordanite: CLLocationCoordinate2D){
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for user in userSnapshot {
                    if user.key == Auth.auth().currentUser?.uid{
                        DataService.instance.REF_USERS.child(user.key).updateChildValues(["coordinate" : [coordanite.latitude , coordanite.longitude]])
                    }
                }
            }
        }
    }
    
    func updateDriverlocation(withCoordinate coordanite: CLLocationCoordinate2D){
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value) { (snapshot) in
            if let DriverSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for driver in DriverSnapshot {
                    if driver.key == Auth.auth().currentUser?.uid{
                        if driver.childSnapshot(forPath: "isPickUpEnabled").value as! Bool {
                            DataService.instance.REF_DRIVERS.child(driver.key).updateChildValues(["coordinate" : [coordanite.latitude , coordanite.longitude]])
                        }
                        
                    }
                }
            }
        }
    }
    func observeTrips(handler: @escaping(_ coordinateDict: Dictionary<String , AnyObject>?) ->  Void ){
        DataService.instance.REF_TRIPS.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for trip in snapshot {
                    if trip.hasChild("passengerKey") && trip.hasChild("TripIsAccepted"){
                        if let tripDect = trip.value as? Dictionary<String ,AnyObject>{
                            handler(tripDect)
                        }
                    }
                }
            }
        }
    }
    
    func updateTripsUponRequest(){
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for user in snapshot {
                    if user.key == Auth.auth().currentUser?.uid {
                        if !user.hasChild("userIsDriver") {
                            if let userDict = user.value as? Dictionary<String, AnyObject>{
                                let pickupArray = userDict["coordinate"] as! NSArray
                                let destinationArray = userDict["tripCoordinate "] as! NSArray
                                
                                DataService.instance.REF_TRIPS.child(user.key).updateChildValues(["PickupCoordinates" : [pickupArray[0],pickupArray[1]]])
                                DataService.instance.REF_TRIPS.child(user.key).updateChildValues(["DestinationCoordinates" : [destinationArray[0],destinationArray[1]]])
                                DataService.instance.REF_TRIPS.child(user.key).updateChildValues(["passengerKey" : user.key])
                                DataService.instance.REF_TRIPS.child(user.key).updateChildValues(["TripIsAccepted" : false])
                                
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func acceptTrip(withPassangerKey passangerKey: String , forDreiverKey driverKey : String ){
        DataService.instance.REF_TRIPS.child(passangerKey).updateChildValues(["DriverKey" : driverKey , "TripIsAccepted":true])
        DataService.instance.REF_DRIVERS.child(driverKey).updateChildValues(["driverOnTrip" : true])
        
        }
    
    func cancelTrip(withPassangerKey passangerKey: String , forDreiverKey driverKey : String?){
        DataService.instance.REF_TRIPS.child(passangerKey).removeValue()
        DataService.instance.REF_USERS.child(passangerKey).child("tripCoordinate ").removeValue()
        if driverKey != nil {
            DataService.instance.REF_DRIVERS.child(driverKey!).updateChildValues(["driverOnTrip" : false])
        }
        
    }
    
    
    
    
    
}
