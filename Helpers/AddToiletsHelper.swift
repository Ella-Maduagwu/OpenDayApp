import FirebaseFirestore
import Foundation

func ensureFacilitiesAndBeaconsExistInBuildings() {
    let requiredFacilities = ["toilets", "elevators", "cafeterias"]
    let db = Firestore.firestore()

    // Step 1: Fetch all buildings
    db.collection("buildings").getDocuments { (querySnapshot, error) in
        guard let documents = querySnapshot?.documents, error == nil else {
            print("Error fetching buildings: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        for document in documents {
            let buildingID = document.documentID
            var facilitiesToUpdate: [String: Any] = [:]

            // Step 2: Ensure all required facilities exist
            for facility in requiredFacilities {
                // Check if the facility exists in the current building document
                if document.data()[facility] == nil {
                    // Facility is missing, add it with a default value (e.g., true)
                    facilitiesToUpdate[facility] = true
                }
            }

            // Step 3: Update building with missing facilities
            if !facilitiesToUpdate.isEmpty {
                db.collection("buildings").document(buildingID).updateData(facilitiesToUpdate) { error in
                    if let error = error {
                        print("Error updating building \(buildingID) with missing facilities: \(error.localizedDescription)")
                    } else {
                        print("Building \(buildingID) successfully updated with missing facilities.")
                    }
                }
            }

            // Step 4: Ensure each room in the building has a Beacon UUID
            db.collection("buildings").document(buildingID).collection("rooms").getDocuments { (roomsSnapshot, error) in
                guard let rooms = roomsSnapshot?.documents, error == nil else {
                    print("Error fetching rooms for building \(buildingID): \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                for room in rooms {
                    let roomID = room.documentID
                    if room.data()["beaconUUID"] == nil {
                        // Generate a new UUID for the room
                        let newUUID = UUID().uuidString

                        // Update room document with the new Beacon UUID
                        db.collection("buildings").document(buildingID).collection("rooms").document(roomID).updateData([
                            "beaconUUID": newUUID
                        ]) { error in
                            if let error = error {
                                print("Error updating room \(roomID) in building \(buildingID) with beacon UUID: \(error.localizedDescription)")
                            } else {
                                print("Room \(roomID) in building \(buildingID) successfully updated with beacon UUID.")
                            }
                        }
                    }
                }
            }
        }
    }
}
