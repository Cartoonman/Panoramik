//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  CameraViewController.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import UIKit
class CameraViewController: UIViewController, CameraManagerDelegate, TagQueryDelegate, BarcodeContentDetectorDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var queryCount: Int = 0
    var currentZoom: Float = 0.0
    var lastIdentifiedItem: HistoryItem!
    var lastIdentifiedLiveItem: String = ""
    var cameraManager: CameraManager!
    var barcodeContentDetector: BarcodeContentDetector!
    var offensiveImagePolicyAlertView: UIAlertView!
    var offensiveImageAlertView: UIAlertView!
    @IBOutlet weak var viewfinder: UIView!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var outputLabel: UILabel!
    var featureIndicator: UIView!

    @IBAction func onCameraButton(_ sender: Any) {
        if TagQueryManager.shared.busyCount() >= MAX_QUERY_COUNT {
            var maxImagesMessage = NSLocalizedString("Sorry, but I can only handle \(MAX_QUERY_COUNT) images at a time.  Please wait for some to finish before taking another picture", comment: "")
            SpeakQueue.shared().speak(maxImagesMessage)
        }
        else {
            cameraManager.captureStillFrame()
        }
    }

    @IBAction func onInfoButton(_ sender: Any) {
        var aboutVC = AboutViewController()
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }

    @IBAction func onRepeatButton(_ sender: Any) {
        var message: String? = nil
        if lastIdentifiedItem != nil {
            message = NSLocalizedString("Repeating. Picture \(lastIdentifiedItem.queryNumber()) is \(lastIdentifiedItem.title)", comment: "")
        }
        else {
            message = NSLocalizedString("No pictures taken. Take a picture first.", comment: "")
        }
        SpeakQueue.shared().speak(message)
    }

    @IBAction func onLibraryButton(_ sender: Any) {
        var imagePickController = UIImagePickerController()
        imagePickController.sourceType = .savedPhotosAlbum
        imagePickController.delegate = self
        imagePickController.allowsEditing = false
        self.present(imagePickController, animated: true, completion: { _ in })
    }

    @IBAction func onShareButton(_ sender: Any) {
        var activityViewController = UIActivityViewController(activityItems: lastIdentifiedItem.shareActivityItems(), applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: { _ in })
    }


    override func viewDidLoad() {
        // Setup the tag query manager
        TagQueryManager.shared.delegate = self
        queryCount = 0
        currentZoom = 1.0
        // Initialize the video layer manager
        // TODO: Make this viewfinder a UIView to get this stuff out of here
        cameraManager = CameraManager()
        cameraManager.delegate = self
        self.addVideoPreviewLayer()
        // View controller misc setup
        if kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1 {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        outputLabel.text = ""
        // Setup observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.previewLayerDidStart), name: AVCaptureSessionDidStartRunningNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.previewLayerDidStop), name: AVCaptureSessionDidStopRunningNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Check to see if accessibility is turned on (in iOS7 we're using AVSpeechSynthesizer)
        if !UIAccessibilityIsVoiceOverRunning() {
            var alert = UIAlertView(title: NSLocalizedString("VoiceOver is Off", comment: ""), message: NSLocalizedString("In order to hear the descriptions of the pictures taken, please enable VoiceOver in your device Settings.", comment: ""), delegate: nil, cancelButtonTitle: "", otherButtonTitles: "OK")
            alert.show()
        }
            // Show user offensive image notice
        var userAcceptedOffensiveImagePolicy: Bool = UserDefaults.standard.bool(forKey: DEFAULT_USER_ACCEPTED_OFFENSIVE_IMAGE_POLICY)
        if !userAcceptedOffensiveImagePolicy {
            offensiveImagePolicyAlertView = UIAlertView(title: NSLocalizedString("Notice", comment: ""), message: NSLocalizedString("Your use will be suspended if you take any violent, nude, partially nude, discriminatory, unlawful, infringing, hateful or pornographic pictures. See our privacy policy for more details.", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("Decline", comment: ""), otherButtonTitles: NSLocalizedString("Accept", comment: ""))
            offensiveImagePolicyAlertView.show()
        }
        // Turn on the camera
        self.enableInput()
        cameraManager.startCamera()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.disableInput()
        cameraManager.stopCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }

    deinit {
        TagQueryManager.shared.delegate = nil
        cameraManager.delegate = nil
        cameraManager.stopCamera()
        NotificationCenter.default.removeObserver(self)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyleLightContent
    }

    func disableInput() {
        cameraButton.isEnabled = false
    }

    func enableInput() {
        cameraButton.isEnabled = true
    }

    func simulateShutterFlashOfWhite() {
        var whiteFlashView = UIView(frame: viewfinder.frame)
        whiteFlashView.alpha = 1.0
        whiteFlashView.backgroundColor = UIColor.white
        self.view.insertSubview(whiteFlashView, aboveSubview: viewfinder)
        UIView.animate(withDuration: 2, animations: {() -> Void in
            whiteFlashView.alpha = 0.0
        }, completion: {(_ finished: Bool) -> Void in
            whiteFlashView.removeFromSuperview()
        })
    }

    func fitImage(toViewfinderSize image: UIImage) -> UIImage {
        var outputSize: CGSize = CGSizeMultiply(viewfinder.frame.size, CGFloat(UIScreen.main.scale()))
        var minSize: Float = outputSize.height < outputSize.width ? outputSize.height : outputSize.width
        var maxSize: Float = outputSize.height > outputSize.width ? outputSize.height : outputSize.width
        if (image.size.width > maxSize || image.size.height > minSize) && (image.size.width > minSize || image.size.height > maxSize) {
            var resizedImage: UIImage? = image.fitToRange(from: minSize, to: maxSize)
            DDLogDebug("AVCaptureStillImageOutput image resized from %@ to %@", NSStringFromCGSize(image.size), NSStringFromCGSize(resizedImage?.size))
            return resizedImage!
        }
        return image
    }

    override func addImage(_ image: UIImage) {
        queryCount += 1
        if queryCount > MAX_QUERY_COUNT {
            queryCount = 1
        }
        var photoFormat = NSLocalizedString("Picture \(queryCount) in progress", comment: "")
        outputLabel.text = photoFormat
        SpeakQueue.shared().speak(photoFormat)
        var historyItem: HistoryItem? = HistoryItemStore.shared().createItem(for: image)
        historyItem?.queryNumber = queryCount
        historyItem?.status = "Waiting..."
        var tagQueryManager = TagQueryManager.shared
        tagQueryManager.query(with: image, withFocus: CGPoint(x: CGFloat(0), y: CGFloat(0)), with: historyItem)
    }

    func previewLayerDidStart(_ sender: Any) {
        // Provide a nice animation when the preview layer starts
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.25)
        viewfinder.alpha = 1.0
        UIView.commitAnimations()
    }

    func previewLayerDidStop(_ sender: Any) {
        viewfinder.alpha = 0.0
    }

    func addVideoPreviewLayer() {
        // Init size and create preview/image capture layer
        self.resetVideoPreviewLayerSize()
        viewfinder.layer().addSublayer(cameraManager.previewLayer)
        // Add feature indicator
        self.featureIndicator = UIView(frame: CGRect.zero)
        self.featureIndicator().backgroundColor = UIColor(red: CGFloat(0.0 / 255.0), green: CGFloat(114.0 / 255.0), blue: CGFloat(255.0 / 255.0), alpha: CGFloat(0.5))
        viewfinder.insertSubview(self.featureIndicator(), at: 3)
    }

    func resetVideoPreviewLayerSize() {
        var layerRect = CGRect(x: CGFloat((viewfinder.layer.bounds.size.width - (viewfinder.layer.bounds.size.width * currentZoom)) / 2), y: CGFloat((viewfinder.layer.bounds.size.height - (viewfinder.layer.bounds.size.height * currentZoom)) / 2), width: CGFloat(viewfinder.layer.bounds.size.width * currentZoom), height: CGFloat(viewfinder.layer.bounds.size.height * currentZoom))
        cameraManager.previewLayer.frame = layerRect
    }
// MARK: CameraManagerDelegate implementation

    func cameraManager(_ manager: CameraManager, didCaptureMetadata metadataObjects: [Any]) {
        var highlightViewRect = CGRect.zero
        var barCodeObject: AVMetadataMachineReadableCodeObject?
        var detectionString: String? = nil
        var barCodeTypes: [Any] = [.upceCode, .code39Code, .code39Mod43Code, .ean13Code, .ean8Code, .code93Code, .code128Code, .pdf417Code, .qrCode, .aztecCode]
        for metadata: AVMetadataObject in metadataObjects {
            for type: String in barCodeTypes {
                if (metadata.type == type) {
                    barCodeObject = (cameraManager.previewLayer.transformedMetadataObject(forMetadataObject: (metadata as? AVMetadataMachineReadableCodeObject)) as? AVMetadataMachineReadableCodeObject)
                    highlightViewRect = barCodeObject?.bounds
                    detectionString = (metadata as? AVMetadataMachineReadableCodeObject)?.stringValue
                    break
                }
            }
            if detectionString != nil {
                break
            }
        }
        if detectionString != nil && barcodeContentDetector == nil {
            // We had a match with the iOS content detector
            barcodeContentDetector = BarcodeContentDetector(delegate: self, withFeatureType: barCodeObject?.type, withFeatureDescription: detectionString)
            barcodeContentDetector.start()
        }
        self.featureIndicator().frame = highlightViewRect
    }

    func cameraManager(_ manager: CameraManager, didCaptureStillFrame image: UIImage) {
        DDLogDebug("Captured still image: %@", image)
        self.simulateShutterFlashOfWhite()
            // Control the image size
        var resizedImage: UIImage? = self.fitImage(toViewfinderSize: image)
            // Crop image to account for zoomed in viewport
        var cropRect = CGRect(x: CGFloat((resizedImage?.size?.width - (resizedImage?.size?.width / currentZoom)) / 2), y: CGFloat((resizedImage?.size?.height - (resizedImage?.size?.height / currentZoom)) / 2), width: CGFloat(resizedImage?.size?.width / currentZoom), height: CGFloat(resizedImage?.size?.height / currentZoom))
        var croppedImage: UIImage? = resizedImage?.croppedImage(cropRect)
        self.addImage(croppedImage)
    }

    func cameraManager(_ manager: CameraManager, didFailToCaptureStillFrameWithError error: Error?) {
        DDLogDebug("Camera error: %@", error)
    }
// MARK: TagQueryDelegate implementation

    func didIdentify(_ item: HistoryItem, with query: TagQuery) {
        lastIdentifiedItem = item
        // Show offensive warning
        if (item.title == "offensive") {
            offensiveImageAlertView = UIAlertView(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Your use will be suspended if you take any violent, nude, partially nude, discriminatory, unlawful, infringing, hateful or pornographic pictures. See our privacy policy for more details.", comment: ""), delegate: nil, cancelButtonTitle: "", otherButtonTitles: NSLocalizedString("Accept", comment: ""))
            offensiveImageAlertView.show()
        }
        else {
                // Do the translation here (so we still get the 'offensive' above)
            var translatedTitle: String = CWTranslate.translate(item.title, withSourceLanguage: "en", withDestinationLanguage: CWTranslate.currentLanguageIdentifier())
            DebugLog("translatedTitle: %@", translatedTitle)
            item.title = translatedTitle
                // Form the VO message and speak
            var message = NSLocalizedString("Picture \(item.queryNumber()) is \(item.title)", comment: "")
            outputLabel.text = message
            SpeakQueue.shared().speak(message)
            // Reset "live item"
            lastIdentifiedLiveItem = nil
        }
        // Enable the share picture
        shareButton.isEnabled = true
    }

    func didDequeue(_ item: HistoryItem, with query: TagQuery) {
        // Ignore
    }

    func didUploadItem(_ item: HistoryItem, with query: TagQuery) {
        // Ignore
    }

    func didFail(_ item: HistoryItem, with query: TagQuery) {
        var message = NSLocalizedString("Picture \(item.queryNumber()) failed: \(item.status)", comment: "")
        outputLabel.text = message
        SpeakQueue.shared().speak(message)
    }
// MARK: BarcodeContentDetectorDelegate implementation

    func barcodeContentDetector(_ sender: Any, didIdentifyWith item: String) {
        DispatchQueue.main.async(execute: {() -> Void in
            if item != nil && !(item == lastIdentifiedLiveItem) {
                DDLogDebug("live item: %@", item)
                var message: String = "Barcode: \(item)"
                outputLabel.text = message
                SpeakQueue.shared().speak(message)
            }
            lastIdentifiedLiveItem = item
        })
        barcodeContentDetector = nil
    }
// MARK: UIImagePickerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [AnyHashable: Any]) {
        var image: UIImage? = (info[UIImagePickerControllerOriginalImage] as? String)
        self.addImage(image)
        picker.dismiss(animated: true, completion: { _ in })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: { _ in })
    }
// MARK: UIAlertViewDelegate implementation

    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if alertView == offensiveImagePolicyAlertView {
            if buttonIndex == 1 {
                UserDefaults.standard.set(true, forKey: DEFAULT_USER_ACCEPTED_OFFENSIVE_IMAGE_POLICY)
                UserDefaults.standard.synchronize()
            }
            else {
                exit(0)
            }
        }
    }
// MARK: IBActions
}
import AVFoundation