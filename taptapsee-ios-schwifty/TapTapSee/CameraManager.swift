//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  CameraManager.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation
import AVFoundation
import CoreMedia
class CameraManager: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureSession: AVCaptureSession!
    var metadataOutput: AVCaptureMetadataOutput!
    var stillImageOutput: AVCaptureStillImageOutput!
    var focusObserver: FocusObserver!
    var sessionPreset: String = ""
    var cameraManagerQueue = DispatchQueue()

    weak var delegate: CameraManagerDelegate?
    private(set) var previewLayer: AVCaptureVideoPreviewLayer!

    func startCamera() {
        if !captureSession.running {
            captureSession.startRunning()
        }
    }

    func stopCamera() {
        if captureSession.running {
            captureSession.stopRunning()
        }
    }

    func captureStillFrame() {
        var videoConnection: AVCaptureConnection? = self.videoConnection()
        if videoConnection == nil {
            var error = Error(domain: Bundle.main.bundleIdentifier, code: kTTSAbnormalResultsError, userInfo: [NSLocalizedDescriptionKey: "Video connection not established"])
            self.delegate.cameraManager(self, didFailToCaptureStillFrameWithError: error)
            return
        }
        if videoConnection?.isVideoOrientationSupported() {
            videoConnection?.videoOrientation = self.cameraOrientation()
        }
        stillImageOutput.captureStillImageAsynchronously(from connection: videoConnection, completionHandler: {(_ imageSampleBuffer: CMSampleBuffer?, _ error: Error) -> Void in
            if imageSampleBuffer != nil {
                var imageData: Data? = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                var image = UIImage(data: imageData)
                self.delegate.cameraManager(self, didCaptureStillFrame: image)
            }
            else {
                self.delegate.cameraManager(self, didFailToCaptureStillFrameWithError: error)
            }
        })
    }


    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onCaptureSessionRuntimeError), name: AVCaptureSessionRuntimeErrorNotification, object: nil)
        cameraManagerQueue = DispatchQueue(label: "com.imagesearcher.CameraManager")
        captureSession = AVCaptureSession()
            // Add video input
        var videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if videoDevice != nil {
            var error: Error?
            var videoIn = try? AVCaptureDeviceInput(device: videoDevice)
            if videoIn != nil {
                if captureSession.canAddInput(videoIn) {
                    captureSession.addInput(videoIn)
                }
                else {
                    DDLogDebug("Couldn't add video input")
                }
            }
            else {
                self.showCameraPrivacyError()
                DDLogDebug("Couldn't create video input: %@", error?.localizedDescription)
            }
            focusObserver = FocusObserver(videoDevice: videoDevice)
        }
        else {
            DDLogDebug("Couldn't create video capture device")
        }
        // Add metadata output
        metadataOutput = AVCaptureMetadataOutput()
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession.addOutput(metadataOutput)
        metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes()
        // Add still image output
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: .jpeg]
        captureSession.addOutput(stillImageOutput)
        // Set up video preview layer
        self.previewLayer = AVCaptureVideoPreviewLayer(captureSession)
        self.previewLayer.videoGravity = .resizeAspectFill
        /*
                 Preset                                3G        3GS     4 back  4 front
                 AVCaptureSessionPresetHigh       400x304    640x480   1280x720  640x480
                 AVCaptureSessionPresetMedium     400x304    480x360    480x360  480x360
                 AVCaptureSessionPresetLow        400x304    192x144    192x144  192x144
                 AVCaptureSessionPreset640x480         NA    640x480    640x480  640x480
                 AVCaptureSessionPreset1280x720        NA         NA   1280x720       NA
                 AVCaptureSessionPresetPhoto    1600x1200  2048x1536  2592x1936  640x480
                 */
        /*
                 if ([captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto])    DDLogDebug(@"canSetSessionPreset AVCaptureSessionPresetPhoto");
                 if ([captureSession canSetSessionPreset:AVCaptureSessionPresetLow])      DDLogDebug(@"canSetSessionPreset AVCaptureSessionPresetLow");
                 if ([captureSession canSetSessionPreset:AVCaptureSessionPresetMedium])   DDLogDebug(@"canSetSessionPreset AVCaptureSessionPresetMedium");
                 if ([captureSession canSetSessionPreset:AVCaptureSessionPresetHigh])     DDLogDebug(@"canSetSessionPreset AVCaptureSessionPresetHigh");
                 if ([captureSession canSetSessionPreset:AVCaptureSessionPreset640x480])  DDLogDebug(@"canSetSessionPreset AVCaptureSessionPreset640x480");
                 if ([captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) DDLogDebug(@"canSetSessionPreset AVCaptureSessionPreset1280x720");
                 */
        sessionPreset = captureSession.sessionPreset
        if captureSession.canSetSessionPreset(AVCaptureSessionPresetPhoto) {
            sessionPreset = AVCaptureSessionPresetPhoto
        }
        if captureSession.canSetSessionPreset(sessionPreset) {
            captureSession.sessionPreset = sessionPreset
        }
        else {
            DDLogDebug("Can not set AVCaptureSession sessionPreset, using default %@", captureSession.sessionPreset)
        }
        DDLogDebug("AVCaptureSession sessionPreset %@", captureSession.sessionPreset)
        var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if device?.isFlashAvailable() && device?.flashMode != .auto {
            captureSession.beginConfiguration()
            device?.lockForConfiguration(nil)
            var defaults = UserDefaults.standard
            if defaults.bool(forKey: DEFAULT_FLASH_KEY) {
                device?.flashMode = .auto
            }
            else {
                device?.flashMode = .off
            }
            device?.unlockForConfiguration()
            captureSession.commitConfiguration()
        }
    
    }

    deinit {
        DDLogDebug("dealloc'ed")
        self.stopCamera()
        if captureSession.outputs.contains(metadataOutput) {
            captureSession.removeOutput(metadataOutput)
        }
        metadataOutput.setMetadataObjectsDelegate(nil, queue: nil)
        NotificationCenter.default.removeObserver(self)
    }
