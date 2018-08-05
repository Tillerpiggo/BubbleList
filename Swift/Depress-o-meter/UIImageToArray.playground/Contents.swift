//: Playground - noun: a place where people can play

import UIKit


var str = "Hello, playground"

struct Pixel {
    var value: UInt32
    
    var red: UInt8 {
        get { return UInt8(value & 0xFF) }
        set { value = UInt32(newValue) | (value & 0xFFFFFF00) }
    }
    var green: UInt8 {
        get { return UInt8((value >> 8) & 0xFF) }
        set { value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF) }
    }
    var blue: UInt8 {
        get { return UInt8((value >> 16) & 0xFF) }
        set { value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF) }
    }
    var alpha: UInt8 {
        get { return UInt8((value >> 24) & 0xFF) }
        set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF) }
    }
    
    // grayscale (ignores alpha)
    // calculates average
    var grayscale: UInt8 {
        let sum: Int = Int(red) + Int(green) + Int(blue)
        let average: Int = sum / 3
        
        let grayscale = UInt8(average)
        
        return grayscale
    }
}

struct RGBA {
    var pixels: UnsafeMutableBufferPointer<Pixel>
    var width: Int
    var height: Int
    
    init?(image: UIImage) {
        guard let cgImage = image.cgImage else { return nil } // 1
        
        width = Int(image.size.width)
        height = Int(image.size.height)
        let bitsPerComponent = 8 // 2
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB() // 3
        
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        imageContext.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: image.size), byTiling: true) // 4
        
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
    }
    
    func toUIImage() -> UIImage? {
        let bitsPerComponent = 8
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB() // 2
        
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let imageContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        guard let cgImage = imageContext!.makeImage() else { return nil } // 3
        
        let image = UIImage(cgImage: cgImage)
        return image
    }
}

let image = UIImage(named: "night-dark-moon-slice.jpg")!
let rgba = RGBA(image: image)!
let newImage = rgba.toUIImage()



// Returns the pixel at a certain x and y value
func pixelAt(_ x: Int, _ y: Int, rgba: RGBA) -> Pixel {
    let index = y * rgba.width + x
    let pixel = rgba.pixels[index]
    
    return pixel
}

// Returns a [UInt8] representing the image
func arrayForRGBA(_ rgba: RGBA) -> [[UInt8]] {
    var array = emptyArrayOfSize(rgba.width, rgba.height)
    //print("Height: \(rgba.height)")
    //print("Width: \(rgba.width)")
    for (y, row) in array.enumerated() {
        for (x, _) in row.enumerated() {
            let index = y * rgba.width + x
            let pixel = rgba.pixels[index]
            array[y][x] = pixel.grayscale
        }
    }
    
    return array
}

func arrayOfSizeForRGBA(_ rgba: RGBA, width: Int, height: Int) -> [[UInt8]] {
    var array = emptyArrayOfSize(width, height)
    let xInterval: Int = rgba.width / width
    let yInterval: Int = rgba.height / height
    
    for (y, row) in array.enumerated() {
        for (x, _) in row.enumerated() {
            if y % yInterval == 0 && x % xInterval == 0 {
                let index = y * rgba.width + x
                let pixel = rgba.pixels[index]
                array[y][x] = pixel.grayscale
            }
        }
    }
    
    return array
}

func emptyArrayOfSize(_ width: Int, _ height: Int) -> [[UInt8]] {
    let emptyRow = [UInt8](repeating: 0, count: width)
    let emptyArray = [[UInt8]](repeating: emptyRow, count: height)
    
    return emptyArray
}

func resizeArray(_ array: [[UInt8]], width: Int, height: Int) -> [[UInt8]] {
    let xInterval: Double = Double(array[0].count) / Double(width)
    let yInterval: Double = Double(array.count) / Double(width)
    
    let emptyRow = [UInt8](repeating: 0, count: width)
    var newArray = [[UInt8]](repeating: emptyRow, count: height)
    for y in 0..<height {
        for x in 0..<width {
            let startX: Int = Int(xInterval * Double(x))
            let startY: Int = Int(yInterval * Double(y))
            let endX: Int = Int(xInterval * Double(x + 1))
            let endY: Int = Int(yInterval * Double(y + 1))
            //print("xInterval: \(startX)-\(endX), yInterval: \(startY)-\(endY)")
            newArray[y][x] = averageBrightness(for: array, startX: startX, endX: endX, startY: startY, endY: endY)
        }
    }
    
    return newArray
}

func averageBrightness(for array: [[UInt8]], startX: Int, endX: Int, startY: Int, endY: Int) -> UInt8 {
    var brightness = 0
    let numberOfPixels = (endX - startX) * (endY - startY)
    
    for x in startX..<endX {
        for y in startY..<endY {
            //print("X: \(x), Y: \(y)")
            brightness += Int(array[y][x])
        }
    }
    
    let average: UInt8 = UInt8(brightness / numberOfPixels)
    
    return average
}

let array = arrayOfSizeForRGBA(rgba, width: 17, height: 17)
let resizedArray = resizeArray(array, width: 17, height: 17)
if array == resizedArray {
    print("It works!")
} else {
    print("It doesn't work...")
}


