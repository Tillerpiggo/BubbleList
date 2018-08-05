/*:
  ## Exercise: Your Own Structure
 When you worked through the Types playground, you had a chance to think about some real-world examples of types and the associated types they might depend on. A `TrainingShoe` type, for example, might have a `size` property that's an `Int`, a `brandName` that's a `String`, and a `releaseDate` that's a `Date`.

 - callout(Exercise):
 Think of another real-world object and its properties. Make up some actions or behaviors that the object might be able to perform. Write them all in plain English first in a comment:
 */
 // Add your English-language description of the type here. Make sure to add // before each line of your comment description.
 // MaxWorkoutStats
 // rotationSpeed
 // heartRate
 // caloriesBurned
 // duration
 // elapsedTime
 // workoutName
 // score
/*:
 - callout(Exercise):
 Using the `struct` syntax from this lesson, create a type for your real-world object with the properties and methods you thought of. Remembering to mark each property with `let` or `var` depending on whether or not it will be allowed to change. If you're not sure how to implement the body of one of the methods, describe what the method should do in a comment.\
 *Hint: If you made any properties with custom types, you can create placeholder types that have empty implementations. (See the TrainingShoe code at the bottom of this page for an example.) The placeholder type below will make sure your playground can run without errors.*
 */
// Add your own struct here:
struct MaxWorkoutStats {
    // rotation speed of the wheel (rpm)
    var rotationSpeed: Int
    
    // heart rate of the user (beats per minute)
    var heartRate: Int
    
    // calories burned so far by the user
    var caloriesBurned: Int
    
    // duration of the workout
    let duration: Int
    
    // how long the user has been doing the workout
    var elapsedTime: Int
    
    // the name of the workout
    let workoutName: String
    
    // the current score of the user
    var score: Int {
        // the score is the rotation speed + the heart rate + the calories burned
        return (rotationSpeed + heartRate + caloriesBurned)
    }
}





/*:
 - callout(Exercise):
 Use the struct you created to make a new instance of your type.

 */
var workout = MaxWorkoutStats(rotationSpeed: 0, heartRate: 70, caloriesBurned: 0, duration: 840, elapsedTime: 0, workoutName: "MAX 14 Minute Interval")

/*:
 - note: Here's an example of a placeholder type used for making a TrainingShoe:
 */
// Placeholder type
struct Shoelaces {

}

struct TrainingShoe {
    let size: Int
    var isTied: Bool
    var laces: Shoelaces

    func squeak() {
        // Make a loud noise like rubber squealing on a gym floor
    }

    func warnAboutLaces() {
        // If laces are untied, print a reminder to tie them
    }
}

// Create an instance of the placeholder type
let newLaces = Shoelaces()

// Use the instance of the placeholder type to create an instance of your new type
let newShoe = TrainingShoe(size: 39, isTied: true, laces: newLaces)





/*:
 
 _Copyright © 2017 Apple Inc._
 
 _Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:_
 
 _The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software._
 
 _THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE._
 */
//: [Previous](@previous)  |  page 9 of 9
