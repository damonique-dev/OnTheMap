//
//  StudentTableViewController.swift
//  OnTheMap
//
//  Created by Damonique Thomas on 7/3/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import UIKit

class StudentTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return GlobalVariables.students.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell", forIndexPath: indexPath)
        let student = GlobalVariables.students[indexPath.row]
        cell.textLabel?.text = student.firstName + " " + student.lastName
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = GlobalVariables.students[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)
    }
    
    func displayAlert(message:String){
        let alertView = UIAlertController(title: "Uh-Oh", message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }

}
