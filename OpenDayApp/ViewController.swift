import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Properties
    let db = Firestore.firestore() // Firestore reference
    var isSigningIn = false // Tracks if a sign-in operation is ongoing

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        setupTextFields()
        setupTapGesture()
        updateLoginButtonState() // Ensure button is initially disabled
    }

    private func setupTextFields() {
        emailTextField.delegate = self
        passwordTextField.delegate = self

        // Add observers to text fields to listen for changes
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateLoginButtonState()
    }

    private func updateLoginButtonState() {
        let isFormValid = isValidEmail(emailTextField.text ?? "") && (passwordTextField.text?.count ?? 0) >= 6
        loginButton.isEnabled = isFormValid
        loginButton.alpha = isFormValid ? 1.0 : 0.5 // Set button opacity for visual cue
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Check if we are currently signing in to prevent multiple requests
              guard !isSigningIn else { return }

              // Ensure email and password are not empty and valid
              guard let email = emailTextField.text, isValidEmail(email),
                    let password = passwordTextField.text, isValidPassword(password) else {
                  showAlert(title: "Missing Information", message: "Both valid email and password are required.")
                  return
              }

              // Start sign-in process
              isSigningIn = true
              signInUser(email: email, password: password)
          }
    
    @IBAction func anonymousLoginButtonTapped(_ sender: UIButton) {
        guard !isSigningIn else { return }
        
        isSigningIn = true
        Auth.auth().signInAnonymously { [weak self] (authResult, error) in
            guard let self = self else { return }
            self.isSigningIn = false
            if let error = error {
                self.showAlert(title: "Login Error", message: error.localizedDescription)
            } else {
                self.navigateToMainTabBar()
                print("DEBUG: user got in anonymously .")

            }
        }
    }

    // MARK: - Helper Methods

    private func signInUser(email: String, password: String) {
        // Attempt to sign in with Firebase Authentication using email and password
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            // Handle any errors that occurred during the authentication process
            if let error = error {
                // Reset the isSigningIn state to allow subsequent sign-in attempts
                self.isSigningIn = false
                // Print debug information for troubleshooting
                print("DEBUG: Authentication error occurred: \(error.localizedDescription)")
                // Display an error alert to inform the user of the problem
                self.showAlert(title: "Login Error", message: error.localizedDescription)
                // Stop further execution if there's an error
                return
            }

            // Ensure the authentication result is not nil
            guard let authResult = authResult else {
                // Reset the isSigningIn state to allow subsequent sign-in attempts
                self.isSigningIn = false
                // Print debug information for unexpected nil auth result
                print("DEBUG: Authentication result is nil, this should not happen without an error.")
                // Display an alert for an unexpected error
                self.showAlert(title: "Unexpected Error", message: "Unable to sign in. Please try again.")
                // Stop further execution if authResult is nil
                return
            }

            // Successful authentication, proceed with the authenticated user
            let user = authResult.user
            print("DEBUG: Auth result successful for user: \(user.email ?? "unknown email")")
            
            // Navigate to the main Tab Bar
            self.navigateToMainTabBar()

            // Reset the isSigningIn flag since navigation is complete
            self.isSigningIn = false
        }
    }



    private func navigateToMainTabBar() {
        print("DEBUG: Attempting to navigate to Main Tab Bar")
        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Ensure that we're able to instantiate the tab bar controller from storyboard
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController {
                print("DEBUG: Successfully instantiated Main Tab Bar Controller")

                // Get the SceneDelegate instance to perform the root view controller change
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    print("DEBUG: SceneDelegate found. Proceeding with changing root view controller.")
                    sceneDelegate.changeRootViewController(to: tabBarController, animated: true)
                } else {
                    print("DEBUG: Unable to find SceneDelegate.")
                    self.showAlert(title: "Navigation Error", message: "Unable to navigate to the main screen. Please try again.")
                }
            } else {
                print("DEBUG: Failed to instantiate the tab bar controller from storyboard.")
                self.showAlert(title: "Navigation Error", message: "Unable to navigate to the main screen. Please try again.")
            }
        }
    }



    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            if self.view.window != nil {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                print("DEBUG: Attempted to present alert while view was not in window hierarchy.")
            }
        }
    }


    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }

    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
