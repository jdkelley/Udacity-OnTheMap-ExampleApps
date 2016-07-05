//
//  Constants.swift
//  SleepingInTheLibrary
//
//  Created by Joshua Kelley on 6/30/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

class FlickrClient {
    
    
    
    
    //struct API {
        static let BaseURL : String = "https://api.flickr.com/services/rest"
        
        struct Parameter {
            struct Key {
                static let Method = "method"
                static let APIKey = "api_key"
                static let GalleryID = "gallery_id"
                static let Extras = "extras"
                static let Format = "format"
                static let NoJSONCallback = "nojsoncallback"
            }
            struct Value {
                static let APIKey = "5e0d2a9f967ab9c653517e593f74d203"
                static let ResponseFormat = "json"
                static let DisableJSONCallback = "1" // 1 -> "yes"
                static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
                static let GalleryID = "5704-72157622566655097"
                static let MediumURL = "url_m"
            }
        }
        
        struct Response {
            struct Key {
                static let Status = "stat"
                static let Photos = "photos"
                static let Photo = "photo"
                static let Title = "title"
                static let MediumURL = "url_m"
            }
            
            struct Value {
                static let OKStatus = "ok"
            }
        }
//    }
}