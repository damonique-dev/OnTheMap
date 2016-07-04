//
//  Constants.swift
//  OnTheMap
//
//  Created by Damonique Thomas on 7/3/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    struct Constants {
        
        static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        static let AuthorizationURL : String = "https://www.udacity.com/api/session"
    }
    
    struct Methods {
        static let UserData = "/users/{user_id}"
    }
    
    struct JSONResponseKeys {
        static let Session = "session"
        static let ID = "id"
        static let Account = "account"
        static let UserID = "key"
    }
}