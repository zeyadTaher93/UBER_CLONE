//
//  ViewController.swift
//  Uber_Clone
//
//  Created by zeyad on 5/24/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RevealingSplashView
import Firebase

enum annotationType{
    case pickup
    case destination
    case driver
}
enum buttonAction {
    case requestRide
    case directiontoPassenger
    case directiontoDestination
    case startTrip
    case endTrip
}

class HomeVC: UIViewController, Alertable {

    @IBOutlet weak var centreBtn: UIButton!
    @IBOutlet weak var requestRideBtn: RoundedSadowButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationTxt: UITextField!
    @IBOutlet weak var distinationCircle: circleView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var tableView = UITableView()
    var delagate: CentreVCDelegate?
    let manager = CLLocationManager()
    let revealingSplash = RevealingSplashView(iconImage: #imageLiteral(resourceName: "driverAnnotation"), iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    var regionRadius: CLLocationDistance = 1000
    var matchingItems = [MKMapItem]()
    var selectedPlaceMark:MKPlacemark? = nil
    var route = MKRoute()
    var actionForButton: buttonAction = .requestRide
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataService.instance.userIsDriver(userKey: Auth.auth().currentUser?.uid) { (status) in
            if status {
                self.buttonsForDrivers(areHidden: true)
            }
        }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        checkAutherizationStatus()
        mapView.delegate = self
        destinationTxt.delegate = self
        centreMapview()
        DataService.instance.REF_DRIVERS.observe(.value) { (snapshot) in
            self.loadAnnotationForAllDriversFromFB()
            DataService.instance.passengerIsOnTrip(passangerKey: Auth.auth().currentUser?  .uid, handler: { (isOnAtrip, driverKey, tripKey) in
                if isOnAtrip! {
                    self.zoom(toFitAnnotationfor: self.mapView, forActiverTripWithDriver: true, withKey: driverKey)
                }
            })
        }
        
        self.view.addSubview(revealingSplash)
        revealingSplash.animationType = SplashAnimationType.heartBeat
        revealingSplash.startAnimation()
        
        UpdateService.instance.observeTrips { (tripDict) in
            if let tripDict = tripDict {
                let tripCoordinate = tripDict["PickupCoordinates"] as! NSArray
                let tripKey = tripDict["passengerKey"] as! String
                let acceptStatus = tripDict["TripIsAccepted"] as! Bool
                
                if acceptStatus == false {
                    DataService.instance.driverIsAvaliable(key: Auth.auth().currentUser!.uid, handler: { (available) in
                        if available! {
                            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                            let pickupVC = storyboard.instantiateViewController(withIdentifier: "PickupVC") as! PickupVC
                            pickupVC.initData(coordinate: CLLocationCoordinate2D(latitude: tripCoordinate[0] as! CLLocationDegrees, longitude: tripCoordinate[1] as! CLLocationDegrees), key: tripKey)
                            self.present(pickupVC, animated: true, completion: nil)
                            
                        }
                    })
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
         DataService.instance.driverIsOnAtrip(driverKey: Auth.auth().currentUser?.uid, handler: { (isOnAtrip, driverKey, tripKey) in
            if isOnAtrip! {
                DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with: { (tripsnapshot) in
                    if let tripsnapshot = tripsnapshot.children.allObjects as? [DataSnapshot]{
                        for trip in tripsnapshot {

                            if trip.childSnapshot(forPath: "DriverKey").value as? String  == Auth.auth().currentUser!.uid {
                                let pickupCoordinateArray = trip.childSnapshot(forPath: "PickupCoordinates").value as! NSArray
                                let pickupCoordiante = CLLocationCoordinate2D(latitude: pickupCoordinateArray[0] as! CLLocationDegrees, longitude: pickupCoordinateArray[1] as! CLLocationDegrees)
                                let pickupPlacemark = MKPlacemark(coordinate: pickupCoordiante)

                                self.dropApinFor(placeMark: pickupPlacemark)
                                self.dropPolyLine(forSourceMapItem: nil, forDestinationMapItem: MKMapItem(placemark: pickupPlacemark))
                                
                                self.customRegion(withAnnotationType: .pickup, withCoordinate: pickupCoordiante)
                                
                                self.actionForButton = .directiontoPassenger
                                self.requestRideBtn.setTitle("DIRECTION TO PASSENGER", for: .normal)
                                self.buttonsForDrivers(areHidden: false)
                            }
                        }
                    }
                })
            }
        })
        connectUserToDriver()
        

        
    }
    
    
    func connectUserToDriver(){
        DataService.instance.userIsDriver(userKey: Auth.auth().currentUser?.uid) { (userIsDriver) in
            if userIsDriver == false {
                DataService.instance.REF_TRIPS.child(Auth.auth().currentUser!.uid).observe( .value , with: { (tripSnapshot) in
                        let tripDict = tripSnapshot.value as? Dictionary<String , AnyObject>
                    if tripDict?["TripIsAccepted"] as? Bool == true {
                            self.removeAnnotationAndRoutes(forDrivers: false, forPassengers: true)
                        let driverKey = tripDict!["DriverKey"] as? String
                        let pickUpCoorrdinateArray = tripDict!["PickupCoordinates"] as? NSArray
                            let pickUpcoordinate = CLLocationCoordinate2D(latitude: pickUpCoorrdinateArray![0] as! CLLocationDegrees, longitude: pickUpCoorrdinateArray![1] as! CLLocationDegrees)
                            let pickupPlaceMark = MKPlacemark(coordinate: pickUpcoordinate)
                            let pickupMapItem = MKMapItem(placemark: pickupPlaceMark)
                            
                        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (driverSnapshot) in
                                if let snapshot = driverSnapshot.children.allObjects as? [DataSnapshot] {
                                    for driver in snapshot {
                                        if driver.key == driverKey {
                                            let coordinateArray = driver.childSnapshot(forPath: "coordinate").value as? NSArray
                                            let driverCoordiante = CLLocationCoordinate2D(latitude: coordinateArray![0] as! CLLocationDegrees, longitude: coordinateArray![1] as! CLLocationDegrees)
                                            let driverPlaceMark = MKPlacemark(coordinate: driverCoordiante)
                                            let driverMapItem = MKMapItem(placemark: driverPlaceMark)
                                            
                                            let passangerAnnotation = PassengerAnnotation(coordinate: pickUpcoordinate, key: Auth.auth().currentUser!.uid)
//                                            let driverAnnotation = DriverAnnotation(withCoordinate: driverCoordiante, key: driverKey!)
                                            print("this is aloop")
                                            self.mapView.addAnnotation(passangerAnnotation)
                                            print("go ahead")
                                            self.dropPolyLine(forSourceMapItem: driverMapItem, forDestinationMapItem: pickupMapItem )
                                            self.requestRideBtn.animateButton(shouldLoad: false, withMessage: "ON THE WAY")
                                            self.requestRideBtn.isUserInteractionEnabled = false
                                            
                                        }
                                  
                                        
                                    }
                                }
                            })
                        DataService.instance.REF_TRIPS.child(driverKey!).observeSingleEvent(of: .value, with: { (tripSnapshot) in
                            if tripDict?["IsTripOnProgress"] as? Bool == true{
                                self.removeAnnotationAndRoutes(forDrivers: true, forPassengers: true)
                                
                                let destinationCoordinateArray = tripDict!["DestinationCoordinates"] as? NSArray
                                let destinataionCoordinate = CLLocationCoordinate2D(latitude: destinationCoordinateArray![0] as! CLLocationDegrees, longitude: destinationCoordinateArray![1] as! CLLocationDegrees)
                                let destinationPlacemark = MKPlacemark(coordinate: destinataionCoordinate)
                                self.dropApinFor(placeMark: destinationPlacemark)
                                self.dropPolyLine(forSourceMapItem: pickupMapItem, forDestinationMapItem: MKMapItem(placemark: destinationPlacemark))
                                self.requestRideBtn.setTitle("ON TRIP", for: .normal)
                                
                            }
                        })
                        }
                    
                    
                    
                })
            }
       
        }
    }
    
    
    func checkAutherizationStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedAlways{
            manager.startUpdatingLocation()
        }else{
            manager.requestAlwaysAuthorization()
        }
    }
    
    func buttonsForDrivers(areHidden: Bool){
        if areHidden {
            requestRideBtn.fadeTo(alphaValue: 0.0, with: 0.2)
            cancelBtn.fadeTo(alphaValue: 0.0, with: 0.2)
            centreBtn.fadeTo(alphaValue: 0.0, with: 0.2)
            requestRideBtn.isHidden = true
            cancelBtn.isHidden = true
            centreBtn.isHidden = true
        }else{
            requestRideBtn.fadeTo(alphaValue: 1.0, with: 0.2)
            cancelBtn.fadeTo(alphaValue: 1.0, with: 0.2)
            centreBtn.fadeTo(alphaValue: 1.0, with: 0.2)
            requestRideBtn.isHidden = false
            cancelBtn.isHidden = false
            centreBtn.isHidden = false
        }
    }
    
    func loadAnnotationForAllDriversFromFB(){
        DataService.instance.REF_DRIVERS.observe(.value,with:  { (snapshot) in
            if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for driver in driverSnapshot {
                    if driver.hasChild("coordinate"){
                        if driver.childSnapshot(forPath: "isPickUpEnabled").value as? Bool == true{
                            let driverDict = driver.value as? Dictionary <String ,AnyObject>
                            let coordinateArray = driverDict!["coordinate"] as! NSArray
                            let driverCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                            let annotation = DriverAnnotation(withCoordinate: driverCoordinate, key: driver.key)
                            
                            
                            var driverIsVisible: Bool{
                                return self.mapView.annotations.contains(where: { (annotation) -> Bool in
                                    if let driverAnnotation = annotation as? DriverAnnotation{
                                        if driverAnnotation.key == driver.key {
                                            driverAnnotation.update(AnnotationLocation: driverAnnotation, withCoordinate: driverCoordinate)
                                            return true
                                        }
                                    }
                                    return false
                                })
                            }
                            if !driverIsVisible {
                                self.mapView.addAnnotation(annotation)
                            }
                            
                        }else{
                            for annotation in self.mapView.annotations {
                                if annotation.isKind(of: DriverAnnotation.self){
                                    if let annotation = annotation as? DriverAnnotation {
                                        if annotation.key == driver.key {
                                            self.mapView.removeAnnotation(annotation)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
        revealingSplash.heartAttack = true
    }
    
    func centreMapview(){
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true )
    }

    @IBAction func requestBtnPressed(_ sender: Any) {
       actionSelector(forAction: actionForButton)
    }
    
    @IBAction func cancelTripBtnPressed(_ sender: Any) {
        DataService.instance.driverIsOnAtrip(driverKey: Auth.auth().currentUser!.uid) { (isOnTrip, driverKey, tripKey) in
            if isOnTrip! {
                UpdateService.instance.cancelTrip(withPassangerKey: tripKey!, forDreiverKey: driverKey!)
                self.removeAnnotationAndRoutes(forDrivers: true, forPassengers: false)
            }
        }
        DataService.instance.passengerIsOnTrip(passangerKey: Auth.auth().currentUser!.uid) { (isOnTrip, driverKey, tripKey) in
            if isOnTrip! {
                UpdateService.instance.cancelTrip(withPassangerKey: Auth.auth().currentUser!.uid, forDreiverKey: driverKey!)
                self.removeAnnotationAndRoutes(forDrivers: false, forPassengers: true)
            }else{
                 UpdateService.instance.cancelTrip(withPassangerKey: Auth.auth().currentUser!.uid, forDreiverKey: nil)
                 self.removeAnnotationAndRoutes(forDrivers: false, forPassengers: true)
            }
        }
        
        self.requestRideBtn.isUserInteractionEnabled = true
        
    }
    @IBAction func sideMenuBtnPressed(_ sender: Any) {
        delagate?.toggleSideMenu()
    }
    @IBAction func centreBtnPressed(_ sender: Any) {
        DataService.instance.REF_USERS.observe(.value) { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for user in userSnapshot {
                    if user.key == Auth.auth().currentUser?.uid {
                        if user.hasChild("tripCoordinate "){
                            self.zoom(toFitAnnotationfor: self.mapView, forActiverTripWithDriver: false , withKey: nil)
                            self.centreBtn.fadeTo(alphaValue: 0.0, with: 0.2)
                        }else{
                            self.centreMapview()
                            self.centreBtn.fadeTo(alphaValue: 0.0, with: 0.2)
                        }
                    }
                }
            }
        }
        
    }
    
    func actionSelector(forAction action: buttonAction){
        switch action {
        case .requestRide:
            if destinationTxt.text != nil {
                self.cancelBtn.fadeTo(alphaValue: 1.0, with: 0.2)
                requestRideBtn.animateButton(shouldLoad: true, withMessage: nil)
                UpdateService.instance.updateTripsUponRequest()
                self.view.endEditing(true)
                self.destinationTxt.isUserInteractionEnabled = false
            }
          
        case .directiontoPassenger:
            DataService.instance.driverIsOnAtrip(driverKey: Auth.auth().currentUser?.uid) { (isOntrip, driverKey, tripKey) in
                if isOntrip! {
                    DataService.instance.REF_TRIPS.child(tripKey!).observe(.value, with: { (tripsnapshot) in
                        let tripDict = tripsnapshot.value as? Dictionary<String ,AnyObject>
                        let pickupCoordinateArray = tripDict?["PickupCoordinates"] as? NSArray
                        let pickupcoordinate = CLLocationCoordinate2D(latitude: pickupCoordinateArray![0] as! CLLocationDegrees, longitude: pickupCoordinateArray![1] as! CLLocationDegrees)
                        let pickupMapitem = MKMapItem(placemark: MKPlacemark(coordinate: pickupcoordinate))
                        pickupMapitem.name = "Passenger pickup Point"
                        pickupMapitem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving ])
                        
                        
                       
                    })
                }
            }
        case .startTrip:
            DataService.instance.driverIsOnAtrip(driverKey: Auth.auth().currentUser?.uid) { (isOnTrip, driverKey, tripKey) in
                if isOnTrip! {
                    self.removeAnnotationAndRoutes(forDrivers: false, forPassengers: false)
                    DataService.instance.REF_TRIPS.child(tripKey!).updateChildValues(["IsTripOnProgress" : true])
                    DataService.instance.REF_TRIPS.child(tripKey!).child("DestinationCoordinates").observeSingleEvent(of: .value, with: { (coordinateSnapshot ) in
                        print(coordinateSnapshot)
                        let coordinateArray = coordinateSnapshot.value as? NSArray
                        let dinstinatonCoordinate = CLLocationCoordinate2D(latitude: coordinateArray![0] as! CLLocationDegrees, longitude: coordinateArray![1] as! CLLocationDegrees)
                        let distinationPlacemark = MKPlacemark(coordinate: dinstinatonCoordinate)
                        self.dropApinFor(placeMark: distinationPlacemark)
                        self.dropPolyLine(forSourceMapItem: nil, forDestinationMapItem: MKMapItem(placemark: distinationPlacemark))
                        self.customRegion(withAnnotationType: .destination, withCoordinate: dinstinatonCoordinate)
                        self.actionForButton = .directiontoDestination
                        self.requestRideBtn.setTitle("GET DIRECTION", for: .normal)
                        
                        
                    })
                }
            }
        case .directiontoDestination:
            print("gjgjh")
        case .endTrip:
            print("gjgjh")
            
        }
    }
}
extension HomeVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAutherizationStatus()
        if status == .authorizedAlways{
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        DataService.instance.driverIsOnAtrip(driverKey: Auth.auth().currentUser!.uid) { (isOnAtrip, driverKey, passengerKey) in
            if isOnAtrip! {
                if region.identifier == "pickup" {
                    self.actionForButton = .startTrip
                    self.requestRideBtn.setTitle("START TRIP", for: .normal)
                }else if region.identifier == "destination" {
                    self.cancelBtn.fadeTo(alphaValue: 0.0, with: 0.2)
                    self.cancelBtn.isHidden = true
                    self.requestRideBtn.setTitle("END TRIP", for: .normal)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        DataService.instance.driverIsOnAtrip(driverKey: Auth.auth().currentUser!.uid) { (isOnAtrip, driverKey, passengerKey) in
            if isOnAtrip! {
                if region.identifier == "pickup" {
                    self.requestRideBtn.setTitle("GET DIRICTION", for: .normal)
                }else if region.identifier == "destination" {
                    
                    self.requestRideBtn.setTitle("GET DIRICTION", for: .normal)
                }
            }
        }
    }
    
}
extension HomeVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        UpdateService.instance.updateUserlocation(withCoordinate: userLocation.coordinate)
        UpdateService.instance.updateDriverlocation(withCoordinate: userLocation.coordinate)
    
        DataService.instance.userIsDriver(userKey: Auth.auth().currentUser?.uid) { (isAdriver) in
            
            if isAdriver {
                DataService.instance.driverIsOnAtrip(driverKey: Auth.auth().currentUser!.uid) { (isOnTrip,driverKey , tripKey) in
                    if isOnTrip! {
                        self.zoom(toFitAnnotationfor: self.mapView, forActiverTripWithDriver: true , withKey:driverKey)
                    }else{
                        self.centreMapview()
                    }
                }
                
            }else{
                DataService.instance.passengerIsOnTrip(passangerKey: Auth.auth().currentUser!.uid, handler: { (isOnAtrip, driverKey, tipKey) in
                    if isOnAtrip! {
                        self.zoom(toFitAnnotationfor: self.mapView, forActiverTripWithDriver: true , withKey:driverKey)
                    }else{
                        self.centreMapview()
                    }
                })
            }
        }
        
      
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view:MKAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "driver")
            view.image = #imageLiteral(resourceName: "driverAnnotation")
            return view
        }else if let annotation = annotation as? PassengerAnnotation{
            
                let view: MKAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "passenger")
                view.image = #imageLiteral(resourceName: "currentLocationAnnotation")
                return view
            
        }else if let annotation = annotation as? MKPointAnnotation{
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "destination")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "destination")
                
            }else{
                annotationView?.annotation = annotation
            }
            annotationView?.image = #imageLiteral(resourceName: "destinationAnnotation")
            return annotationView
        }
        return nil
    }
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        centreBtn.fadeTo(alphaValue: 1.0, with: 0.2)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let lineRrndrer = MKPolylineRenderer(overlay: route.polyline)
        lineRrndrer.strokeColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        lineRrndrer.lineWidth = 3
        shouldPresrntLoadingView(false)
        return lineRrndrer
    }
    
    func performSearch(){
        matchingItems.removeAll()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = destinationTxt.text
        request.region = self.mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error != nil {
                self.showAlert(error.debugDescription)
            }else if response?.mapItems.count == 0 {
                self.showAlert("no results")
            }else{
                for item in response!.mapItems{
                    self.matchingItems.append(item)
                    self.tableView.reloadData()
                    self.shouldPresrntLoadingView(false)
                }
            }
        }
        
    }
    
    func dropApinFor(placeMark: MKPlacemark){
        selectedPlaceMark = placeMark
        for annotation in mapView.annotations {
            if annotation.isKind(of: MKPointAnnotation.self){
                mapView.removeAnnotation(annotation)
            }
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placeMark.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func dropPolyLine(forSourceMapItem sourceMapItem : MKMapItem? , forDestinationMapItem destinationMapItem: MKMapItem){
        
        let request = MKDirections.Request()
        
        if sourceMapItem == nil {
            request.source = MKMapItem.forCurrentLocation()
        }else{
            request.source = sourceMapItem
        }
        
        request.destination = destinationMapItem
        request.transportType = .automobile
        
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            guard let response = response else{
                self.showAlert(error.debugDescription)
                return
            }
            
            self.route = response.routes[0]
            
//              if self.mapView.overlays.count == 0 {
                self.mapView.addOverlay(self.route.polyline)
//              }
            self.zoom(toFitAnnotationfor: self.mapView, forActiverTripWithDriver: false , withKey: nil)

            let delegate = AppDelegate.getAppDelegate()
            
            delegate.window?.rootViewController?.shouldPresrntLoadingView(false)
        }
        
    }
    func removeAnnotationAndRoutes(forDrivers: Bool? , forPassengers: Bool?){
        for annotation in mapView.annotations {
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
            
            if forPassengers! {
                if let annotation = annotation as? PassengerAnnotation{
                    mapView.removeAnnotation(annotation)
                }
            }
            if forDrivers! {
                if let annotation = annotation as? DriverAnnotation{
                    mapView.removeAnnotation(annotation)
                }
            }
        }
        
        for overlay in mapView.overlays {
            print("a7a")
            if overlay .isKind(of: MKPolyline.self) {
                self.mapView.removeOverlay(overlay)
                print(overlay.description)
                
            }
        }
        
    }
    
    func customRegion(withAnnotationType type : annotationType , withCoordinate coordinate: CLLocationCoordinate2D){
        if type == .pickup{
            let pickupRegion = CLCircularRegion(center: coordinate, radius: 100, identifier: "pickup")
            manager.startMonitoring(for: pickupRegion)
        }else if type == .destination{
            let destinationRegion = CLCircularRegion(center: coordinate, radius: 100, identifier: "destination")
            manager.startMonitoring(for: destinationRegion)
        }
    }
    
    func zoom(toFitAnnotationfor mapView: MKMapView , forActiverTripWithDriver: Bool , withKey key : String?){
        if mapView.annotations.count == 0{
            return
        }

        var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        if forActiverTripWithDriver {
            for annotation in mapView.annotations {
                if let annotation = annotation as? DriverAnnotation {
                    if annotation.key == key {
                        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
                        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
                        
                        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
                        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
                    }
                }else  {
                    topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
                    topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
                    
                    bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
                    bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
                }
            }
        }

        for annotation in mapView.annotations where !annotation.isKind(of: DriverAnnotation.self){
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)

            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)

            

        }
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 2.0
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 2.0
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
}
extension HomeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == destinationTxt{
            tableView.frame = CGRect(x: 20, y: view.frame.height , width: view.frame.width - 40, height: view.frame.height - 170)
            tableView.layer.cornerRadius = 5.0
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
            tableView.rowHeight = 60
            tableView.tag = 18
            
