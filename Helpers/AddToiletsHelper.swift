import FirebaseFirestore
import Foundation

 func ensureFacilitiesExistInBuildings() {
    let requiredFacilities = ["toilets", "elevators", "cafeterias"]
    let db = Firestore.firestore()

    db.collection("buildings").getDocuments { (querySnapshot, error) in
        guard let documents = querySnapshot?.documents, error == nil else {
            print("Error fetching buildings: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        for document in documents {
            var facilitiesToUpdate: [String: Any] = [:]

            for facility in requiredFacilities {
                // Check if the facility exists in the current building document
                if document.data()[facility] == nil {
                    // Facility is missing, add it with a default value (e.g., false)
                    facilitiesToUpdate[facility] = true
                }
            }

            // If we added any missing facilities, update the Firestore document
            if !facilitiesToUpdate.isEmpty {
                db.collection("buildings").document(document.documentID).updateData(facilitiesToUpdate) { error in
                    if let error = error {
                        print("Error updating building \(document.documentID) with missing facilities: \(error.localizedDescription)")
                    } else {
                        print("Building \(document.documentID) successfully updated with missing facilities.")
                    }
                }
            }
        }
    }
}
