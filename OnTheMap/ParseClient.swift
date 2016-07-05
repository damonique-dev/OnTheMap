//
//  Client.swift
//  OnTheMap
//
//  Created by Damonique Thomas on 7/3/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    var session = NSURLSession.sharedSession()
        
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    //Get all student locations from API
    func getStudentLocations(completionHandler: (success: Bool, error: String?) -> Void){
        let parameters = [ParameterKeys.Limit:"100", ParameterKeys.Order:"-updatedAt"]
        let request = NSMutableURLRequest(URL: URLFromParameters(parameters, withPathExtension: Methods.StudentLocations))
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func sendError(error: String) {
                print(error)
                completionHandler(success: false, error: error)
            }
            
            //Error Checking
            guard (error == nil) else {
                sendError("Failed to connect to server.")
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Unsuccessful GET")
                return
            }
            guard let data = data else {
                sendError("No Data")
                return
            }
            
            //Parse JSON
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError( "Failed parsing json")
                return
            }
            
            //Attempt to get student data
            if let results = parsedResult[JSONResponseKeys.Results] as? [[String:AnyObject]] {
                GlobalVariables.students = Student.studentsFromResults(results)
            } else {
                sendError("Failed getting user data")
                return
            }
            completionHandler(success: true, error: nil)
        }
        task.resume()
    }
    
    //Queries API to see if user has existing posted location
    func queryForStudentLocation(completionHandler: (success: Bool, result: [Student]?, error: String?) -> Void){
        let path = "?where=%7B%22uniqueKey%22%3A%22\(GlobalVariables.userID!)%22%7D"
        let url = NSURL(string: Constants.GetURL + path)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func sendError(error: String) {
                print(error)
                completionHandler(success: false, result: nil, error: error)
            }
            
            //Error Checking
            guard (error == nil) else {
                sendError("Failed to connect to server.")
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Unsuccessful GET")
                return
            }
            guard let data = data else {
                sendError("No Data")
                return
            }
            
            //Parse JSON
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError( "Failed parsing json")
                return
            }
            
            //Attempt to get student location
            var userLocation: [Student]
            if let results = parsedResult[JSONResponseKeys.Results] as? [[String:AnyObject]] {
                userLocation = Student.studentsFromResults(results)
            } else {
                sendError("Failed getting user data")
                return
            }
            completionHandler(success: true, result: userLocation, error: nil)
        }
        task.resume()
    }
    
    func postStudentLocation(student:[String:AnyObject], completionHandler: (success: Bool, error: String?) -> Void){
        var request = NSMutableURLRequest()
        request = requestValues(request)
        request.URL = NSURL(string: Constants.GetURL)!
        request.HTTPMethod = "POST"
        request.HTTPBody = "{\"uniqueKey\": \"\(student[JSONResponseKeys.UniqueKey]!)\", \"firstName\": \"\(student[JSONResponseKeys.FirstName]!)\", \"lastName\": \"\(student[JSONResponseKeys.LastName]!)\",\"mapString\": \"\(student[JSONResponseKeys.MapString]!)\", \"mediaURL\": \"\(student[JSONResponseKeys.MediaURL]!)\",\"latitude\": \(student[JSONResponseKeys.Lat]!), \"longitude\": \(student[JSONResponseKeys.Long]!)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func sendError(error: String) {
                print(error)
                completionHandler(success: false, error: error)
            }
            
            //Error Checking
            guard (error == nil) else {
                sendError("Failed to connect to server.")
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Unable to Post Location")
                return
            }

            completionHandler(success: true, error: nil)
        }
        task.resume()
    }
    
    func updateStudentLocation(student:Student, completionHandler: (success: Bool, error: String?) -> Void){
        let url = NSURL(string: Constants.GetURL + "/\(student.objectID)")
        var request = NSMutableURLRequest()
        request = requestValues(request)
        request.URL = url
        request.HTTPMethod = "PUT"
        request.HTTPBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.lat), \"longitude\": \(student.lng)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func sendError(error: String) {
                print(error)
                completionHandler(success: false, error: error)
            }
            
            //Error Checking
            guard (error == nil) else {
                sendError("Failed to connect to server.")
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Unable to Update Location")
                return
            }
            
            completionHandler(success: true, error: nil)
        }
        task.resume()

    }
    
    // create a URL from parameters
    private func URLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = ParseClient.Constants.ApiScheme
        components.host = ParseClient.Constants.ApiHost
        components.path = ParseClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    //Adds values and HTTP body to request for the put and post location calls
    func requestValues(request: NSMutableURLRequest)->NSMutableURLRequest {
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    //substitute the key for the value that is contained within the method name
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
}