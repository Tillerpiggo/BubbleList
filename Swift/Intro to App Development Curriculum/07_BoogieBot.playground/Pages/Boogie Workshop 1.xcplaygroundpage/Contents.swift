/*:
 ## Boogie Workshop
 
 This page is here for you to create your own routines. 
 
 Remember the moves:
 
 - `leftArmUp()`, `leftArmDown()`, `rightArmUp()`, `rightArmDown()`
 - `leftLegUp()`, `leftLegDown()`, `rightLegUp()`, `rightLegDown()`
 - `shakeItLeft()`, `shakeItRight()`, `shakeItCenter()`
 - `jumpUp()`, `jumpDown()`
 - `fabulize()`, `defabulize()`
 
 To sign your work:
 
 `setBotTitle("My Awesome Dance")`\
 `setBotSubtitle("By The Boogiemaster")`
*/
// make the bot shake it's torso
func shakeBot() {
    shakeItLeft()
    shakeItRight()
    shakeItLeft()
    shakeItRight()
    shakeItCenter()
}

// make the bot jump up and down
func jump() {
    jumpUp()
    jumpDown()
}

// make the bot raise both of it's arms
func raiseArms() {
    leftArmUp()
    rightArmUp()
}

//make the bot become the rainbow itself
func superFabulize() {
    fabulize()
    fabulize()
    fabulize()
}

//sign the dance
func sign() {
    setBotTitle("The Cosmic Boogie")
    setBotSubtitle("By Tiller Pige")
}

// start the dance
startBot()
startRecording()
superFabulize()
raiseArms()
shakeBot()
superFabulize()
shakeBot()
superFabulize()
jump()
superFabulize()
defabulize()









//: Continue with your creativity.
//:
//:[Previous](@previous)  |  page 10 of 13  |  [Next: Boogie Workshop](@next)
