/*:
 ## Exercise: Goals

Think of a goal of yours that can be measured in progress every day, whether it’s minutes spent exercising, number of photos sent to friends, hours spent sleeping, or number words written for your novel.

 - callout(Exercise): Create an array literal with 20 to 25 items of sample data for your daily activity. It may be something like `let milesBiked = [3, 7.5, 0, 0, 17 ... ]` Feel free to make up or embellish the numbers, but make sure you have entries that are above, below and exactly at the goal you've thought of. _Hint: Make sure to choose the right kind of array for your data, whether `[Double]` or `[Int]`._
*/
// array to store hours of overwatch played by Algee daily
let hoursOfOverwatch = [4, 2, 5, 4, 16, 12, 1]

// set goal
let goal = 5
//: - callout(Exercise): Write a function that takes the daily number as an argument and returns a message as a string. It should return a different message based on how close the number comes to your goal. You can be as ambitious and creative as you'd like with your responses, but make sure to return at least two different messages depending on your daily progress!
// gives feedback as to how well you're doing with your Overwatch withdrawal program, ALEX.
func printOverwatch(hours: Int) -> String {
    // determine how far off you were from your goal
    let goalDifference = hours - goal
    
    // stores response
    var response = ""
    
    if goalDifference > 0 {
        response = "(\(hours) hours) You're getting close! Just take a break once every hour and you shouldn't get TOO fat!"
    } else if goalDifference == 0 {
        response = "(\(hours) hours) Nice! You reached your goal to only play 5 hours of overwatch in a day!"
    } else {
        response = "(\(hours) hours) Amazing! You're actually practicing enough self control to not spend a third of your waking hours staring at a screen! Keep it up!"
    }
    
    return response
}


//: - callout(Exercise): Write a `for…in` loop that loops over your sample data, calls your function to get an appropriate message for each item, and prints the message to the console.
for dailyHours in hoursOfOverwatch {
    print(printOverwatch(hours: dailyHours) + "\n")
}




//: [Previous](@previous)  |  page 16 of 17  |  [Next: Exercise: Screening Messages](@next)
