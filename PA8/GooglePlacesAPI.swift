//
//  GooglePlacesAPI.swift
//  PA8
//
//  Created by Sophia Braun on 12/6/20.
//  Copyright © 2020 Rebekah Hale. All rights reserved.
//

import Foundation

struct GooglePlacesAPI {
    private static let apiKey = "AIzaSyCqr-r3261KQcBV7G_BT-HZyy7SBKdAoxs"
    static var latitude: Double = 0.0
    static var longitude: Double = 0.0
    
    // the first thing we wanna do is construct or flickr.interestingness.getList url request for data
    static func GooglePlacesURL(input: String) -> URL {
        let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        // first lets define our query parameters
        let params = [
            "key": GooglePlacesAPI.apiKey,
            "latitude": "\(latitude)",
            "longitude": "\(longitude)",
            "radius": "1000",
            "keyword": "\(input)"
        ]
        // now we need to get the params into a url with the base ulr
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
            
        }
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = queryItems
        let url = components.url!
        print(url)
        return url
        
    }
    
    // lets define a function to make the request using the url we just constructed
    static func fetchPlaces(input: String) {
        let url = GooglePlacesAPI.GooglePlacesURL(input: input)
        
        // we need to make a request to the Flickr API server using the url
        // we will get back a JSON response (if all goes well)
        // we will make the request on a background thread using a data task
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
    // this closure executes later...
    // when the task has received a response from the server
    // we want to grab the Data object that represents the JSON response (if there is one)
    if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
    print("we got data!!!")
    print(dataString)
    
}
    else {
    if let error = errorOptional {
    print("Error getting data \(error)")
    
            }
    
    }
    
}
        // by default tasks are created in the suspended state
        // call resume() to start the tas
        task.resume()
        
    }
}
