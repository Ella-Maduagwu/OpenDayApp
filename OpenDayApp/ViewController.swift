import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController, UITextFieldDelegate {
    
    /// MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var emailTextField: customeTextField!
    @IBOutlet weak var passwordTextField: customeTextField!
    
    let db = Firestore.firestore() // Firestore reference
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupTapGesture()
    }
    
    /// Sets up the text fields' delegate
    private func setupTextFields() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    /// Adds a tap gesture to dismiss the keyboard when tapping outside the text fields
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
        
        // Check if the user exists in Firestore before attempting Firebase Authentication
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { [weak self] (querySnapshot, error) in
            guard let strongSelf = self else { return } // Ensure self is available

            if let error = error {
                // Handle Firestore errors
                strongSelf.showAlert(title: "Error", message: error.localizedDescription)
            } else if querySnapshot?.isEmpty == true {
                // No user found in Firestore with the given email
                strongSelf.showAlert(title: "User Not Found", message: "No user found with the provided email address.")
            } else {
                // If user exists, proceed to Firebase Authentication
                strongSelf.signInUser(email: email, password: password)
            }
        }
    }
    
    /// Signs in the user with the given email and password using Firebase Authentication.
    private func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return } // Ensure self is available

            if let error = error {
                // Handle errors, possibly show an alert with the error description
                strongSelf.showAlert(title: "Login Error", message: error.localizedDescription)
            } else {
                // Successful login, handle navigation to the next screen
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController {
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                            sceneDelegate.changeRootViewController(to: tabBarController, animated: true)
                        } else {
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
    func showAlert(title: String, message: String) {
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

    // MARK: - UITextFieldDelegate Methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder() // Moves focus to the password field when 'return' is pressed
        } else if textField == passwordTextField {
            textField.resignFirstResponder() // Dismiss keyboard if 'return' is pressed on password field
        }
        return true
    }
}
