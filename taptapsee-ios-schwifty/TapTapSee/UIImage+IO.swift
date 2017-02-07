//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  UIImage+IO.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import UIKit
extension UIImage {
    class func uniqueName() -> String {

        var timeUnion: (ti: TimeInterval, ull: UInt64)
        timeUnion.ti = Date.timeIntervalSinceReferenceDate
        return "\(timeUnion.ull)_photo"
    }

    func save(asJPEGinDirectory directory: String, withName name: String) -> Bool {
        var imagePath: String = URL(fileURLWithPath: directory).appendingPathComponent(name).absoluteString
        var imageData: Data? = self.asJPEG(withQuality: 1.0)
        return imageData?.write(toFile: imagePath, atomically: true)!
    }

    func save(asJPEGinDirectory directory: String, withName name: String, size: CGSize) -> Bool {
        var imageResized: UIImage? = self.resizedImage(withContentMode: .scaleAspectFill, bounds: size, interpolationQuality: kCGInterpolationDefault)
        return imageResized?.save(asJPEGinDirectory: directory, withName: name)!
    }

    func imageAsJPEG(withQuality quality: Float) -> Data {
        return .uiImageJPEGRepresentation()!
        // Alternative method
        //    NSMutableData *data = [NSMutableData data];
        //    
        //    // Setup the destination and type
        //    CFStringRef uti = kUTTypeJPEG;
        //    CGImageDestinationRef dest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data, uti, 1, NULL);
        //    if (!dest)
        //        return nil;
        //    
        //    // Create an options dict for compression (etc)
        //    CFMutableDictionaryRef options = CFDictionaryCreateMutable(kCFAllocatorDefault, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        //    if (!options) {
        //        CFRelease(dest);
        //        return nil;
        //    }
        //    
        //    CFDictionaryAddValue(options, kCGImageDestinationLossyCompressionQuality, (__bridge CFNumberRef)[NSNumber numberWithFloat:quality]);
        //    
        //    // Write the image
        //    CGImageDestinationAddImage(dest, self.CGImage, (CFDictionaryRef)options);
        //    CGImageDestinationFinalize(dest);
        //    
        //    // Cleanup
        //    CFRelease(options);
        //	CFRelease(dest);
        //    
        //    return data;
    }

    override func description() -> String {
        var orientation: String = ""
        if self.imageOrientation == .up {
            orientation = "UIImageOrientationUp"
        }
        else if self.imageOrientation == .down {
            orientation = "UIImageOrientationDown"
        }
        else if self.imageOrientation == .left {
            orientation = "UIImageOrientationLeft"
        }
        else if self.imageOrientation == .right {
            orientation = "UIImageOrientationRight"
        }
        else if self.imageOrientation == .upMirrored {
            orientation = "UIImageOrientationUpMirrored"
        }
        else if self.imageOrientation == .downMirrored {
            orientation = "UIImageOrientationDownMirrored"
        }
        else if self.imageOrientation == .leftMirrored {
            orientation = "UIImageOrientationLeftMirrored"
        }
        else if self.imageOrientation == .rightMirrored {
            orientation = "UIImageOrientationRightMirrored"
        }

        var cgImageSize = CGSize(width: CGFloat(CGImageGetWidth(self.cgImage)), height: CGFloat(CGImageGetHeight(self.cgImage)))
        return "{\n    size             = \(NSStringFromCGSize(self.size))\n    CGImage.size     = \(NSStringFromCGSize(cgImageSize))\n    imageOrientation = \(orientation)\n}"
    }
}
import ImageIO
import MobileCoreServices