//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Damonique Thomas on 7/3/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        getStudentLocations()
    }
    
    func reload() {
        map.removeAnnotations(annotations)
        annotations.removeAll()
    }
    
    func setUp() {
        for student in GlobalVariables.students {
            
            let lat = CLLocationDegrees(student.lat)
            let long = CLLocationDegrees(student.lng)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.map.addAnnotations(annotations)
    }
    
    func getStudentLocations(){
        ParseClient.sharedInstance().getStudentLocations(){ (success, error) in
            performUIUpdatesOnMain {
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.setUp();
                    }
                } else {
                    self.displayAlert(error!)
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    func displayAlert(message:String){
        let alertView = UIAlertController(title: "Uh-Oh", message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
}
