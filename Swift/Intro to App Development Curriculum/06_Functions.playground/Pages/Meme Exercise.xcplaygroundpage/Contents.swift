/*:
 ## Functional Meme
 
 Think of a fun song or meme that you've heard or seen recently. Try to think of one with repetitive parts. For example:
 
 - A song with a repeated chorus.
 - A meme that repeats a word or phrase.
 - A song that repeats a line over and over.
 
 Write out the song or meme using `print` statements, then look for patterns and repetition and choose groups of lines to combine into functions. This is a free-form exercise, so you can do whatever you like.
*/
print("He attac")
print("He protec")
print("But most importantly, he respec")
print("")
print("He attac")
print("He protec")
print("But most importantly, he deflec")
print("")
print("He attac")
print("He protec")
print("But most importantly, he rec")

//define functions to attac, protec, and \(verb ending with c)
func attacProtec() {
    print("He attac")
    print("He protec")
}

func spaceBetweenLines() {
    print("")
}

func respec() {
    let verb = "respec"
    print("But most importantly, he \(verb)")
}

func deflec() {
    let verb = "deflec"
    print("But most importantly, he \(verb)")
}

func rec() {
    let verb = "rec"
    print("But most importantly, he \(verb)")
}

func verseOne() {
    attacProtec()
    respec()
}

func verseTwo() {
    attacProtec()
    deflec()
}

func verseThree() {
    attacProtec()
    rec()
}

//run the meme
verseOne()
spaceBetweenLines()
verseTwo()
spaceBetweenLines()
verseThree()
spaceBetweenLines()













//: Next, make the meme your own.
//:
//: [Previous](@previous)  |  page 11 of 12  |  [Next: Personal Meme](@next)
