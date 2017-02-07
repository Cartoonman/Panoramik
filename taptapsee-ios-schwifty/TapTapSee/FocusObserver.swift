//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  FocusObserver.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation
import AVFoundation
class FocusObserver: NSObject {
    var audioPlayer: AVAudioPlayer!

    var avCaptureDevice: AVCaptureDevice!

    override init(videoDevice avcd: AVCaptureDevice) {
        super.init()
        
        // Turn on the sound
        self.initializeAudioPlayer()
        // Setup the AVCaptureDevice observing
        self.avCaptureDevice = avcd
        self.avCaptureDevice.addObserver(self, forKeyPath: "adjustingFocus", options: (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew), context: nil)
    
    }


    deinit {
        self.avCaptureDevice.removeObserver(self, forKeyPath: "adjustingFocus")
    }

    func initializeAudioPlayer() {
        var error: Error?
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        if error != nil {
            print("Error setting up audio session: \(error)")
        }
        var audioFile: String? = Bundle.main.path(forResource: "camera-focus-beep-01", ofType: "mp3")
        audioPlayer = try? AVAudioPlayer(contentsOfURL: URL(fileURLWithPath: audioFile))
        if error != nil {
            print("Failed to init 'focus acquired' sound: \(error)")
        }
        audioPlayer.prepareToPlay()
    }

    func focusAcquired() {
        var defaults = UserDefaults.standard
        if defaults.bool(forKey: DEFAULT_FOCUS_LOCK_SOUND_KEY) {
            // Check to see if we've got VoiceOver queued so we don't interrupt it
            if !SpeakQueue.shared().isBusy() {
                audioPlayer.play()
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String, ofObject object: Any, change: [AnyHashable: Any], context: UnsafeMutableRawPointer) {
        if (keyPath == "adjustingFocus") {
            var wasAdjustingFocus: Bool? = ((change[NSKeyValueChangeOldKey] as? String)? == Int(1))
            var adjustingFocus: Bool? = ((change[NSKeyValueChangeNewKey] as? String)? == Int(1))
            DDLogDebug("Focusing %@ -> %@", wasAdjustingFocus ? "YES" : "NO", adjustingFocus ? "YES" : "NO")
            //        NSLog(@"Change dict: %@", change);
            if wasAdjustingFocus && !adjustingFocus {
                DDLogDebug("Focus acquired")
                self.focusAcquired()
            }
        }
    }
}
import AudioToolbox