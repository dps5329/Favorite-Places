//
//  ViewController.swift
//  Favorite Places
//
//  Created by Daniel Schartner on 6/16/15.
//  Copyright (c) 2015 Daniel Schartner. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

var favCoords = [CGPoint]()

//gets a user's list of favorite places from memory
func getLatestCoords(){
    //if the user has recorded some places, get those
    if(NSUserDefaults.standardUserDefaults().objectForKey("coords") != nil){
        favCoords = NSUserDefaults.standardUserDefaults().objectForKey("coords")! as [CGPoint]
    }else{
        favCoords = []
    }
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var userInput: UITextField!
    
    var locationManager =  CLLocationManager()
    
    var mapCentered = false
    
    var userText = ""
    
    var tempCoordinates = [AnyObject]()
    
    //control keyboard
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
        userText = ""
        tempCoordinates = [AnyObject]()
        userInput.hidden = true
    }
    
    //update info
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        userText = userInput.text
        if(userText != "" && tempCoordinates.count > 0){
            favPlaces.append(userText)
            favCoords.append(tempCoordinates[0])
            println(tempCoordinates[0].locationInView(self.map))
            println(favCoords[0].locationInView(self.map))
            /*NSUserDefaults.standardUserDefaults().setObject(favPlaces, forKey: "places")
            NSUserDefaults.standardUserDefaults().setObject(favCoords, forKey: "coords")*/
        }
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        userText = ""
        tempCoordinates = [AnyObject]()
        textField.resignFirstResponder()
        userInput.hidden = true
        return true
    }
    
    //sets up map based on user's location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        //in case locations has multiple locations we'll just get the first
        var currentLoc: CLLocation = locations[0] as CLLocation
        
        //setup coordinates and location data
        var lat = currentLoc.coordinate.latitude
        var lon = currentLoc.coordinate.longitude
        var latDelta = 0.01
        var lonDelta = 0.01
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
        var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        //center map on that location
        if(!mapCentered){
            self.map.setRegion(region, animated:true)
            mapCentered = true
        }
    }
    
    //the user presssed on the map and wants to add a marker there
    func mapLongPressed(gestureRecog: UIGestureRecognizer){
        //touchPoint is the location of the press on the screen
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        userInput.hidden = false
        
        //save the user press
        tempCoordinates.append(gestureRecog)
    }
    
    //add markers on map to display favorite places
    func createMarkers(){
        //update data
        getLatestPlaces()
        getLatestCoords()
        var touchPoint:CGPoint
        var coords:CLLocationCoordinate2D
        var annotation = MKPointAnnotation()
        //go through each point
        for(var i = 0; i < favPlaces.count; i++){
            //get coordinates and make annotations (or markers)
            touchPoint = favCoords[i].locationInView(self.map)
            coords = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            annotation = MKPointAnnotation()
            annotation.coordinate = coords
            annotation.title = favPlaces[i] as NSString
            map.addAnnotation(annotation)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup initial data
        userInput.hidden = true
        userText = ""
        tempCoordinates = [AnyObject]()
        self.userInput.delegate = self
        
        //update data
        getLatestPlaces()
        getLatestCoords()
        
        //add markers
        createMarkers()
        
        //setup user location logisitics
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //add marker or annotation at long pressed spot
        //the colon makes sure the function is called after all data is recorded
        //that way we can get the necessary gesture recognizer into the function
        var uilpgr = UILongPressGestureRecognizer(target: self, action: "mapLongPressed:")
        uilpgr.minimumPressDuration = 2
        map.addGestureRecognizer(uilpgr)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

