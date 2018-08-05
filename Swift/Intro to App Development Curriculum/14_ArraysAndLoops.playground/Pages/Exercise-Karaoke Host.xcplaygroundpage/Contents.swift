/*:
 ## Exercise: Karaoke Host

 You have a friend who loves singing karaoke with a big group of people. The karaoke singers add songs they’d like to sing to a list and the karaoke host calls out the songs one by one. 
 
 Your friend and has asked you to write software to help manage the song list.

 - callout(Exercise):
 Create an empty array to hold song titles as strings, and use the `append` method to add three or four songs one at a time.
 */
// create an array to store songs
var songArray = [String]()

// fill the array
songArray.append("Yee")
songArray.append("The High Ground (Remix)")
songArray.append("It's Everyday, Bro (with that Disney Channel flow)")


/*:
 - callout(Exercise):
 One enthusiastic singer wants to add three songs at once. Create an array holding this one singer's song list and use the `+=` operator to append their whole list to the end of the group's song list.
 */
songArray += ["song1", "song2", "song3"]




/*:
 - callout(Exercise):
 Write a `for…in` loop and, for every song title in the array, print an encouraging announcement to let the next singer know that it's their turn.
 */
// give an encouraging statement to the next person, informing them of the song
for song in songArray {
    print("Ok, the next singer is up! You're going to be singing the latest hit, \"\(song)\"!")
}





/*:
 - callout(Exercise):
 After the loop has called everyone up to sing, use the `removeAll` method on the song list to clear out all the past songs.
 */
// remove all songs from songArray
songArray.removeAll()



//: [Previous](@previous)  |  page 14 of 17  |  [Next: Exercise: Counting Votes](@next)