// MARK: Capture control

    func showCameraPrivacyError() {
        var alert = UIAlertView(title: NSLocalizedString("Camera Access", comment: ""), message: NSLocalizedString("Make sure privacy settings for TapTapSee are enabled under Settings > Privacy > Camera.", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("Accept", comment: ""), otherButtonTitles: "")
        alert.show()
    }
// MARK: Utilities

    func videoConnection() -> AVCaptureConnection {
        for connection: AVCaptureConnection in stillImageOutput.connections() {
            for port: AVCaptureInputPort in connection.inputPorts {
                if port.mediaType.isEqual(AVMediaTypeVideo) {
                    return connection
                    break
                }
            }
        }
        return nil
    }

    func machineName() -> String {
struct utsname {
}

        var systemInfo: utsname
        uname(systemInfo)
        return String(cString: systemInfo.machine, encoding: String.Encoding.utf8)
    }

    func cameraOrientation() -> AVCaptureVideoOrientation {
        var deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
        var newOrientation: AVCaptureVideoOrientation
        // AVCapture and UIDevice have opposite meanings for landscape left and right
        // (AVCapture orientation is the same as UIInterfaceOrientation)
        if deviceOrientation == .portrait {
            newOrientation = .portrait
        }
        else if deviceOrientation == .portraitUpsideDown {
            newOrientation = .portraitUpsideDown
        }
        else if deviceOrientation == .landscapeLeft {
            newOrientation = .landscapeRight
        }
        else if deviceOrientation == .landscapeRight {
            newOrientation = .landscapeLeft
        }
        else if deviceOrientation == .unknown {
            newOrientation = .portrait
        }
        else {
            newOrientation = .portrait
        }

        return newOrientation
    }

    func onCaptureSessionRuntimeError(_ n: Notification) {
        DDLogDebug("AVCaptureSessionRuntimeError: %@", (n.userInfo?[AVCaptureSessionErrorKey] as? String))
    }
// MARK: AVCaptureMetadataOutputObjectsDelegate implementation

    func captureOutput(_ captureOutput: AVCaptureOutput, didOutputMetadataObjects metadataObjects: [Any], from connection: AVCaptureConnection) {
        self.delegate.cameraManager(self, didCaptureMetadata: metadataObjects)
    }
}
import sys
let kTTSAbnormalResultsError: Int = 81