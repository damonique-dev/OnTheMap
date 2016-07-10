//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Damonique Thomas on 7/3/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentLocations()
    }

    @IBAction func logoutPressed(sender: AnyObject) {
        UdacityClient.sharedInstance().deleteSession(){ (success, error) in
            performUIUpdatesOnMain {
                if success {
                    self.completeLogout()
                } else {
                    self.displayAlert(error!)
                }
            }
        }

    }

    @IBAction func refreshPressed(sender: AnyObject) {
        getStudentLocations()
    }
    
    @IBAction func pinPressed(sender: AnyObject) {
        ParseClient.sharedInstance().queryForStudentLocation(){ (success, result, error) in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.overrideLocation(result!)
                }
            } else {
                self.displayAlert(error!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
    }
    
    func getStudentLocations(){
        ParseClient.sharedInstance().getStudentLocations(){ (success, error) in
            performUIUpdatesOnMain {
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        let map = self.viewControllers![0] as! MapViewController
                        map.setUp()
                    }
                } else {
                    self.displayAlert(error!)
                }
            }
        }
    }
    
    private func completeLogout() {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("loginVC") 
        GlobalVariables.sessionID = ""
        GlobalVariables.userID = ""
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func displayAlert(message:String){
        let alertView = UIAlertController(title: "Uh-Oh", message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    func overrideLocation(result:[Student]){
        if result.count > 0 {
            let message = "There already exists a location for you. Would you like to override it?"
            let alertView = UIAlertController(title: "Uh-Oh", message: message, preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "Override", style: .Default){ _ in
                let object: AnyObject = self.storyboard!.instantiateViewControllerWithIdentifier("postPinNavVC")
                let controller = object as! UINavigationController
                let pinController = controller.topViewController as! PostPinViewController
                pinController.result = result
                self.navigationController!.presentViewController(controller, animated: true, completion: nil)
                })
            alertView.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            presentViewController(alertView, animated: true, completion: nil)
        } else {
            let object: AnyObject = self.storyboard!.instantiateViewControllerWithIdentifier("postPinNavVC")
            let controller = object as! UINavigationController
            self.navigationController!.presentViewController(controller, animated: true, completion: nil)
        }
    }
}
