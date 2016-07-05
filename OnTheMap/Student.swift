//
//  Student.swift
//  OnTheMap
//
//  Created by Damonique Thomas on 7/3/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import Foundation

struct Student {
    let objectID: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let lat: Float
    let lng: Float
    
    init(dictionary: [String:AnyObject]) {
        objectID = dictionary[ParseClient.JSONResponseKeys.ObjectID] as! String
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String
        firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
        mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as! String
        lat = dictionary[ParseClient.JSONResponseKeys.Lat] as! Float
        lng = dictionary[ParseClient.JSONResponseKeys.Long] as! Float
    }
    
    static func studentsFromResults(results: [[String:AnyObject]]) -> [Student] {
        
        var students = [Student]()
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            students.append(Student(dictionary: result))
        }
        
        return students
    }
}