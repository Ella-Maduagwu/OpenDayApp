import UIKit
import FirebaseFirestore

class AccessibilityViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let db = Firestore.firestore()
    
    var buildings: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView() // Set up the collection view with layout and delegate settings
        setupAccessibility() // Set up accessibility for better user experience
        setupHeader()
        fetchBuildings() // Fetch building names from Firestore
    }
    
    /// Configures the collection view layout, delegate, and data source.
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: self.view.frame.width / 2 - 15, height: self.view.frame.width / 2 - 15)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
                
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BuildingCollectionViewCell.self, forCellWithReuseIdentifier: BuildingCollectionViewCell.identifier)
    }
    
    /// Configures accessibility properties for the collection view.
    private func setupAccessibility() {
        collectionView.isAccessibilityElement = true
        collectionView.accessibilityLabel = "Building List"
        collectionView.accessibilityTraits = .allowsDirectInteraction
    }

    /// Fetches buildings from Firestore to populate the collection view.
    private func fetchBuildings() {
        let buildingsCollection = db.collection("buildings")

        buildingsCollection.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("DEBUG: Error occurred while fetching buildings: \(error.localizedDescription)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("DEBUG: No building documents found.")
                return
            }

            self.buildings.removeAll()
            for document in documents {
                if let buildingName = document.data()["name"] as? String {
                    self.buildings.append(buildingName)
                } else {
                    print("DEBUG: Building document \(document.documentID) does not contain a 'name' field.")
                }
            }

            DispatchQueue.main.async {
                print("DEBUG: Reloading collectionView with \(self.buildings.count) buildings.")
                self.collectionView.reloadData()
            }
        }
    }

    /// Sets up the header for the page with the title.
    private func setupHeader() {
        let headerLabel = UILabel()
        headerLabel.text = "Buildings"
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
    
    /// Prepares for segue to the RoomsViewController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRooms",
           let destinationVC = segue.destination as? RoomsViewController,
           let buildingName = sender as? String {
            destinationVC.buildingName = buildingName
        }
    }
}

extension AccessibilityViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// Returns the number of items in the section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buildings.count
    }
    
    /// Configures the cell for each item in the collection view.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BuildingCollectionViewCell.identifier, for: indexPath) as? BuildingCollectionViewCell else {
            assertionFailure("Failed to dequeue BuildingCollectionViewCell") // Assert failure if cell cannot be dequeued
            return UICollectionViewCell()
        }

        cell.configure(with: buildings[indexPath.row]) // Configure the cell with the building name
        return cell
    }
    
    /// Handles the selection of a cell in the collection view.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBuilding = buildings[indexPath.row]
        let roomsVC = storyboard?.instantiateViewController(withIdentifier: "RoomsViewController") as! RoomsViewController
        roomsVC.buildingName = selectedBuilding
        navigationController?.pushViewController(roomsVC, animated: true) // Trigger segue to RoomsViewController
    }
}
