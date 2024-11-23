//
//  AddCourseInfoHelper.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 22/11/2024.
//

import FirebaseFirestore
import Foundation
class AddCourseInfoHelper {
    private let db = Firestore.firestore() // Firestore reference
    static let shared = AddCourseInfoHelper() 

        /// Updates all existing courses in the Firestore "courses" collection to add `infoLink` and `briefDescription` fields.
        func addDetailsToAllCourses() {
            db.collection("courses").getDocuments { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents, error == nil else {
                    print("Error fetching courses: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                for document in documents {
                    let courseName = document.documentID // Use course name as the document identifier

                    // Define the new fields to add to each course
                    let infoLink = "https://aru.ac.uk/courses/\(courseName.replacingOccurrences(of: " ", with: "-").lowercased())"
                    let briefDescription = "This is a brief description for the course named \(courseName)."

                    // Update the course document with the new fields
                    self?.db.collection("courses").document(courseName).updateData([
                        "infoLink": infoLink,
                        "briefDescription": briefDescription
                    ]) { error in
                        if let error = error {
                            print("Error updating course \(courseName) with new fields: \(error.localizedDescription)")
                        } else {
                            print("Successfully updated course \(courseName) with infoLink and briefDescription.")
                        }
                    }
                }
            }
        }
    }

    

