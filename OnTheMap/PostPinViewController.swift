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
    @IBOutlet weak var urlLabel: UILabel!
    
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
        
        buttonFormat(locationButton)
        buttonFormat(submitButton)
        
        queryLocationAndGetStudentData()
    }
    
    //MARK: - Actions
    //Attempts to get lat/long from input location
    @IBAction func findLocationOnMap(sender: AnyObject) {
        if locationTextBox.text != "" {
            activityIndicator.startAnimating()
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
                    self.activityIndicator.stopAnimating()
                } else {
                    self.displayAlert("Could not Geocode Location")
                }
            })
        } else {
            displayAlert("Please enter a location!")
        }
    }
    
    @IBAction func postPin(sender: AnyObject) {
        if urlTextBox.text != "" {
            lat = Float(coordinates.latitude)
            lng = Float(coordinates.longitude)
            activityIndicator.startAnimating()
            if result?.count == 0 {
                self.postLocation()
            } else {
                self.updateLocation(result!)
            }
        } else {
            displayAlert("Please enter a link!")
        }
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - API CALLS
    func queryLocationAndGetStudentData(){
        UdacityClient.sharedInstance().getUserData(){ (success, error) in
            if !success {
                self.displayAlert(error!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func postLocation(){
        let info = [
            "uniqueKey": GlobalVariables.userID!,
            "firstName": GlobalVariables.firstName!,
            "lastName": GlobalVariables.lastName!,
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
    func displayAlert(message:String){
        let alertView = UIAlertController(title: "Uh-Oh", message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    func setUpMap(){
        let annotation = MKPointAnnotation()
        let regionRadius: CLLocationDistance = 10000
        annotation.coordinate = coordinates
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
        ParseClient.sharedInstance().getStudentLocations(){ (success, error) in
            performUIUpdatesOnMain {
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        table.tableView.reloadData()
                        map.reload()
                    }
                } else {
                    self.displayAlert(error!)
                }
            }
        }
 
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
    
    func buttonFormat(button:UIButton){
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    func secondViewVisibility(hide: Bool){
        submitButton.hidden = hide
        mapView.hidden = hide
        urlTextBox.hidden = hide
        urlLabel.hidden = hide
    }
    
    func firstViewVisibility(hide: Bool){
        locationLabel.hidden = hide
        locationTextBox.hidden = hide
        locationButton.hidden = hide
    }
}
