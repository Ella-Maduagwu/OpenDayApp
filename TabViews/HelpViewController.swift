//
//  HelpViewController.swift
//  OpenDayApp
//

//

import UIKit
import MessageUI

class HelpViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var liveChatButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Help"
    }

    // Action to handle sending an email.
    @IBAction func emailButtonTapped(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@university.com"])
            mail.setSubject("Need Help")
            mail.setMessageBody("Hello, I need help with...", isHTML: false)
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Email Unavailable", message: "Please configure an email account on this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MFMailComposeViewControllerDelegate method to handle mail completion.
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    // Action to handle making a phone call.
    @IBAction func phoneButtonTapped(_ sender: UIButton) {
        if let phoneURL = URL(string: "tel://+1234567890"), UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL)
        } else {
            let alert = UIAlertController(title: "Call Unavailable", message: "Unable to initiate a call from this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // Placeholder for live chat button.
    @IBAction func liveChatButtonTapped(_ sender: UIButton) {
        // Implement live chat functionality later.
    }
}

// MARK: - Data Models
struct Course {
    var id: String
    var name: String
    var infoLink: String

    init?(data: [String: Any]) {
        guard let name = data["name"] as? String, let infoLink = data["infoLink"] as? String else {
            return nil
        }
        self.id = UUID().uuidString
        self.name = name
        self.infoLink = infoLink
    }
}
