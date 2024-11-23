import Foundation

// Assuming Firebase is configured somewhere in your app, and that we can interact with it.
func main() {
    let helper = AddUserHelper.shared

    // Menu loop
    var shouldContinue = true
    while shouldContinue {
        // Provide options for the user
        print("\nWhat would you like to do?")
        print("1. Create a New User and Assign a Course")
        print("2. Assign a Course to a User without a Course (Using UID)")
        print("3. Assign a Course to an Existing User by Email")
        print("4. Exit")
        
        // Prompt the user for their choice
        print("Enter your choice (1/2/3/4):", terminator: " ")
        guard let choice = readLine(), let choiceNumber = Int(choice) else {
            print("Invalid input. Please enter a number between 1 and 4.")
            continue
        }
        
        // Process the user choice
        switch choiceNumber {
        case 1:
            // Create a new user and assign a course
            helper.createUser()
        case 2:
            // Assign a course to an existing user by UID
            print("Enter the User UID:", terminator: " ")
            guard let userID = readLine(), !userID.isEmpty else {
                print("Invalid User UID.")
                continue
            }
            helper.assignCourseToUser(userID: userID)
        case 3:
            // Assign a course to an existing user by email
            helper.assignExistingUserCourse()
        case 4:
            // Exit the program
            shouldContinue = false
            print("Exiting the program. Goodbye!")
        default:
            print("Invalid choice. Please enter a number between 1 and 4.")
        }
    }
}



