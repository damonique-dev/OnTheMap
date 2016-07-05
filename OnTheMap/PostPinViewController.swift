//
//  PostPinViewController.swift
//  OnTheMap
//
//  Created by Damonique Thomas on 7/4/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import UIKit
import MapKit

class PostPinViewController: UIViewController, UITextViewDelegate {
    //first view
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTextBox: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    
    //second view
    @IBOutlet weak var urlTextBox: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var lat:Float!
    var lng:Float!
    var result:[Student]?
    var coordinates:CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextBox.delegate = self
        urlTextBox.delegate = self
        
        firstViewVisibility(false)
        secondViewVisibility(true)
        
        queryLocationAndGetStudentData()
    }
    
    //MARK: - Actions
    //Attempts to get lat/long from input location
    @IBAction func findLocationOnMap(sender: AnyObject) {
        if locationTextBox.text != "" {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(locationTextBox.text, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    self.displayAlert("Could not Geocode Location")
                }
                if let placemark = placemarks?.first {
                    self.coordinates = placemark.location!.coordinate
                    self.setUpMap()
                    self.firstViewVisibility(true)
                    self.secondViewVisibility(false)
                    
                } else {
                    self.displayAlert("Could not Geocode Location")
                }
            })
        }
    }
    
    @IBAction func postPin(sender: AnyObject) {
        //Checks to see if a student result was returned
        lat = Float(coordinates.latitude)
        lng = Float(coordinates.longitude)
        activityIndicator.startAnimating()
        if result?.count == 0 {
            self.postLocation()
        } else {
            self.updateLocation(result!)
        }
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - API CALLS
    func queryLocationAndGetStudentData(){
        ParseClient.sharedInstance().queryForStudentLocation(){ (success, result, error) in
            if success {
                self.result = result
                self.overrideLocation()
            } else {
                self.displayAlert(error!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        UdacityClient.sharedInstance().getUserData(){ (success, error) in
            if !success {
                self.displayAlert(error!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
    }
    
    func postLocation(){
        let info = [
            "uniqueKey": UdacityClient.sharedInstance().userID!,
            "firstName": UdacityClient.sharedInstance().firstName!,
            "lastName": UdacityClient.sharedInstance().lastName!,
            "mapString": locationTextBox.text!,
            "mediaURL": urlTextBox.text!,
            "latitude": lat,
            "longitude": lng
        ]
        
        ParseClient.sharedInstance().postStudentLocation(info as! [String : AnyObject]){ (success, error) in
            if success {
                self.refreshData()
                self.dismiss()
            } else {
                self.displayAlert(error!)
            }
        }
    }
    
    func updateLocation(result:[Student]){
        let student = result[0]
        let info = [
            "objectId":student.objectID,
            "uniqueKey": student.uniqueKey,
            "firstName": student.firstName,
            "lastName": student.lastName,
            "mapString": locationTextBox.text!,
            "mediaURL": urlTextBox.text!,
            "latitude": lat,
            "longitude": lng
        ]
        
        let newStudent = Student(dictionary: info as! [String : AnyObject])
        
        ParseClient.sharedInstance().updateStudentLocation(newStudent){ (success, error) in
            if success {
                self.refreshData()
                self.dismiss()
            } else {
                self.displayAlert(error!)
            }
        }
    }
    
    //MARK:- ACTION HELPERS
    func overrideLocation(){
        if result?.count > 0 {
            let message = "There already exists a location for you. Would you like to override it?"
            let alertView = UIAlertController(title: "Uh-Oh", message: message, preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "Override", style: .Default, handler: nil))
            alertView.addAction(UIAlertAction(title: "Cancel", style: .Default){ _ in
                self.dismissViewControllerAnimated(true, completion: nil)
                })
            presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    func displayAlert(message:String){
        let alertView = UIAlertController(title: "Uh-Oh", message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default){ _ in
            self.dismissViewControllerAnimated(true, completion: nil)
            })
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    func setUpMap(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }
    
    func dismiss(){
        activityIndicator.stopAnimating()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refreshData(){
        let nav  = self.presentingViewController as! UINavigationController
        let tab = nav.viewControllers[0] as! TabBarViewController
        let map = tab.viewControllers![0] as! MapViewController
        let table = tab.viewControllers![1] as! StudentTableViewController
        dispatch_async(dispatch_get_main_queue(), {
            tab.getStudentLocations()
            map.reload()
            table.reload()
        })
    }
    
    //MARK:- VIEW HELPERS
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "userpin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func secondViewVisibility(hide: Bool){
        submitButton.hidden = hide
        mapView.hidden = hide
        urlTextBox.hidden = hide
        if(hide) {
            //view.backgroundColor = UIColor(hexString: "FD8C1C")
        }
        
    }
    
    func firstViewVisibility(hide: Bool){
        locationLabel.hidden = hide
        locationTextBox.hidden = hide
        locationButton.hidden = hide
        if(hide) {
            //view.backgroundColor = UIColor(hexString: "A9A9A9")
        }
    }
}
