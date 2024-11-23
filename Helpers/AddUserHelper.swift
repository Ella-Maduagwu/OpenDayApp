import Foundation
import FirebaseFirestore
import FirebaseAuth

class AddUserHelper {
    static let shared = AddUserHelper() // Singleton instance
    private let db = Firestore.firestore() // Firestore reference

    // MARK: Hardcoded Details
    private let hardcodedEmail = "karen.bell@aru.ac.uk"
    private let hardcodedPassword = "ELGZFO"
    private let hardcodedCourseName = "Business"

    // Function to create a new user, assign a course, and populate Firestore using hardcoded details
    func createUser() {
        let email = hardcodedEmail
        let password = hardcodedPassword
        let courseName = hardcodedCourseName

        // Create the user in Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let userID = authResult?.user.uid, error == nil else {
                print("Error creating user: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Create a user document in Firestore
            self?.db.collection("users").document(userID).setData([
                "email": email,
                "courseName": courseName
            ]) { error in
                if let error = error {
                    print("Error storing user data in Firestore: \(error.localizedDescription)")
                } else {
                    print("User data stored successfully in Firestore with assigned course: \(courseName)")
                }
            }
        }
    }

    // Function to assign a course to a user without one using hardcoded UID and courseName
    func assignCourseToUser(userID: String) {
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if data?["courseName"] == nil {
                    print("User does not have a course assigned. Assigning 'Software Engineering' course...")

                    // Update user document with hardcoded course assignment
                    userRef.updateData(["courseName": self?.hardcodedCourseName ?? "Unknown Course"]) { error in
                        if let error = error {
                            print("Error updating user with course assignment: \(error.localizedDescription)")
                        } else {
                            print("User updated successfully with course assignment: \(self?.hardcodedCourseName ?? "Unknown Course")")
                        }
                    }
                } else {
                    print("User already has a course assigned.")
                }
            } else if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
            }
        }
    }

    // Function to assign a course to an existing user based on their email using hardcoded email and courseName
    func assignExistingUserCourse() {
        let email = hardcodedEmail
        let courseName = hardcodedCourseName

        // Find the user in Firestore by their email
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { [weak self] (querySnapshot, error) in
            guard let document = querySnapshot?.documents.first, error == nil else {
                print("Error finding user: \(error?.localizedDescription ?? "User not found.")")
                return
            }

            let userID = document.documentID
            let userData = document.data()

            // Check if the user already has a course assigned
            if let existingCourseName = userData["courseName"] as? String, !existingCourseName.isEmpty {
                print("User already has a course assigned: \(existingCourseName)")
                return
            }

            print("User does not have a course assigned. Assigning 'Software Engineering' course...")

            // Update the user document in Firestore to assign the hardcoded course
            self?.db.collection("users").document(userID).updateData([
                "courseName": courseName
            ]) { error in
                if let error = error {
                    print("Error updating user with course assignment: \(error.localizedDescription)")
                } else {
                    print("User updated successfully with course assignment: \(courseName)")
                }
            }
        }
    }
}
