//
//  hearthstone.playground
//  iOS Networking
//
//  Created by Jarrod Parkes on 09/30/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation

/* Path for JSON files bundled with the Playground */
var pathForHearthstoneJSON = NSBundle.mainBundle().pathForResource("hearthstone", ofType: "json")

/* Raw JSON data (...simliar to the format you might receive from the network) */
var rawHearthstoneJSON = NSData(contentsOfFile: pathForHearthstoneJSON!)

/* Error object */
var parsingHearthstoneError: NSError? = nil

/* Parse the data into usable form */
var parsedHearthstoneJSON = try! NSJSONSerialization.JSONObjectWithData(rawHearthstoneJSON!, options: .AllowFragments) as! NSDictionary

func parseJSONAsDictionary(dictionary: NSDictionary) {
    print(dictionary)
    
    guard let cards = dictionary["Basic"] as? [[String : AnyObject]] else {
        print("Could not find value for key: Basic")
        return
    }
    
    let numberOfFiveDollarMinions = cards.filter {
        card in
        guard   let minion = card["type"] as? String where minion == "Minion",
                let cost = card["cost"] as? Int where cost == 5 else {
            return false
        }
        return true
    }.count
    print("\(numberOfFiveDollarMinions) minions have a cost of 5")
    
    let weaponsOfDurabilityTwo = cards.filter {
        card in
        guard   let weapon = card["type"] as? String where weapon == "Weapon",
                let durability = card["durability"] as? Int where durability == 2 else {
                return false
        }
        return true
    }.count
    print("\(weaponsOfDurabilityTwo) weapons have a durability of 2")
    
    let minionsWithBattleCry = cards.filter {
        card in
        guard   let minion = card["type"] as? String where minion == "Minion",
            let text = card["text"] as? String where text.containsString("Battlecry") else {
                return false
        }
        return true
    }.count
    
    print("\(minionsWithBattleCry) minions mention the 'Battlecry' effect in their text")
    
    let commonMinions = cards.filter {
        card in
        guard   let minion = card["type"] as? String where minion == "Minion",
            let common = card["rarity"] as? String where common == "Common" else {
                return false
        }
        return true
    }
    let averageCostOfCommonMinion = Double(commonMinions.reduce(0) {
        total, card in
        guard let cost = card["cost"] as? Int else {
            return total
        }
        return total + cost
    }) / Double(commonMinions.count)
    print("\(averageCostOfCommonMinion) is the average cost of a common minion.")
    
    var totalOfMinions: Double = 0.0
    let averageStatsToCostRatioMinions = cards.reduce(0.0) {
        total, card in
        guard   let minion = card["type"] as? String where minion == "Minion",
                let cost = card["cost"] as? Double where cost > 0,
                let attack = card["attack"] as? Double,
                let health = card["health"] as? Double
        else {
            print("Unable to cast as Double")
            return total
        }
        totalOfMinions += 1
        return total + ((attack + health) / cost)
    } / totalOfMinions
    print("\(averageStatsToCostRatioMinions) is the average stats-to-cost-ratio for all minions.")
}

parseJSONAsDictionary(parsedHearthstoneJSON)

struct Solution {
    
    /**
    Hearthstone Solution
    You can find the solution playground in the Playgrounds directory of the course repository. Here are some highlights of things we did to solve the problems:
    
    Creating Dictionaries with Key Values from an Array
    
    Since one of the questions requires us to calculate values based on card rarity, we used an array of known rarity keys to elegantly store calculations into dictionaries:
    
    let rarities = ["Free", "Common"]
    
    // initialization...
    for rarity in rarities {
    numCostForRarityItemsDictionary[rarity] = 0
    sumCostForRarityDictionary[rarity] = 0
    }
    Then, later in the code when we parse a card's rarity, we can easily add it to our running totals:
    
    guard let rarityForCard = cardDictionary["rarity"] as? String else {
    print("Cannot find key 'rarityForCard' in \(cardDictionary)")
    return
    }
    
    numCostForRarityItemsDictionary[rarityForCard]! += 1
    sumCostForRarityDictionary[rarityForCard]! += manaCost
    Creating an Array of Dictionaries
    
    Like in the previous exercise, we can use one line to create the array of dictionaries (card dictionaries) as seen in the JSON:
    
    guard let arrayOfBasicSetCardDictionaries = parsedHearthstoneJSON["Basic"] as? [[String:AnyObject]] else {
    print("Cannot find key 'Basic' in \(parsedHearthstoneJSON)")
    return
    } */
    
}
