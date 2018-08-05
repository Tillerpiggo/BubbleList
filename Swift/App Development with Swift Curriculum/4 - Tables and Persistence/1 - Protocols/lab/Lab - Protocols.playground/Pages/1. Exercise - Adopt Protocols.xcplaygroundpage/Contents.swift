/*:
 ## Exercise - Adopt Protocols: CustomStringConvertible, Equatable, and Comparable
 
 Create a `Human` class with two properties: `name` of type `String`, and `age` of type `Int`. You'll need to create a memberwise initializer for the class. Initialize two `Human` instances.
 */
class Human: CustomStringConvertible, Equatable, Comparable, Codable {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    // Protocol stubs:
    
    static func == (lhs: Human, rhs: Human) -> Bool {
        let hasSameName = lhs.name == rhs.name
        let hasSameAge = lhs.age == rhs.age
        
        let isEqual = hasSameName && hasSameAge
        
        return isEqual
    }
    
    var description: String {
        let description = "Human(name: \(name), age: \(age))"
        return description
    }
    
    static func < (lhs: Human, rhs: Human) -> Bool {
        // Sort the humans by their name, so use String comparisons (alphabetical order)
        return lhs.name < rhs.name
    }
}

let myHuman = Human(name: "Tyler", age: 14)
let brother = Human(name: "Alex", age: 14)
/*:
 Make the `Human` class adopt the `CustomStringConvertible`. Print both of your previously initialized `Human` objects.
 */
print(myHuman)
print(brother)
/*:
 Make the `Human` class adopt the `Equatable` protocol. Two instances of `Human` should be considered equal if their names and ages are identical to one another. Print the result of a boolean expression evaluating whether or not your two previously initialized `Human` objects are equal to eachother (using `==`). Then print the result of a boolean expression evaluating whether or not your two previously initialized `Human` objects are not equal to eachother (using `!=`).
 */
print("These humans are equal to each other: \(myHuman == brother)")
print("These humans are not the same: \(myHuman != brother)")
/*:
 Make the `Human` class adopt the `Comparable` protocol. Sorting should be based on age. Create another three instances of a `Human`, then create an array called `people` of type `[Human]` with all of the `Human` objects that you have initialized. Create a new array called `sortedPeople` of type `[Human]` that is the `people` array sorted by age.
 */
let people = [myHuman, brother]

let sortedPeople = people.sorted(by: <)
print(sortedPeople)

/*:
 Make the `Human` class adopt the `Codable` protocol. Create a `JSONEncoder` and use it to encode as data one of the `Human` objects you have initialized. Then use that `Data` object to initialize a `String` representing the data that is stored, and print it to the console.
 */
import Foundation

let jsonEncoder = JSONEncoder()

let data = try? jsonEncoder.encode(myHuman)
if let stringRepresentation = data?.base64EncodedString() {
    print(stringRepresentation)
}

//: page 1 of 5  |  [Next: App Exercise - Printable Workouts](@next)
