//
//  GooglePlacesAPI.swift
//  PA8
//
//  Created by Sophia Braun on 12/6/20.
//  Copyright © 2020 Rebekah Hale. All rights reserved.
//

import Foundation
import UIKit

struct GooglePlacesAPI {
    private static let apiKey = "AIzaSyCqr-r3261KQcBV7G_BT-HZyy7SBKdAoxs"
    static var input: String = ""
    static var latitude: String = ""
    static var longitude: String = ""
    
    static func googleNearBySearchesURL (input: String, latitude: String, longitude: String) -> URL {
        let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
            
        let params = [
            "key": GooglePlacesAPI.apiKey,
            "location": "\(latitude), \(longitude)",
            "radius": "1000",
            "keyword": "\(input)"
        ]
            
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
        
        
    static func googlePlaceDetailsURL (placeID: String) -> URL {
        let baseURL = "https://maps.googleapis.com/maps/api/place/details/json?"
            
        let params = [
            "key": GooglePlacesAPI.apiKey,
            "place_id": "\(placeID)",
            "fields": "place_id,name,vicinity,rating,photos[]"
        ]
            
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
        
    /*
    static func googlePlacePhotosURL (photoRefrence: String) -> URL {
        let baseURL = "https://maps.googleapis.com/maps/api/place/photo?"
            
        let params = [
            "key": GooglePlacesAPI.apiKey,
            "photoreference": "\(photoRefrence)",
            "maxwidth": "1600"
        ]
            
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
            
        var components = URLComponents(string: baseURL)!
        components.queryItems = queryItems
        let url = components.url!
        print(url)
        return url
    }*/
        
    static func fetchPlaces (completion: @escaping ([Place]?) -> Void) {
        let nearBySearchURL = GooglePlacesAPI.googleNearBySearchesURL(input: input, latitude: latitude, longitude: longitude)
              
        let task = URLSession.shared.dataTask(with: nearBySearchURL) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
                print("we got data!!!")
                print(dataString)
                    
                if let places = places(fromData: data) {
                    print("we got an [InterestingPhoto] with \(places.count) photos")
                    DispatchQueue.main.async {
                        completion(places)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            else {
                if let error = errorOptional {
                    print("Error getting data \(error)")
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
        
    static func places (fromData data: Data) -> [Place]? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            /*guard let jsonDictionary = jsonObject as? [String: Any], let placesObject = jsonDictionary["html_attributions"] as? [String: Any], let placesArray = placesObject["results"] as? [[String: Any]] else {
                    print("Error parsing JSON")
                    return nil
            }*/
            guard let jsonDictionary = jsonObject as? [String: Any], let placesArray = jsonDictionary["results"] as? [[String: Any]] else {
                    print("Error parsing JSON")
                    return nil
            }
            print("successfully got placesArray")
            var places = [Place]()
            for placeObject in placesArray {
                if let place = place(fromJSON: placeObject) {
                    places.append(place)
                }
            }
            if !places.isEmpty {
                return places
            }
        }
        catch {
            print("Error converting Data to JSON \(error)")
        }
              
        return nil
    }
        
    static func place (fromJSON json: [String: Any]) -> Place? {
        guard let id = json["place_id"] as? Int, let name = json["name"] as? String, let vicinity = json["vicinity"] as? String, let rating = json["rating"] as? Int, let photoURL = json["photo_reference"] as? String else {
                return nil
            }
        return Place(ID: id, name: name, vicinity: vicinity, rating: rating, photoRefrence: photoURL)
    }
          
    static func fetchImage (fromURLString urlString: String, completion: @escaping (UIImage?) -> Void) {
        let url = URL(string: urlString)!
              
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            else {
                if let error = errorOptional {
                    print("error fetching image \(error)")
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
}
