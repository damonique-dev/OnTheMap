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
        //load()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        load()
    }
    
    @IBAction func pinPressed(sender: AnyObject) {
        let object: AnyObject = self.storyboard!.instantiateViewControllerWithIdentifier("postPinNavVC")
        let controller = object as! UINavigationController
        navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
    
    func getStudentLocations(){
        ParseClient.sharedInstance().getStudentLocations(){ (success, error) in
            performUIUpdatesOnMain {
                if !success {
                    self.displayAlert(error!)
                } 
            }
        }
    }
    
    func load(){
        let map = self.viewControllers![0] as! MapViewController
        let table = self.viewControllers![1] as! StudentTableViewController
        getStudentLocations()
        map.reload()
        table.reload()
    }
    
    private func completeLogout() {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("loginVC") 
        UdacityClient.sharedInstance().sessionID = ""
        UdacityClient.sharedInstance().userID = ""
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func displayAlert(message:String){
        let alertView = UIAlertController(title: "Uh-Oh", message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }

}
