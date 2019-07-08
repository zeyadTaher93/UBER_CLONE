//
//  PickupVCViewController.swift
//  Uber_Clone
//
//  Created by zeyad on 6/22/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class PickupVC: UIViewController {

    
    
    @IBOutlet weak var mapview: RoundedMapView!
    
    
    var pickupCoordinate: CLLocationCoordinate2D!
    var passengeKey: String!
    var pin: MKPlacemark? = nil
    var locationplacemark: MKPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        locationplacemark = MKPlacemark(coordinate: pickupCoordinate)
        dropPin(placeMark: locationplacemark)
        centreMap(location: locationplacemark.location!)
        
        DataService.instance.REF_TRIPS.child(passengeKey).observe(.value) { (tripSnapshot) in
            if tripSnapshot.exists() {
                if tripSnapshot.childSnapshot(forPath: "TripIsAccepted").value as! Bool == true {
                    self.dismiss(animated: true, completion: nil)
                }
                
                
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func initData(coordinate : CLLocationCoordinate2D , key: String){
        self.pickupCoordinate = coordinate
        self.passengeKey = key
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptBtnPressed(_ sender: Any) {
        UpdateService.instance.acceptTrip(withPassangerKey: passengeKey, forDreiverKey: Auth.auth().currentUser!.uid )
        presentingViewController?.shouldPresrntLoadingView(true)
    }
    

}
extension PickupVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PickupPoint")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "PickupPoint")
        }else{
            annotationView?.annotation = annotation
        }
        annotationView?.image = #imageLiteral(resourceName: "destinationAnnotation")
        return annotationView
    }
    
    func centreMap(location : CLLocation){
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapview.setRegion(coordinateRegion, animated: true)
        
    }
    func dropPin(placeMark: MKPlacemark){
        pin = placeMark
        for annotation in mapview.annotations {
            mapview.removeAnnotation(annotation)
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = placeMark.coordinate
        mapview.addAnnotation(annotation)
        
    }
}
