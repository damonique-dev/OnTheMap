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

        // Do any additional setup after loading the view.
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
        
    }
    
    @IBAction func pinPressed(sender: AnyObject) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func completeLogout() {
        print("Logout successful")
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
