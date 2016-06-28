//: Playground - noun: a place where people can play

import UIKit

typealias Integer = Int
typealias int = Int

let a: Integer = 1
let b: int = 2
let c = 1+2

typealias IntToInt = (Int) -> Int

typealias IntMaker = (Void)->Int

func makeCounter() -> IntMaker {
    var n = 0
    
    func adder() -> Int {
        n = n + 1
        return n
    }
    
    return adder
}

// each closure has a copy of all the captured variables
