//
//  FirestoreHelper.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 20/11/2024.
//

import FirebaseFirestore

class FirestoreHelper {
    static let shared = FirestoreHelper() // Singleton instance
    private let db = Firestore.firestore() // Firestore reference

    private init() {} // Private init to ensure it's used as a singleton

    // Function to add latitude and longitude to all buildings with checks
    static func addLatLongToBuildings(transaction: Transaction) {
        let buildings = [
            ("lordAshcroft", 52.2039, 0.1343),
            ("scienceCentre", 52.20368, 0.13483),
            ("davidBuilding", 52.20266, 0.13555),
            ("ruskinBuilding", 52.20382, 0.13313),
            ("aruStudentUnion", 52.20292, 0.13550),
            ("cosletteBuilding", 52.202633, 0.135601),
            ("helmoreBuilding", 52.20383, 0.13314)
        ]

        var documentsToUpdate: [(DocumentReference, Double, Double)] = []

        // Read Phase: Check which buildings need updates
        for (buildingID, latitude, longitude) in buildings {
            let buildingDocument = Firestore.firestore().collection("buildings").document(buildingID)
            do {
                let snapshot = try transaction.getDocument(buildingDocument)
                if snapshot.exists {
                    let data = snapshot.data() ?? [:]
                    if data["latitude"] == nil || data["longitude"] == nil {
                        documentsToUpdate.append((buildingDocument, latitude, longitude))
                    } else {
                        print("DEBUG: Latitude and longitude already exist for building \(buildingID). Skipping...")
                    }
                } else {
                    print("DEBUG: Building \(buildingID) does not exist.")
                }
            } catch let error {
                print("DEBUG: Error fetching building document: \(error.localizedDescription)")
            }
        }

        // Write Phase: Update only the necessary documents
        for (buildingDocument, latitude, longitude) in documentsToUpdate {
            transaction.updateData([
                "latitude": latitude,
                "longitude": longitude
            ], forDocument: buildingDocument)
            print("DEBUG: Added latitude and longitude to building \(buildingDocument.documentID).")
        }
    }

    
    
}
