//
//  Constants.swift
//  OnTheMap
//
//  Created by Damonique Thomas on 7/3/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import Foundation

extension ParseClient {

    struct Constants {
        static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let AppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1"
        static let GetURL = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    struct Methods {
        static let StudentLocations = "/classes/StudentLocation"
        static let UpdateStudentLocation = "/classes/StudentLocation/{objectId}"
    }
    
    struct ParameterKeys {
        static let Limit = "limit"
        static let Order = "order"
    }
    
    struct JSONResponseKeys {
        static let Results = "results"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let MediaURL = "mediaURL"
        static let MapString = "mapString"
        static let Lat = "longitude"
        static let Long = "latitude"
    }

}