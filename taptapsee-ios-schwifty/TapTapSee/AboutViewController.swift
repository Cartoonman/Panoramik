//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  AboutViewController.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import UIKit
import MessageUI
class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var focusLockSwitch: UISwitch!
    @IBOutlet weak var flashSwitch: UISwitch!
    @IBOutlet weak var pictureCreditLabel: UILabel!
    @IBOutlet weak var pictureCreditTitleLabel: UILabel!
    var isFocusLockSoundEnabled: Bool = false
    var isFlashEnabled: Bool = false

    @IBAction func onPrivacyPolicyButton(_ sender: Any) {
        var privacyPolicyURL = URL(string: "http://www.taptapseeapp.com/privacy")
        UIApplication.shared.openURL(privacyPolicyURL)
    }

    @IBAction func onTermsOfService(_ sender: Any) {
        var termsOfServiceURL = URL(string: "http://www.taptapseeapp.com/terms_of_use")
        UIApplication.shared.openURL(termsOfServiceURL)
    }

    @IBAction func onFocusLockSwitchDidToggle(_ sender: Any) {
        self.focusLockSoundEnabled = focusLockSwitch.isOn()
        self.saveDefaults()
    }

    @IBAction func onContactUs(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            var mailer = MFMailComposeViewController()
            mailer.mailComposeDelegate = self
            mailer.setToRecipients(["contact@taptapseeapp.com"])
            mailer.setSubject("TapTapSee - Contact Us")
            mailer.setMessageBody("Your Message:<br/><br/><br/><br/><br/><br/><br/>Version: \(self.versionInfoString())<br/>Model: \(UIDevice.current.model)<br/>System: \(UIDevice.current.systemName), \(UIDevice.current.systemVersion)<br/>Locale: \(NSLocale.current.localeIdentifier)<br/>Network: \(TMReachability().currentReachabilityString())", isHTML: true)
            self.present(mailer, animated: true, completion: { _ in })
        }
        else {
            var alert = UIAlertView(title: "Failure", message: "Your device doesn't support the composer sheet", delegate: nil, cancelButtonTitle: "Accept", otherButtonTitles: "")
            alert.show()
        }
    }

    @IBAction func onFlashSwitchDidToggle(_ sender: Any) {
        self.flashEnabled = flashSwitch.isOn()
        self.saveDefaults()
    }


    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        // iOS 6/7 compatibility
        if CFloat(UIDevice.current.systemVersion) < 7 {
            topLayoutConstraint.constant = 19
        }
            // Setup version label
        var appInfo: [AnyHashable: Any]? = Bundle.main.infoDictionary
        var versionStr = NSLocalizedString("Version: \(appInfo?["CFBundleShortVersionString"] as? String) (build \(appInfo?["CFBundleVersion"] as? String))", comment: "")
        versionLabel.text = versionStr
            // Setup switch default states
        var defaults = UserDefaults.standard
        focusLockSwitch.on = defaults.bool(forKey: DEFAULT_FOCUS_LOCK_SOUND_KEY)
        flashSwitch.on = defaults.bool(forKey: DEFAULT_FLASH_KEY)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1 {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override func viewDidUnload() {
        versionLabel = nil
        super.viewDidUnload()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .blackTranslucent
    }

    func saveDefaults() {
        var defaults = UserDefaults.standard
        defaults.set(self.focusLockSoundEnabled(), forKey: DEFAULT_FOCUS_LOCK_SOUND_KEY)
        defaults.set(self.flashEnabled(), forKey: DEFAULT_FLASH_KEY)
        defaults.synchronize()
    }

    func versionInfoString() -> String {
        var appInfo: [AnyHashable: Any]? = Bundle.main.infoDictionary
        var versionStr: String? = "Version: \(appInfo?["CFBundleShortVersionString"] as? String) (\(appInfo?["CFBundleVersion"] as? String))"
        return versionStr!
    }
// MARK: IBActions
// MARK: Email callbacks

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //    switch (result)
        //    {
        //        case MFMailComposeResultCancelled:
        //            DebugLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
        //            break;
        //        case MFMailComposeResultSaved:
        //            DebugLog(@"Mail saved: you saved the email message in the drafts folder.");
        //            break;
        //        case MFMailComposeResultSent:
        //            DebugLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
        //            break;
        //        case MFMailComposeResultFailed:
        //            DebugLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
        //            break;
        //        default:
        //            DebugLog(@"Unknown MFMailComposeResult value.");
        //            break;
        //    }
        //    
        self.dismiss(animated: true, completion: { _ in })
    }
}