            tableView.delegate = self
            tableView.dataSource = self
            
            view.addSubview(tableView)
            animateTableView(shouldShow: true)
            UIView.animate(withDuration: 0.2) {
                self.distinationCircle.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0.2784313725, blue: 0.1176470588, alpha: 1)
                self.distinationCircle.borderColor = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
            }
            
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == destinationTxt{
            if destinationTxt.text == ""{
                UIView.animate(withDuration: 0.2) {
                    self.distinationCircle.backgroundColor = UIColor.lightGray
                    self.distinationCircle.borderColor = UIColor.darkGray
                }
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == destinationTxt{
            performSearch()
            shouldPresrntLoadingView(true)
            view.endEditing(true)
            
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        matchingItems = []
        tableView.reloadData()
        centreMapview()
        DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid).child("tripCoordinate ").removeValue()
        mapView.removeOverlays(mapView.overlays)
        for annotation in mapView.annotations {
            if annotation.isKind(of: MKPointAnnotation.self){
                mapView.removeAnnotation(annotation)
            }else if annotation.isKind(of: PassengerAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
            
        }
        return true
    }
    func animateTableView(shouldShow: Bool){
        if shouldShow{
            UIView.animate(withDuration: 0.2) {
                self.tableView.frame = CGRect(x: 20, y: 170 , width: self.view.frame.width - 40, height: self.view.frame.height - 170)
            }
        }else{
            UIView.animate(withDuration: 0.2 ,delay: 0, animations: {
                self.tableView.frame = CGRect(x: 20, y: self.view.frame.height , width: self.view.frame.width - 40, height: self.view.frame.height - 170)
            }) { (finished) in
                if finished {
                    for view in self.view.subviews {
                        if view.tag == 18 {
                            view.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
  
}

extension HomeVC: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "locationCell")
        let matchItem = matchingItems[indexPath.row]
        cell.textLabel?.text = matchItem.name
        cell.detailTextLabel?.text = matchItem.placemark.title
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shouldPresrntLoadingView(true)
        let passengerCoordinate = manager.location?.coordinate
        let passengerAnnotation = PassengerAnnotation(coordinate: passengerCoordinate!, key: Auth.auth().currentUser!.uid)
        mapView.addAnnotation(passengerAnnotation)
        destinationTxt.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        let selectedResult = matchingItems[indexPath.row]
        let longitude = selectedResult.placemark.coordinate.longitude
        let latitude = selectedResult.placemark.coordinate.latitude
     DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid).updateChildValues(["tripCoordinate " : [latitude,longitude]])
        dropApinFor(placeMark: selectedResult.placemark)
        dropPolyLine(forSourceMapItem: nil, forDestinationMapItem: selectedResult)
        animateTableView(shouldShow: false)
        print("selected")
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("dragging is working")
            if destinationTxt.text == "" {
            print("dammn")
            animateTableView(shouldShow: false)
        }
    }
}
