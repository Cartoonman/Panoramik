//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  UIImage+FitToRange.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import UIKit
extension UIImage {
    func fitToRange(from maxDimension1: Int, to maxDimension2: Int) -> UIImage {
        var inputSize = CGSize(width: CGFloat(CGImageGetWidth(self.cgImage)), height: CGFloat(CGImageGetHeight(self.cgImage)))
            // Determine max size.
        var biggerMaxDimension: Int = (maxDimension1 > maxDimension2) ? maxDimension1 : maxDimension2
        var smallerMaxDimension: Int = (maxDimension1 > maxDimension2) ? maxDimension2 : maxDimension1
        var maxSize: CGSize
        if inputSize?.width > inputSize?.height {
            maxSize = CGSize(width: CGFloat(biggerMaxDimension), height: CGFloat(smallerMaxDimension))
        }
        else {
            maxSize = CGSize(width: CGFloat(smallerMaxDimension), height: CGFloat(biggerMaxDimension))
        }
            // Determine final size.
        var finalSize: CGSize? = inputSize
        if (finalSize?.width > maxSize.width) || (finalSize?.height > maxSize.height) {
            if finalSize?.width > maxSize.width {
                var oldSize: CGSize? = finalSize
                finalSize?.width = maxSize.width
                finalSize?.height = (finalSize?.width * oldSize?.height) / oldSize?.width
            }
            if finalSize?.height > maxSize.height {
                var oldSize: CGSize? = finalSize
                finalSize?.height = maxSize.height
                finalSize?.width = (finalSize?.height * oldSize?.width) / oldSize?.height
            }
            finalSize?.width = ceilf(finalSize?.width)
            finalSize?.height = ceilf(finalSize?.height)
        }
            // Make scaled image.
        var colorSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        var context = CGContext(data: nil, width: finalSize?.width, height: finalSize?.height, bitsPerComponent: 8, bytesPerRow: 4 * (Int(finalSize?.width)), space: colorSpace, bitmapInfo: kCGImageAlphaNoneSkipLast)
        var outputRect = CGRect.zero
        outputRect.size = finalSize
        CGContextSetInterpolationQuality(context, kCGInterpolationNone)
        context.draw(in: self.cgImage, image: outputRect)
        var outputCGImage: CGImageRef = context.makeImage()
        CGContextRelease(context)
        var output = UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)
        CGImageRelease(outputCGImage)
        return output
    }
}