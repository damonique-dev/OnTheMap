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
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
//    func taskForGETMethod(method: String, parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
//        
//        
//
//    }
    
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
                sendError("There was an error with your request: \(error)")
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Failure to connect - status")
                return
            }
            guard let data = data else {
                sendError("Failure to connect - data")
                return
            }
            //Parse JSON
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                sendError( "Failure to connect - json")
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
    
//    func taskForDELETEMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
//    }
    
    // create a URL from parameters
    private func URLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
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