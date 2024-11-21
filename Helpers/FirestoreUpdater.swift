//
//  FirestoreUpdater.swift
//  OpenDayApp
///THIS IS A SINGLETON HELPER CLASS
//  Created by Emmanuella Maduagwu
//
import FirebaseFirestore

class FirestoreUpdater {
    static let shared = FirestoreUpdater() // Singleton instance
    private let db = Firestore.firestore() // Firestore reference
    
    private init() {} // Private init to ensure it's used as a singleton
    
    // Function to add a new building if it doesn't already exist
    func addBuilding(documentID: String, buildingData: [String: Any], rooms: [(String, String)]) {
        let buildingDocument = db.collection("buildings").document(documentID)
        
        buildingDocument.getDocument { (document, error) in
            if let document = document, document.exists {
                print("Building \(documentID) already exists. Skipping addition...")
            } else {
                buildingDocument.setData(buildingData) { err in
                    if let err = err {
                        print("Error adding building: \(err.localizedDescription)")
                    } else {
                        print("Building \(documentID) successfully added.")
                        // Add rooms to the newly created building
                        self.addRoomsToBuilding(buildingID: documentID, rooms: rooms)
                    }
                }
            }
        }
    }
    
    // Function to add new rooms to an existing building
    func addRoomsToBuilding(buildingID: String, rooms: [(String, String)]) {
        let buildingDocument = db.collection("buildings").document(buildingID)
        
        buildingDocument.getDocument { (document, error) in
            if let document = document, document.exists {
                for (roomID, roomName) in rooms {
                    let roomDocument = buildingDocument.collection("rooms").document(roomID)
                    
                    roomDocument.getDocument { (roomDoc, roomError) in
                        if let roomDoc = roomDoc, roomDoc.exists {
                            print("Room \(roomID) already exists in \(buildingID). Skipping...")
                        } else {
                            roomDocument.setData(["name": roomName]) { roomErr in
                                if let roomErr = roomErr {
                                    print("Error adding room \(roomID): \(roomErr.localizedDescription)")
                                } else {
                                    print("Room \(roomID) successfully added to \(buildingID).")
                                }
                            }
                        }
                    }
                }
            } else {
                if let error = error {
                    print("Error finding building: \(error.localizedDescription)")
                } else {
                    print("Building \(buildingID) does not exist. Cannot add rooms.")
                }
            }
        }
    }
    
    // Function to add a new course if it doesn't already exist
    func addCourse(courseName: String, talks: [(String, String, String, String)]) {
        let courseDocument = db.collection("courses").document(courseName)
        
        courseDocument.getDocument { (document, error) in
            if let document = document, document.exists {
                print("Course \(courseName) already exists. Skipping addition...")
            } else {
                courseDocument.setData(["name": courseName]) { err in
                    if let err = err {
                        print("Error adding course: \(err.localizedDescription)")
                    } else {
                        print("Course \(courseName) successfully added.")
                    }
                }
            }
        }
    }
    
    // Function to add buildings and rooms from a predefined list, ensuring no duplicates
    func addBuildingsFromList() {
        let buildings = [
            ("aruStudentUnion", [
                "name": "ARU Student Union",
                "address": "Cambridge Campus, East Road"
            ], [
                ("Room_001", "Room 001"),
                ("Room_002", "Room 002"),
                ("Toilet_A", "Toilet A"),
                ("Toilet_B", "Toilet B")
            ]),
            ("cosletteBuilding", [
                "name": "Coslette Building",
                "address": "Cambridge Campus, East Road"
            ], [
                ("Room_001", "Room 001"),
                ("Room_002", "Room 002"),
                ("Toilet_A", "Toilet A"),
                ("Toilet_B", "Toilet B")
            ]),
            ("helmoreBuilding", [
                "name": "Helmore Building",
                "address": "Cambridge Campus, East Road"
            ], [
                ("Room_001", "Room 001"),
                ("Room_002", "Room 002"),
                ("Toilet_A", "Toilet A"),
                ("Toilet_B", "Toilet B")
            ])
        ]
        
        for (buildingID, buildingData, rooms) in buildings {
            addBuilding(documentID: buildingID, buildingData: buildingData, rooms: rooms)
        }
        
    }
    
    
    
}
