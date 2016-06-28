//: Playground - noun: a place where people can play

import UIKit

// assign to var or constant
let f = { (x: Int) -> Int
    in
    return x + 42
}

f(1)
f(42)

// Closures in an array (or a dictionary, or a set, etc...)
let closures = [f,
                {(x: Int) -> Int in return x * 2},
                {(x: Int) in return x - 8},
                {(x: Int) in return x * x},
                {$0 * 42}
]

closures[0](1)
for f in closures {
    f(1)
}

let altClosures = [
    {$0 * 2.0}
]

let deepThought = {(question: String) in
    return "The answer to \"\(question)\" is \(7 * 6)!"}