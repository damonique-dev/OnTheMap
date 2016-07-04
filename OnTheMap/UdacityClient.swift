//
//  Client.swift
//  OnTheMap
//
//  Created by Damonique Thomas on 7/3/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {

    var session = NSURLSession.sharedSession()
    
    var sessionID : String? = nil
    var userID : String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    //Creates a session using the Udacity API
    func createSession(username: String, password:String, completionHandler: (success: Bool, error: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.AuthorizationURL)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
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
                sendError("Incorrect Email/Password")
                return
            }
            guard let data = data else {
                sendError("data")
                return
            }
            
            //Parse JSON
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                sendError( "Failed parsing json")
                return
            }
            
            //Attempt to get userID
            if let account = parsedResult[JSONResponseKeys.Account] {
                if let userID = account![JSONResponseKeys.UserID]{
                    self.userID = userID! as? String
                } else {
                    sendError("Incorrect Email/Password-account")
                    return
                }
            } else {
                sendError("Incorrect Email/Password-account")
                return
            }
            
            //Attempt to get sessionID
            if let session = parsedResult[JSONResponseKeys.Session] {
                if let sessionID = session![JSONResponseKeys.ID]{
                    self.sessionID = sessionID! as? String
                } else {
                    sendError("Incorrect Email/Password-session")
                    return
                }
            } else {
                sendError("Incorrect Email/Password-session")
                return
            }
            completionHandler(success: true, error: nil)
            
        }
        task.resume()
    }
    
    //Deletes the session using the Udacity API
    func deleteSession(completionHandler: (success: Bool, error: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.AuthorizationURL)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                completionHandler(success: false, error: error)
            }
            
            //Error Checking
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Failure to connect - status")
                return
            }
            completionHandler(success: true, error: nil)
        }
        task.resume()
    }
    
    //Gets users public data using the Udacity API
    func getUserData(completionHandler: (success: Bool, error: String?) -> Void) {
        
        var mutableMethod: String = Methods.UserData
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: URLKeys.UserID, value: String(userID!))!
        let request = NSMutableURLRequest(URL: URLFromParameters(mutableMethod))
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
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                sendError( "Failed parsing json")
                return
            }
            //Attempt to get user
            if let user = parsedResult[JSONResponseKeys.User] {
                if let last = user![JSONResponseKeys.LastName], first = user![JSONResponseKeys.FirstName] {
                    self.lastName = last! as? String
                    self.firstName = first! as? String
                } else {
                    sendError("Failed getting First/Last Name")
                    return
                }
            } else {
                sendError("Failed getting user data")
                return
            }
            completionHandler(success: true, error: nil)
            
        }
        task.resume()
    }
    // create a URL from parameters
    private func URLFromParameters(withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = ParseClient.Constants.ApiScheme
        components.host = ParseClient.Constants.ApiHost
        components.path = ParseClient.Constants.ApiPath + (withPathExtension ?? "")
        
        return components.URL!
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