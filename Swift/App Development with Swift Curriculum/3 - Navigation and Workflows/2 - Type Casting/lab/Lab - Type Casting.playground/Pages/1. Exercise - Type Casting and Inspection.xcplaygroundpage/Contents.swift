/*:
 ## Exercise - Type Casting and Inspection
 
 Create a collection of type [Any], including a few doubles, integers, strings, and booleans within the collection. Print the contents of the collection.
 */
var anyArray: [Any] = [0.7, 0.4, "Hello", "yeet", false, true, 5]
print("Heterogenous Array: \(anyArray)")

/*:
 Loop through the collection. For each integer, print "The integer has a value of ", followed by the integer value. Repeat the steps for doubles, strings and booleans.
 */
for object in anyArray {
    if let int = object as? Int {
        print("The integer has a value of \(int)")
    } else if let double = object as? Double {
        print("The double has a value of \(double)")
    } else if let string = object as? String {
        print("The string has a value of \(string)")
    } else if let bool = object as? Bool {
        print("The boolean has a value of \(bool)")
    }
}

/*:
 Create a [String : Any] dictionary, where the values are a mixture of doubles, integers, strings, and booleans. Print the key/value pairs within the collection
 */
var anyDictionary: [String: Any] = ["Pi": 3.14159, "My Grades": "Fine", "The number of times I've been productive today": 0, "Apple > Microsoft": true]
print(anyDictionary)
/*:
 Create a variable `total` of type `Double` set to 0. Then loop through the dictionary, and add the value of each integer and double to your variable's value. For each string value, add 1 to the total. For each boolean, add 2 to the total if the boolean is `true`, or subtract 3 if it's `false`. Print the value of `total`.
 */
var total: Double = 0

for (_, value) in anyDictionary {
    if let int = value as? Int {
        total += Double(int)
    } else if let double = value as? Double {
        total += double
    } else if let _ = value as? String {
        total += 1
    } else if let bool = value as? Bool {
        if bool {
            total += 2
        } else {
            total -= 3
        }
    }
}

print("Total: \(total)")

/*:
 Create a variable `total2` of type `Double` set to 0. Loop through the collection again, adding up all the integers and doubles. For each string that you come across during the loop, attempt to convert the string into a number, and add that value to the total. Ignore booleans. Print the total.
 */
var total2: Double = 0

for (_, value) in anyDictionary {
    if let int = value as? Int {
        total2 += Double(int)
    } else if let double = value as? Double {
        total2 += double
    } else if let string = value as? String {
        if let numberFromString = Double(string) {
            total2 += numberFromString
        }
    }
}

print("Total2: \(total2)")

//: page 1 of 2  |  [Next: App Exercise - Workout Types](@next)
