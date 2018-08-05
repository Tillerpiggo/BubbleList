/*:
 ## Exercise: Switch
 
 This enum represents targets that the player might hit in a game:
*/
enum Target {
    case red, green, blue, gold
}
//: This function returns a score given a particular target:
func score(target: Target) -> Int {
    switch target {
    case .red:
        return 10
    case .green:
        return 15
    case .blue:
        return 25
    case .gold:
        return 50
    }
}
//: - callout(Exercise): Update the `score(target:)` function to use a switch statement and return the correct score for each target. The statements below tell you the values to aim for:
score(target: .red)    // This should be 10
score(target: .green)  // This should be 15
score(target: .blue)   // This should be 25
score(target: .gold)   // This should be 50


// define game state
enum GameState {
    case start, win, lose, draw
}



// define 3 different signs playable
enum Sign {
    // define the 3 different signs
    case rock, paper, scissors
    
    // return the emoji each sign represents
    var emoji: String {
        switch self {
        case .rock:
            return "👊"
        case .paper:
            return "✌️"
        case .scissors:
            return "🖐"
        }
    }
    
    private var number: Int {
        switch self {
        case .rock:
            return 0
        case .scissors:
            return 1
        case .paper:
            return 2
        }
    }
    
    private func signFromInt(_ number: Int) -> Sign {
        switch number {
        case 0:
            return .rock
        case 1:
            return .scissors
        case 2:
            return .paper
        default:
            print("That Int does not match up with any known Sign, Signs are labeled from 0-2")
            return .paper
        }
        
    }
    
    // returns which sign a given sign beats
    private func beats(_ sign: Sign) -> Bool {
        let winNumber = (self.number + 1) % 3
        
        if sign.number == winNumber {
            return true
        } else {
            return false
        }
    }
    
    // returns which sign a given sign loses to
    private func losesTo(_ sign: Sign) -> Bool {
        let lossNumber = (self.number + 2) % 3
        
        if sign.number == lossNumber {
            return true
        } else {
            return false
        }
    }
    
    // returns which sign a given sign draws
    private func draws(_ sign: Sign) -> Bool {
        let drawNumber = self.number
        
        if sign.number == drawNumber {
            return true
        } else {
            return false
        }
    }
    
    func battles(_ sign: Sign) -> GameState {
        if self.beats(sign) {
            return .win
        } else if self.losesTo(sign) {
            return .lose
        } else if self.draws(sign) {
            return .draw
        } else {
            print("This is impossible! You can't NOT win, lose or draw!")
            return .start
        }
    }
}

let mySign = Sign.rock
mySign.battles(.rock)
mySign.battles(.paper)
mySign.battles(.scissors)


/*:
 
 _Copyright © 2017 Apple Inc._
 
 _Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:_
 
 _The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software._
 
 _THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE._
 */
//: [Previous](@previous)  |  page 21 of 21
