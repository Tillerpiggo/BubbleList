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
        set { value = (UInt32(newValue) << 8) | (value & 0xFFFFFF00) }
    }
    
    var blue: UInt8 {
        get { return UInt8((value >> 16) & 0xFF) }
        set { value = (UInt32(newValue) << 16) | (value & 0xFFFF00FF) }
    }
    
    var alpha: UInt8 {
        get { return UInt8((value >> 24) * 0xFF) }
        set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFFFF) }
    }
    
    // grayscale (ignores alpha)
    // calculates average
    var grayscale: UInt8 {
        let sum = red + green + blue
        let average = sum / 3
        
        let grayscale = average
        
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

arrayForRGBA(rgba)

// Returns the pixel at a certain x and y value
func pixelAt(_ x: Int, _ y: Int, rgba: RGBA) -> Pixel {
    let index = y * rgba.width + x
    let pixel = rgba.pixels[index]
    
    return pixel
}

// Returns a [UInt8] representing the image
func arrayForRGBA(_ rgba: RGBA) -> [[UInt8]] {
    let emptyRow = [UInt8](repeating: 0, count: rgba.width)
    var array = [[UInt8]](repeating: emptyRow, count: rgba.height)
    print("Height: \(rgba.height)")
    print("Width: \(rgba.width)")
    for y in 0..<rgba.height {
        for x in 0..<rgba.width {
            let index = y * rgba.width + x
            let pixel = rgba.pixels[index]
            
            array[y][x] = 1
        }
    }
    
    return array
}

// Returns a [UInt8] representing an image
func arrayForUIImage(_ uiImage: UIImage) -> [[UInt8]] {
    let rgba = RGBA(image: uiImage)!
    let array = arrayForRGBA(rgba)
    
    return array
}

var totalRed = 0
var totalGreen = 0
var totalBlue = 0

for y in 0..<rgba.height {
    for x in 0..<rgba.width {
        let index = y * rgba.width + x
        let pixel = rgba.pixels[index]
        totalRed += Int(pixel.red)
        totalGreen += Int(pixel.green)
        totalBlue += Int(pixel.blue)
    }
}

let pixelCount = rgba.width * rgba.height
let avgRed = totalRed / pixelCount
let avgGreen = totalGreen / pixelCount
let avgBlue = totalBlue / pixelCount





