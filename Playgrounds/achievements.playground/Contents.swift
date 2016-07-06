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

struct Solution {
    /**
     
     Achievements Solution
     You can find the solution playground in the Playgrounds directory of the course repository. Here are some highlights of things we did to solve the problems:
     
     Created Array and Dictionary to Determine Achievements in a Category
     
     One of the questions required us to determine the number of achievements belonging to the "Matchmaking" category. Since the "Matchmaking" category contains several children categories, we use an array to store the categoryIds:
     
     /* Create array to hold the categoryIds for "Matchmaking" categories */
     var matchmakingIds: [Int] = []
     
     /* Store all "Matchmaking" categories */
     for categoryDictionary in categoryDictionaries {
     
     if let title = categoryDictionary["title"] as? String where title == "Matchmaking" {
     
     guard let children = categoryDictionary["children"] as? [NSDictionary] else {
     print("Cannot find key 'children' in \(categoryDictionary)")
     return
     }
     
     for child in children {
     guard let categoryId = child["categoryId"] as? Int else {
     print("Cannot find key 'categoryId' in \(child)")
     return
     }
     matchmakingIds.append(categoryId)
     }
     }
     }
     Later, when browsing through achievements, we use a dictionary to count the number of achievements for all categoryIds:
     
     /* Create dictionary to store the counts for "Matchmaking" categories */
     var categoryCounts: [Int: Int] = [:]
     
     for achievementDictionary in achievementDictionaries {
     
     /* Add to category counts */
     guard let categoryId = achievementDictionary["categoryId"] as? Int else {
     print("Cannot find key 'categoryId' in \(achievementDictionary)")
     return
     }
     
     /* Does category have a key in dictionary? If not, initialize */
     if categoryCounts[categoryId] == nil {
     categoryCounts[categoryId] = 0
     }
     
     /* Add one to category count */
     if let currentCount = categoryCounts[categoryId] {
     categoryCounts[categoryId] = currentCount + 1
     }
     }
     
    */
}
