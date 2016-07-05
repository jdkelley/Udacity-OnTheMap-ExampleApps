//
//  animals.playground
//  iOS Networking
//
//  Created by Jarrod Parkes on 09/30/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation

/* Path for JSON files bundled with the Playground */
var pathForAnimalsJSON = NSBundle.mainBundle().pathForResource("animals", ofType: "json")

/* Raw JSON data (...simliar to the format you might receive from the network) */
var rawAnimalsJSON = NSData(contentsOfFile: pathForAnimalsJSON!)

/* Error object */
var parsingAnimalsError: NSError? = nil

/* Parse the data into usable form */
var parsedAnimalsJSON = try! NSJSONSerialization.JSONObjectWithData(rawAnimalsJSON!, options: .AllowFragments) as! NSDictionary
print(parsedAnimalsJSON)

func parseJSONAsDictionary(dictionary: NSDictionary) {
    guard let photosDictionary = dictionary["photos"] as? [String: AnyObject] else {
        return
    }
    guard let total = photosDictionary["total"] as? Int else {
        return
    }
    guard let photoArray = photosDictionary["photo"] as? [AnyObject] else {
        return
    }
    print("Count by objects: \(photoArray.count)")
    print("Count by kvp: \(total)")
}

parseJSONAsDictionary(parsedAnimalsJSON)
