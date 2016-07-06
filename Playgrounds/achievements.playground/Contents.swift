//
//  achievements.playground
//  iOS Networking
//
//  Created by Jarrod Parkes on 09/30/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation

/* Path for JSON files bundled with the Playground */
var pathForAchievementsJSON = NSBundle.mainBundle().pathForResource("achievements", ofType: "json")

/* Raw JSON data (...simliar to the format you might receive from the network) */
var rawAchievementsJSON = NSData(contentsOfFile: pathForAchievementsJSON!)

/* Error object */
var parsingAchivementsError: NSError? = nil

/* Parse the data into usable form */
var parsedAchievementsJSON = try! NSJSONSerialization.JSONObjectWithData(rawAchievementsJSON!, options: .AllowFragments) as! NSDictionary

func parseJSONAsDictionary(dictionary: NSDictionary) {
   
    //print(dictionary)
    
    // Acheivements greater than 10
    // Average points for acheivements
    // which mission acheivement description has Cool Running
    // For category "Matchmaking" which acheivements have that categoryID
    guard   let categories = dictionary["categories"] as? [[String:AnyObject]],
            let achievements = dictionary["achievements"] as? [[String:AnyObject]] else {
        print("Could not find 'categories' or 'achievements' in \(dictionary)")
        return
    }
    
    var matchmakingCategoryList = [Int]()
    let matchmakingCategory = categories.filter {
        category in
        guard let matchmaking = category["title"] as? String where matchmaking == "Matchmaking" else {
            return false
        }
        return true
    }[0]

    guard let children = matchmakingCategory["children"] as? [[String: AnyObject]] else {
        return
    }
    
    children.forEach {
        guard let id = $0["categoryId"] as? Int else {
            return
        }
        matchmakingCategoryList.append(id)
    }

    var achievementsHigherThanTen: Int = 0
    var averageAchievementPointsTotal: Int = 0
    var numForAverage: Int = 0
    var missionForCoolRunning: String = ""
    var achievementsInMatchmaking: Int = 0
    
    for achievement in achievements {
        guard   let points = achievement["points"] as? Int,
                let category = achievement["categoryId"] as? Int,
                let description = achievement["description"] as? String,
                let title = achievement["title"] as? String
            else {
                print("could not find 'points','categoryId', or 'description' in \(achievement)")
                continue
        }
        
        if points > 10 {
            achievementsHigherThanTen += 1
        }
        
        if matchmakingCategoryList.contains(category) {
            achievementsInMatchmaking += 1
        }
        
        if title.containsString("Cool Running") {
            missionForCoolRunning = description
        }
        averageAchievementPointsTotal += points
        numForAverage += 1
        
    }
    
    print("There are \(achievementsHigherThanTen) achievements with points higher than 10.")
    print("The average achievement points is: \(Double(averageAchievementPointsTotal)/Double(numForAverage))")
    print("The description for the 'Cool Running' achievement is '\(missionForCoolRunning)'")
    print("The number of matchmaking achievements is: \(achievementsInMatchmaking)")
}

parseJSONAsDictionary(parsedAchievementsJSON)
