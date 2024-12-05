import UIKit
import FirebaseFirestore
import CoreLocation
import MapKit
import UserNotifications


class RoomsViewController: UIViewController, CLLocationManagerDelegate  {
    @IBOutlet weak var tableView: UITableView!
    var rooms: [Room] = [] // Room is a model class that holds room data
    let db = Firestore.firestore()
    var buildingName: String?
    let locationManager = CLLocationManager() // line to declare locationManager
    static var selectedRoom : Room? // static property to track the selected room

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = buildingName // Set the title to the building name
        // Set up the table view with delegate and data source
        
        // Ensure the navigation bar is visible
           self.navigationController?.setNavigationBarHidden(false, animated: false)

           // Set the navigation bar title and button colors for dynamic appearance
           self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
           self.navigationController?.navigationBar.tintColor = UIColor.label

           // Set the navigation bar background color
           self.navigationController?.navigationBar.barTintColor = UIColor.systemBackground

        setupTableView()
        setupHeader()
        setupFooter()
        setupNavigationBar()
                if let buildingName = buildingName {
            let buildingID = getFirestoreDocumentID(for: buildingName)
            if !buildingID.isEmpty {
                fetchRoomsForBuilding(buildingID: buildingID) // Fetch rooms based on the selected building
            } else {
                print("DEBUG: Invalid building name provided. Unable to fetch rooms.")
            }
        } else {
            print("DEBUG: No building name provided.")
        }
        
        
        // Request location permissions
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        requestNotificationPermission()

    }
    
    // Delegate to handle changes in authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           switch status {
           case .authorizedWhenInUse, .authorizedAlways:
               print("DEBUG: Location access granted.")
           case .denied, .restricted:
               print("DEBUG: Location access denied.")
           default:
               break
           }
       }
   
  
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            } else {
                print("Notification permission denied")
            }
        }
    }

    
    
    // Sets up the header for the page with the title.
    private func setupHeader() {
        let headerLabel = UILabel()
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Sets up the footer for the page with instructions.
    private func setupFooter() {
        let footerLabel = UILabel()
        footerLabel.text = "Tap any room to navigate to it."
        footerLabel.textColor = .black
        footerLabel.textAlignment = .center
        footerLabel.font = UIFont.systemFont(ofSize: 14)
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerLabel)
        NSLayoutConstraint.activate([
            footerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    /// Sets up the navigation bar to include a button for the QR code scanner.
      private func setupNavigationBar() {
          let scanButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(scanQRCode))
          navigationItem.rightBarButtonItem = scanButton
      }
    
    /// Action to scan a QR code.
        @objc private func scanQRCode() {
            // Here you can add your QR code scanning functionality.
            let scannerVC = ScannerViewController() // Assuming you have a ScannerViewController class.
            navigationController?.pushViewController(scannerVC, animated: true)
        }

    /// Helper function to match building names with Firestore document IDs.
    private func getFirestoreDocumentID(for buildingName: String) -> String {
        switch buildingName {
        case "Lord Ashcroft Building":
            return "lordAshcroft"
        case "Science Centre":
            return "scienceCentre"
        case "David Building":
            return "davidBuilding"
        case "Ruskin Building":
            return "ruskinBuilding"
        case "Helmore Building":
            return "helmoreBuilding"
        case "Coslette Building":
            return "cosletteBuilding"
        case "ARU Student Union":
            return "aruStudentUnion"
        default:
            return ""

        }
    }
    
    /// Configures the table view delegate, data source, and appearance.
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RoomCell")
        
        // Set table view appearance
              tableView.layer.cornerRadius = 10
              tableView.clipsToBounds = true
              tableView.separatorStyle = .none
    }

    // Fetch rooms based on the selected building name.
    private func fetchRoomsForBuilding(buildingID: String) {
        let buildingDocument = db.collection("buildings").document(buildingID)
        
        let roomsCollection = buildingDocument.collection("rooms")

        print("DEBUG: Fetching rooms for building with ID: \(buildingID)")

        roomsCollection.getDocuments { [weak self] (querySnapshot, error: Error?) in
            guard let self = self else { return }

            if let error = error {
                print("DEBUG: Error occurred while fetching rooms: \(error.localizedDescription)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("DEBUG: No room documents found for building with ID: \(buildingID)")
                return
            }

            self.rooms.removeAll() // clear the array to remove any previous input

            for document in documents {
                if let roomData = Room(data: document.data(), buildingID: buildingID) {
                    self.rooms.append(roomData)
                    print("DEBUG: Added room with name: \(roomData.name)")
                } else {
                    print("DEBUG: Room document \(document.documentID) does not contain valid data.")
                }
            }


            DispatchQueue.main.async {
                print("DEBUG: Reloading tableView with \(self.rooms.count) rooms.")
                self.tableView.reloadData() // reload the table view to display the rooms
            }
        }
    }
}

extension RoomsViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// Returns the number of rows in the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DEBUG: Number of rows in section: \(rooms.count)")
        return rooms.count
    }
    
    /// Configures the cell for each row in the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath)
        let room = rooms[indexPath.row]
        cell.textLabel?.text = room.name
        cell.accessibilityLabel = "Room: \(room.name)"
        
        // Set cell appearance
              cell.backgroundColor = .systemYellow
              cell.layer.cornerRadius = 8
              cell.clipsToBounds = true
        
        return cell
    }

    /// Handles row selection and initiates turn-by-turn navigation.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = rooms[indexPath.row]
        RoomsViewController.selectedRoom = room 
        initiateNavigation(to: room)
    }
    
    /// Adds spacing between cells in the table view.
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 50 // Adjust height as needed
       }
}

extension RoomsViewController {
    
    func initiateNavigation(to room: Room) {
        let buildingDocument = db.collection("buildings").document(room.buildingID)
        
        buildingDocument.getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let error = error {
                print("DEBUG: Error fetching building for navigation: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let latitude = data["latitude"] as? Double,
                  let longitude = data["longitude"] as? Double else {
                print("DEBUG: Building document does not contain valid coordinates.")
                return
            }
            
        //set up geofencing for the building
           // Use the building's coordinates to open map and start navigation
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            GeolocationManager.shared.setupGeofencing()
            
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = room.name
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
            mapItem.openInMaps(launchOptions: launchOptions)
            
            
            // Notify the user about beacon scanning when they arrive at the building
            let alert = UIAlertController(
                title: "Indoor Navigation",
                message: "if you arrived at the building? iBeacon signalling should start now.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)

        }
    }

}
