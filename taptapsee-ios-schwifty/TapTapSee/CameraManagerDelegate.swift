//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  CaptureManagerDelegate.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation

protocol CameraManagerDelegate: NSObjectProtocol {
    func cameraManager(_ manager: CameraManager, didCaptureStillFrame image: UIImage)

    func cameraManager(_ manager: CameraManager, didCaptureMetadata metadataObjects: [Any])

    func cameraManager(_ manager: CameraManager, didFailToCaptureStillFrameWithError error: Error?)
}