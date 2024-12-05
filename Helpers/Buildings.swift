import FirebaseFirestore

func addBuildingsAndCourses() {
    let db = Firestore.firestore()
    
    // Reference to the buildings collection
    let buildingsCollection = db.collection("buildings")
    
    // Add a building with transactional consistency
    db.runTransaction({ (transaction, errorPointer) -> Any? in
        do {
            // Adding information for each building
            // Lord Ashcroft Building
            let lordAshcroftDocument = buildingsCollection.document("lordAshcroft")
            transaction.setData([
                "name": "Lord Ashcroft Building",
                "address": "Cambridge Campus, East Road"
            ], forDocument: lordAshcroftDocument)
            
            let lordAshcroftRooms = [
                ("LAB_026", "LAB 026"),
                ("LAB_003", "LAB 003"),
                ("LAB_211", "LAB 211"),
                ("LAB_207", "LAB 207"),
                ("LAB_117", "LAB 117"),
                ("LAB_111", "LAB 111"),
                ("LAB_112", "LAB 112"),
                ("LAB_113", "LAB 113"),
                ("LAB_005", "LAB 005")
               
            ]
            
            // Adding rooms for Lord Ashcroft Building
            for (roomID, roomName) in lordAshcroftRooms {
                let roomDocument = lordAshcroftDocument.collection("rooms").document(roomID)
                transaction.setData([
                    "name": roomName
                ], forDocument: roomDocument)
            }
            
            // Science Centre
            let scienceCentreDocument = buildingsCollection.document("scienceCentre")
            transaction.setData([
                "name": "Science Centre",
                "address": "Cambridge Campus, East Road"
            ], forDocument: scienceCentreDocument)
            
            let scienceCentreRooms = [
                ("Sci_303", "SCI 303"),
                ("Sci_105", "SCI 105"),
                ("Sci_106", "SuperLab"),
                ("Sci_713", "SCI 713"),
                ("Sci_721", "SCI 721")
               
            ]
            
            // Adding rooms for Science Centre
            for (roomID, roomName) in scienceCentreRooms {
                let roomDocument = scienceCentreDocument.collection("rooms").document(roomID)
                transaction.setData([
                    "name": roomName
                ], forDocument: roomDocument)
            }
            
            // David Building
            let davidBuildingDocument = buildingsCollection.document("davidBuilding")
            transaction.setData([
                "name": "David Building",
                "address": "Cambridge Campus, East Road"
            ], forDocument: davidBuildingDocument)
            
            let davidRooms = [
                ("Dav_001", "DAV 001"),
                ("Dav_204", "DAV 204")
                
            ]
            
            // Adding rooms for David Building
            for (roomID, roomName) in davidRooms {
                let roomDocument = davidBuildingDocument.collection("rooms").document(roomID)
                transaction.setData([
                    "name": roomName
                ], forDocument: roomDocument)
            }
            
            // Ruskin Building
            let ruskinBuildingDocument = buildingsCollection.document("ruskinBuilding")
            transaction.setData([
                "name": "Ruskin Building",
                "address": "Cambridge Campus, East Road"
            ], forDocument: ruskinBuildingDocument)
            
            let ruskinRooms = [
                ("Rus_203", "Rus 203"),
                ("Rus_220", "RUS 220"),
                ("Rus_137", "RUS 137"),
                ("Rus_108", "RUS 108"),
                ("Rus_135", "RUS 135"),
                ("Rus_208", "RUS 208"),
                ("Rus_212", "RUS 212")
              
            ]
            
            // Adding rooms for Ruskin Building
            for (roomID, roomName) in ruskinRooms {
                let roomDocument = ruskinBuildingDocument.collection("rooms").document(roomID)
                transaction.setData([
                    "name": roomName
                ], forDocument: roomDocument)
            }
            
            // Adding courses and course talks
            let coursesCollection = db.collection("courses")
            
            let courses = [
                ("Biomedical Science", [
                    ("Meet the team", "Science Centre", "Sci_106", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Science Centre", "Sci_105", "12:00 PM")
                ]),
                ("Business", [
                    ("Meet the team", "Lord Ashcroft Building", "LAB_117", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Lord Ashcroft Building", "LAB_111-113", "11:00 AM"),
                    ("Bloomberg Lab demonstration", "Lord Ashcroft Building", "LAB_223", "11:45 AM"),
                    ("ARUCPD Taster Session", "Lord Ashcroft Building", "LAB_111-113", "12:30 PM")
                ]),
                ("Art and Design", [
                    ("Meet the team", "Ruskin Gallery", "RUS_001", "10:00 AM - 2:00 PM"),
                    ("Welcome talk", "Ruskin Building", "Rus_203", "10:40 AM"),
                    ("Course talk", "Ruskin Building", "Rus_135", "11:15 AM"),
                    ("Creative Facilities Tour", "Ruskin Gallery", "RUS_001", "12:00 PM"),
                    ("Portfolio guidance", "Ruskin Building", "Rus_203", "1:30 PM")
                ]),
                ("Criminology", [
                    ("Meet the team", "Lord Ashcroft Building", "LAB_005", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Lord Ashcroft Building", "LAB_002", "11:45 AM"),
                    ("Taster Lecture: Demystifying the Dark Web", "Lord Ashcroft Building", "LAB_207", "1:15 PM")
                ]),
                ("Computer Games", [
                    ("Meet the team", "David Building", "Dav_204", "10:00 AM - 2:00 PM"),
                    ("Welcome talk", "Mumford Theatre", "MUM_001", "10:40 AM"),
                    ("Course talk", "David Building", "Dav_204", "11:15 AM")
                ]),
                ("Education", [
                    ("Meet the team", "Lord Ashcroft Building", "LAB_210", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Lord Ashcroft Building", "LAB_002", "10:45 AM"),
                    ("Primary Education Studies Course talk", "Lord Ashcroft Building", "LAB_212", "12:45 PM"),
                    ("Education Taster Lecture", "Lord Ashcroft Building", "LAB_207", "1:30 PM")
                ]),
                ("English and Literature", [
                    ("Meet the team", "Lord Ashcroft Building", "LAB_006", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Lord Ashcroft Building", "LAB_207", "10:45 AM"),
                    ("Taster Lecture: Father Christmas in Literature", "Lord Ashcroft Building", "LAB_207", "12:30 PM")
                ]),
                ("Film and Media", [
                    ("Meet the team", "Lord Ashcroft Building", "LAB_028", "10:00 AM - 2:00 PM"),
                    ("Welcome talk", "Mumford Theatre", "MUM_001", "10:40 AM"),
                    ("Course talk and tour", "Coslett Building", "COS_117", "11:15 AM")
                ]),
                ("Psychology", [
                    ("Meet the team", "Science Centre", "Sci_704", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Science Centre", "Sci_105", "11:30 AM"),
                    ("Course talk", "Science Centre", "Sci_704", "1:00 PM")
                ]),
                ("Sport Sciences", [
                    ("Meet the team", "Compass House", "COM_302", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Science Centre", "Sci_105", "10:40 AM"),
                    ("Course talk", "Compass House", "COM_317", "1:00 PM")
                ]),
                ("Writing", [
                    ("Meet the team", "Lord Ashcroft Building", "LAB_028", "10:00 AM - 2:00 PM"),
                    ("Welcome talk", "Mumford Theatre", "MUM_001", "10:40 AM"),
                    ("Course talk", "Lord Ashcroft Building", "LAB_213", "11:15 AM")
                ]),
                ("Law", [
                    ("Meet the team", "Lord Ashcroft Building", "LAB_119", "10:00 AM - 2:00 PM"),
                    ("Course talk and taster session", "Lord Ashcroft Building", "LAB_111-113", "11:00 AM")
                ]),
                ("Midwifery", [
                    ("Meet the team", "Young Street", "YST_018", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Young Street", "YST_124", "11:00 AM")
                ]),
                ("Nursing", [
                    ("Adult Nursing Meet the team", "Young Street", "YST_010", "10:00 AM - 2:00 PM"),
                    ("Child Nursing Meet the team", "Young Street", "YST_009", "10:00 AM - 2:00 PM"),
                    ("Mental Health Nursing Meet the team", "Young Street", "YST_106", "10:00 AM - 2:00 PM"),
                    ("Course talk for all nursing courses", "Young Street", "YST_218", "11:45 AM")
                ]),
                ("Operating Department Practice", [
                    ("Meet the team", "Young Street", "YST_017", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Young Street", "YST_017", "11:30 AM")
                ]),
                ("Optometry", [
                    ("Meet the team", "University Eye Clinic", "UEC_001", "10:00 AM - 2:00 PM"),
                    ("Course talk and tour", "University Eye Clinic", "UEC_121", "11:30 AM")
                ]),
                ("Paramedic Science", [
                    ("Meet the team", "Young Street", "YST_030", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Young Street", "YST_129", "11:15 AM")
                ]),
                ("Social Work", [
                    ("Meet the team", "Young Street", "YST_107", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Young Street", "YST_107", "11:30 AM")
                ]),
                ("Music Performance, Production and Technology", [
                    ("Meet the team", "Helmore Building", "HEL_029", "10:00 AM - 2:00 PM"),
                    ("Welcome Talk", "Mumford Theatre", "MUM_001", "10:40 AM"),
                    ("Course talk and tour", "Helmore Building", "HEL_029", "11:15 AM")
                ]),
                ("Public Health", [
                    ("Meet the team", "Young Street", "YST_201", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Young Street", "YST_211", "12:00 PM")
                ]),
                ("Physiotherapy", [
                    ("Meet the team", "Young Street", "YST_125", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Young Street", "YST_126", "12:15 PM")
                ]),
                ("Forensic Science", [
                    ("Meet the team", "Science Centre", "Sci_115", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Science Centre", "Sci_117", "11:00 AM")
                ]),
                ("Engineering", [
                    ("Meet the team", "Compass House", "COM_210", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Science Centre", "Sci_220", "11:45 AM")
                ]),
                ("Architecture", [
                    ("Meet the team", "Coslett Building", "COS_310", "10:00 AM - 2:00 PM"),
                    ("Course talk and portfolio guidance", "Coslett Building", "COS_315", "1:00 PM")
                ]),
                ("International Relations", [
                    ("Meet the team", "Lord Ashcroft Building", "LAB_003", "10:00 AM - 2:00 PM"),
                    ("Course talk", "Lord Ashcroft Building", "LAB_111-113", "1:15 PM")
                ])
            ]
            
            // Adding courses and related talks
            for (courseName, talks) in courses {
                let courseDocument = coursesCollection.document(courseName)
                transaction.setData([
                    "name": courseName
                ], forDocument: courseDocument)
                
                let talksCollection = courseDocument.collection("talks")
                for (talkTitle, building, roomID, time) in talks {
                    let talkDocument = talksCollection.document()
                    transaction.setData([
                        "title": talkTitle,
                        "building": building,
                        "room": roomID,
                        "time": time
                    ], forDocument: talkDocument)
                }
            }
            
            return nil
        }
    }) { (object, error) in
        // Handling transaction result
        if let error = error {
            print("Transaction failed: \(error.localizedDescription)")
        } else {
            print("Transaction successfully committed!")
        }
    }
}


