/*:
 ## Exercise: What Fits on Your iPhone?
 
 In this exercise you’re going to work on figuring out the answer to the timeless question: How much stuff can I fit on my iPhone?
 
 Unlike the previous exercises, no code will be provided. But here are a few things you’ll need to know:
 
 
 - iPhone storage capacity is measured in **gigabytes** (GB).
 - The iPhone in question has 8GB of storage.
 - A gigabyte is about **1000 megabytes** (MB)
 - The phone already has **3GB** of stuff on it
 - **One minute** of video takes **150MB** of storage
 
 - callout(Exercise): How many minutes of video will it take to fill the phone?\
 _Hint_: Do all of your calculations in megabytes (MB).
*/
// Storage Capacity of iPhone (MB)
let storageCapacity = 8000

// Storage already used on the iPhone (MB)
let storageUsed = 3000

// Storage remaining on the iPhone (MB)
let storageAvailable = storageCapacity - storageUsed

// MB required per minute of video
let mbPerMinute = 150

// Minutes of video to fill the phone
let minutesToFill = storageAvailable / mbPerMinute

//:[Previous](@previous)  |  page 12 of 14  |  [Next: Exercise: Fixing Your Morning](@next)
