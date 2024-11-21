//
//  AddToiletsHelper.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 21/11/2024.
//

import FirebaseFirestore

func addToiletsToAllBuildings() {
    let db = Firestore.firestore() // Firestore reference
    let buildingsCollection = db.collection("buildings")

    // Define the toilets to be added
    let toilets = [
        ("Toilet_A", "Toilet A"),
        ("Toilet_B", "Toilet B"),
        ("Toilet_C", "Toilet C")
    ]

    // Get all building documents
    buildingsCollection.getDocuments { (querySnapshot, error) in
        if let error = error {
            print("Error fetching buildings: \(error.localizedDescription)")
            return
        }

        guard let documents = querySnapshot?.documents else {
            print("No buildings found.")
            return
        }

        for document in documents {
            let buildingID = document.documentID
            let buildingName = document.data()["name"] as? String ?? "Unknown Building"

            // Add toilets to each building
            for (toiletID, toiletName) in toilets {
                let roomDocument = buildingsCollection.document(buildingID).collection("rooms").document(toiletID)

                roomDocument.getDocument { (roomDoc, roomError) in
                    if let roomDoc = roomDoc, roomDoc.exists {
                        print("\(toiletName) already exists in \(buildingName). Skipping...")
                    } else {
                        roomDocument.setData(["name": toiletName]) { roomErr in
                            if let roomErr = roomErr {
                                print("Error adding \(toiletName) to \(buildingName): \(roomErr.localizedDescription)")
                            } else {
                                print("\(toiletName) successfully added to \(buildingName).")
                            }
                        }
                    }
                }
            }
        }
    }
}
