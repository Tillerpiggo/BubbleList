//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


func factorial(_ n: Int) -> Int {
    if n > 1 {
        return n * factorial(n - 1)
    } else {
        return 1
    }
}

func choose(_ n: Int, _ r: Int) -> Int {
    let permutations = factorial(n) / (factorial(r) * factorial(n - r))
    return permutations
}

func numberOfWays(steps: Int) -> Int {
    // Returns the number of ways to climb a set of stairs wtih n steps and 1 or 2 steps at a time
    // This is the same as the number of ways you can add 1 and 2 to get a number times the number of ways to arrange each possibility
    var numberOfWays: Int = 0
    
    // Calculate the number of ways you can use 2 steps
    let maxNumberOfDoubleSteps: Int = steps / 2
    
    // The remaining steps would be filled with 1s
    
    // For every way you can take 2 steps at a time, you can rearrange them in any order
    // Use the choose function
    
    // Create an array of all the number of double steps you can take
    var permutationArray = [Int]()
    
    for doubleSteps in 0...maxNumberOfDoubleSteps {
        permutationArray.append(choose(steps - doubleSteps, doubleSteps))
    }
    
    for numberOfPermutations in permutationArray {
        numberOfWays += numberOfPermutations
    }
    
    return numberOfWays
}

numberOfWays(steps: 5)

