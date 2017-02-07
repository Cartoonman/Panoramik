//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
// UIImage+Resize.swift
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.
import UIKit
extension UIImage {
    // Extends the UIImage class to support resizing/cropping
    func croppedImage(_ newRect: CGRect) -> UIImage {
        var drawTransposed: Bool
        switch self.imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                drawTransposed = true
            default:
                drawTransposed = false
        }

        newRect = newRect.integral()
        var imageRef: CGImageRef? = self.cgImage
            // Build a context that's the same dimensions as the new size
        var bitmap = CGContext(data: nil, width: newRect.size.width, height: newRect.size.height, bitsPerComponent: CGImageGetBitsPerComponent(imageRef), bytesPerRow: 0, space: CGImageGetColorSpace(imageRef), bitmapInfo: CGImageGetBitmapInfo(imageRef))
        if bitmap == nil {
            return nil
        }
        var clippedRect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(newRect.size.width), height: CGFloat(newRect.size.height))
        bitmap.clip(to: clippedRect)
        // Rotate and/or flip the image if required by its orientation
        bitmap.concatenate(self.transform(forOrientation: newRect.size))
        var transposedRect = CGRect(x: CGFloat(-newRect.origin.y), y: CGFloat(-newRect.origin.x), width: CGFloat(self.size.height), height: CGFloat(self.size.width))
        var drawRect = CGRect(x: CGFloat(-newRect.origin.x), y: CGFloat(-newRect.origin.y), width: CGFloat(self.size.width), height: CGFloat(self.size.height))
        // Draw into the context; this crops the image
        bitmap.draw(in: imageRef, image: drawTransposed ? transposedRect : drawRect)
            // Get the resized image from the context and a UIImage
        var newImageRef: CGImageRef = bitmap.makeImage()
        var newImage = UIImage(cgImage: newImageRef)
            // Clean up
        CGContextRelease(bitmap)
        CGImageRelease(newImageRef)
        return newImage
    }

    func resizedImage(_ newSize: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        var drawTransposed: Bool
        switch self.imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                drawTransposed = true
            default:
                drawTransposed = false
        }

        return self.resizedImage(newSize, transform: self.transform(forOrientation: newSize), drawTransposed: drawTransposed, interpolationQuality: quality)
    }

    func resizedImage(with contentMode: UIViewContentMode, bounds: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        var horizontalRatio: CGFloat = bounds.width / self.size.width
        var verticalRatio: CGFloat = bounds.height / self.size.height
        var ratio: CGFloat
        switch contentMode {
            case .scaleAspectFill:
                ratio = max(horizontalRatio, verticalRatio)
            case .scaleAspectFit:
                ratio = min(horizontalRatio, verticalRatio)
            default:
                NSException.raise(NSInvalidArgumentException, format: "Unsupported content mode: %d", Int(contentMode))
        }

        var newSize = CGSize(width: CGFloat(self.size.width * ratio), height: CGFloat(self.size.height * ratio))
        return self.resizedImage(newSize, interpolationQuality: quality)
    }

    // Returns a rescaled copy of the image, taking into account its orientation
    // The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
    // Resizes the image according to the given content mode, taking into account the image's orientation
// MARK: -
// MARK: Private helper methods
    // Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
    // The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
    // If the new size is not integral, it will be rounded up

    func resizedImage(_ newSize: CGSize, transform: CGAffineTransform, drawTransposed transpose: Bool, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        var newRect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(newSize.width), height: CGFloat(newSize.height)).integral()
        var transposedRect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(newRect.size.height), height: CGFloat(newRect.size.width))
        var imageRef: CGImageRef? = self.cgImage
            // Build a context that's the same dimensions as the new size
        var bitmap = CGContext(data: nil, width: newRect.size.width, height: newRect.size.height, bitsPerComponent: CGImageGetBitsPerComponent(imageRef), bytesPerRow: 0, space: CGImageGetColorSpace(imageRef), bitmapInfo: CGImageGetBitmapInfo(imageRef))
        // Rotate and/or flip the image if required by its orientation
        bitmap.concatenate(transform)
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(bitmap, quality)
        // Draw into the context; this scales the image
        bitmap.draw(in: imageRef, image: transpose ? transposedRect : newRect)
            // Get the resized image from the context and a UIImage
        var newImageRef: CGImageRef = bitmap.makeImage()
        var newImage = UIImage(cgImage: newImageRef)
            // Clean up
        CGContextRelease(bitmap)
        CGImageRelease(newImageRef)
        return newImage
    }
    // Returns an affine transform that takes into account the image orientation when drawing a scaled image

    func transform(forOrientation newSize: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        switch self.imageOrientation {
            case .down,             // EXIF = 3
.downMirrored:
                // EXIF = 4
                transform = transform.translatedBy(x: newSize.width, y: newSize.height)
                transform = transform.rotated(by: .pi)
            case .left,             // EXIF = 6
.leftMirrored:
                // EXIF = 5
                transform = transform.translatedBy(x: newSize.width, y: 0)
                transform = transform.rotated(by: M_PI_2)
            case .right,             // EXIF = 8
.rightMirrored:
                // EXIF = 7
                transform = transform.translatedBy(x: 0, y: newSize.height)
                transform = transform.rotated(by: -M_PI_2)
            default:
                break
        }

        switch self.imageOrientation {
            case .upMirrored,             // EXIF = 2
.downMirrored:
                // EXIF = 4
                transform = transform.translatedBy(x: newSize.width, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            case .leftMirrored,             // EXIF = 5
.rightMirrored:
                // EXIF = 7
                transform = transform.translatedBy(x: newSize.height, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            default:
                break
        }

        return transform
    }
}