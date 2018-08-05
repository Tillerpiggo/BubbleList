/*:
 ## Exercise: Argument Label

 Functions and their arguments should be named so that they read like a clear instruction when they’re called. To make this easier, you can give parameters two names - an _argument label_ to be used when calling the function and a _parameter name_ to be used within the function’s body.
*/

/*: 
 - callout(Exercise): Add an argument label to the function definition so it reads like this when you call it:\
 `let finalScore = score(withReds: 5, greens: 3, golds: 3)`
*/
func score(withReds reds: Int, greens: Int, golds: Int) -> Int {
    let pointsPerRed = 5
    let pointsPerGreen = 10
    let pointsPerGold = 30
    
    let redScore = reds * pointsPerRed
    let greenScore = greens * pointsPerGreen
    let goldScore = golds * pointsPerGold
    
    let finalScore = redScore + greenScore + goldScore
    
    return finalScore
}

let finalScore = score(withReds: 5, greens: 3, golds: 3)




//: [Previous](@previous)  |  page 16 of 17  |  [Next: Exercise: No Argument Label](@next)
