import FirebaseFirestore
import CoreLocation
import Foundation

func ensureFacilitiesAndBeaconsExistInBuildings() {
    let requiredFacilities = ["toilets", "elevators", "cafeterias"]
    let db = Firestore.firestore()
    
    // helper function to generate major and minor values
    func generateMajorMinorValues() -> ( CLBeaconMajorValue, CLBeaconMinorValue){
        let major = CLBeaconMajorValue.random(in: 1 ... 65535)
        let minor = CLBeaconMinorValue.random(in: 1 ... 65535)
        return (major,minor)
    }

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
                if document.data()[facility] == nil {
                    // Facility is missing, add it with a default value (e.g., true)
                    facilitiesToUpdate[facility] = true
                }
            }
            //step 3: Ensure the building has a major value
            if document.data()["major"] == nil {
                let majorValue = CLBeaconMajorValue.random(in: 1 ... 65535)
                facilitiesToUpdate["major"] = majorValue
                print("Assigned major value \(majorValue) to building \(buildingID)")
            }
          
            //  Update building with missing facilities or major value
            if !facilitiesToUpdate.isEmpty {
                db.collection("buildings").document(buildingID).updateData(facilitiesToUpdate) { error in
                    if let error = error {
                        print("Error updating building \(buildingID) \(error.localizedDescription)")
                    } else {
                        print("Building \(buildingID) successfully updated.")
                    }
                }
            }
            
            // Step 4: Process rooms in the building
                        let roomsCollection = db.collection("buildings").document(buildingID).collection("rooms")
                        roomsCollection.getDocuments { (roomSnapshot, error) in
                            guard let roomDocuments = roomSnapshot?.documents, error == nil else {
                                print("Error fetching rooms for building \(buildingID): \(error?.localizedDescription ?? "Unknown error")")
                                return
                            }
                            
                            // Fetch the major value for the building
                                let buildingMajorValue = document.data()["major"] as? CLBeaconMajorValue


                            for roomDocument in roomDocuments {
                                let roomID = roomDocument.documentID
                                var roomDataToUpdate: [String: Any] = [:]

                                // Ensure the room has a minor value
                                if roomDocument.data()["minor"] == nil {
                                    let minorValue = CLBeaconMinorValue.random(in: 1...65535)
                                   
                                    roomDataToUpdate["minor"] = minorValue
                            
                                    print("Assigned minor value \(minorValue) to room \(roomID) in building \(buildingID)")
                                }
                                // ensure the room has the building's major value
                                if roomDocument.data()["major"] == nil, let majorValue = buildingMajorValue{
                                    roomDataToUpdate["major"] = majorValue
                                    print("Assigned major value \(majorValue) to room \(roomID) in building \(buildingID)")
                                }

                                // Update the room with the minor value
                                if !roomDataToUpdate.isEmpty {
                                    roomsCollection.document(roomID).updateData(roomDataToUpdate) { error in
                                        if let error = error {
                                            print("Error updating room \(roomID) in building \(buildingID): \(error.localizedDescription)")
                                        } else {
                                            print("Room \(roomID) in building \(buildingID) successfully updated.")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            
            

          

                
            
