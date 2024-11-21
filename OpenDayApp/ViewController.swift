//
//  ViewController.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 08/11/2024.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    /// MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var emailTextField: customeTextField!
    @IBOutlet weak var passwordTextField: customeTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Step 1: Use FirestoreUpdater to add new buildings and rooms
                
       
    }
    /// Attempts to log in a user using Firebase authentication with email and password.
       ///- Parameter sender: The button that triggers the login process.
    
    @IBAction func loginButton(_ sender: UIButton) {
        // Ensure the email and password fields are not empty
            guard let email = emailTextField.text, !email.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty else {
                // Alert the user that email and password fields cannot be empty
                showAlert(title: "Missing Information", message: "Both email and password are required.")
                return
            }
        // Perform Firebase authentication with the provided email and password
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return } // Ensure self is available

                if let error = error {
                    // Handle errors, possibly show an alert with the error description
                    strongSelf.showAlert(title: " Login Error", message: error.localizedDescription)
                } else {
                   
                    // Successful login, handle navigation to the next screen
                    DispatchQueue.main.async{
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                       if let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController {
                                           if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                               sceneDelegate.changeRootViewController(to: tabBarController, animated: true)
                                           }
                            else{
                                print("TabBarController could not be instantiated from storyboard.")
                            }
                        }
                    }
                }
            }
        }
    /// Shows an alert with a title and a message.
        /// - Parameters:
        ///   - title: The title of the alert.
        ///   - message: The message of the alert.
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    @IBAction func anonymousLoginButton(_ sender: UIButton) {
        Auth.auth().signInAnonymously { [weak self] (authResult, error) in
                    guard let strongSelf = self else { return }
                    if let error = error {
                        // Handle any errors that occur during login
                        strongSelf.showAlert(title: "Login Error", message: error.localizedDescription)
                    } else {
                        // Handle the success scenario, perhaps transitioning to another screen
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                       if let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController {
                                           if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                               sceneDelegate.changeRootViewController(to: tabBarController, animated: true)
                                           }
                        }
                    }
                }
    }
    
    }
    




