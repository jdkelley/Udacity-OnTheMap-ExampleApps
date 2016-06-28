//: Playground - noun: a place where people can play

import UIKit

func foo(x: Int) -> Int {
    return 42 + x
}

let bar = {(x: Int) -> Int
    in
    42 + x
}

// create a few functions, add them to an array and  call them
func curly(n: Int) -> Int{
    return n * n
}

func larry(x: Int) -> Int {
    return x * (x + 1)
}

func moe(m: Int) -> Int {
    return m*(m-1)*(m-2)
}
var stooges = [larry, curly, moe]
stooges.append(bar)

for stooge in stooges {
    stooge(42)
}

func baz(x:Int) -> Double {
    return Double(x) / 42
}


