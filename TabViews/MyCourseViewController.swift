import UIKit
import SafariServices
import FirebaseAuth
import FirebaseFirestore
import CoreLocation
import MapKit
import UserNotifications

class MyCourseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var courseDetailContainerView: UIView!
    
    let db = Firestore.firestore()
    var courseName: String?
    var courseInfoLink: String?
    var courseDescription: String?
    var talks: [Talk] = []
    var geolocationManager: GeolocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        fetchUserCourse()
        setupGeofencing()
    }
    
    // MARK: - View Setup
    private func setupView() {
        self.title = "My Course"
        // Styling for the course description block
        courseDetailContainerView.layer.cornerRadius = 15
        courseDetailContainerView.layer.masksToBounds = true
        courseDetailContainerView.layer.borderWidth = 1.0
        courseDetailContainerView.layer.borderColor = UIColor.lightGray.cgColor
        courseDetailContainerView.isHidden = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TalkTableViewCell.self, forCellReuseIdentifier: "TalkCell")
        let headerView = createTableHeaderView()
        tableView.tableHeaderView = headerView
    }
    
    private func createTableHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemYellow
        headerView.layer.cornerRadius = 2
       // headerView.translatesAutoresizingMaskIntoConstraints = false
        
       
    
       
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40) // Adjust height as needed
        tableView.tableHeaderView = headerView

        return headerView
    }
    
    // MARK: - Fetch Course Data
    private func fetchUserCourse() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user logged in.")
            displayCourseListForAnonymousUser()
            return
        }
        
        if currentUser.isAnonymous {
            print("Anonymous user detected, limited course access only.")
            displayCourseListForAnonymousUser()
            return
        }
        
        let userID = currentUser.uid
        db.collection("users").document(userID).getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching user course: \(error.localizedDescription)")
                return
            }
            
            guard let data = document?.data(), let courseName = data["courseName"] as? String else {
                print("No course data found for user.")
                return
            }
            
            self?.courseName = courseName
            self?.fetchCourseDetails(courseName: courseName)
        }
    }
    
    private func fetchCourseDetails(courseName: String) {
        db.collection("courses").document(courseName).getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching course details: \(error.localizedDescription)")
                return
            }
            
            guard let data = document?.data() else {
                print("Invalid course data or course document not found.")
                return
            }
            
            self?.courseDescription = data["briefDescription"] as? String ?? "No description available."
            self?.courseInfoLink = data["infoLink"] as? String
            
            // Update UI with course details
            DispatchQueue.main.async {
                self?.updateCourseDetailContainerView()
            }
            self?.fetchScheduledTalks(courseName: courseName)
        }
    }
    
    private func updateCourseDetailContainerView() {
               // Remove previous subviews to avoid duplication
               courseDetailContainerView.subviews.forEach { $0.removeFromSuperview() }
               
               let descriptionTextView = UITextView()
               descriptionTextView.text = courseDescription
               descriptionTextView.font = UIFont.systemFont(ofSize: 16)
               descriptionTextView.textColor = UIColor.darkGray
               descriptionTextView.isEditable = false
               descriptionTextView.isScrollEnabled = false
               descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
               
               courseDetailContainerView.addSubview(descriptionTextView)
               
               NSLayoutConstraint.activate([
                   descriptionTextView.leadingAnchor.constraint(equalTo: courseDetailContainerView.leadingAnchor, constant: 16),
                   descriptionTextView.trailingAnchor.constraint(equalTo: courseDetailContainerView.trailingAnchor, constant: -16),
                   descriptionTextView.topAnchor.constraint(equalTo: courseDetailContainerView.topAnchor, constant: 16)
               ])
               
               // Add the "View More Info" button inside the container view
               let moreInfoButton = UIButton(type: .system)
               moreInfoButton.setTitle("View More Info", for: .normal)
               moreInfoButton.addTarget(self, action: #selector(viewMoreInfoButtonTapped(_:)), for: .touchUpInside)
               moreInfoButton.translatesAutoresizingMaskIntoConstraints = false
               
               courseDetailContainerView.addSubview(moreInfoButton)
               
               NSLayoutConstraint.activate([
                   moreInfoButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
                   moreInfoButton.centerXAnchor.constraint(equalTo: courseDetailContainerView.centerXAnchor),
                   moreInfoButton.bottomAnchor.constraint(equalTo: courseDetailContainerView.bottomAnchor, constant: -16)
               ])
               
               courseDetailContainerView.isHidden = false
           }
    
    private func displayCourseListForAnonymousUser() {
           print("Anonymous user: Limited access to courses.")
           talks = []
           tableView.reloadData()
           tableView.isHidden = true
           
           courseDetailContainerView.subviews.forEach { $0.removeFromSuperview() }
           let anonymousTextView = UITextView()
           anonymousTextView.text = "As an anonymous user, you can only see general course information. Please log in to see personalized content."
           anonymousTextView.font = UIFont.systemFont(ofSize: 16)
           anonymousTextView.textColor = UIColor.darkGray
           anonymousTextView.isEditable = false
           anonymousTextView.isScrollEnabled = false
           anonymousTextView.translatesAutoresizingMaskIntoConstraints = false
           
           courseDetailContainerView.addSubview(anonymousTextView)
           
           NSLayoutConstraint.activate([
               anonymousTextView.leadingAnchor.constraint(equalTo: courseDetailContainerView.leadingAnchor, constant: 16),
               anonymousTextView.trailingAnchor.constraint(equalTo: courseDetailContainerView.trailingAnchor, constant: -16),
               anonymousTextView.topAnchor.constraint(equalTo: courseDetailContainerView.topAnchor, constant: 16),
               anonymousTextView.bottomAnchor.constraint(equalTo: courseDetailContainerView.bottomAnchor, constant: -16)
           ])
           
           courseDetailContainerView.isHidden = false
       }
           
           // MARK: - Fetch Scheduled Talks
           private func fetchScheduledTalks(courseName: String) {
               db.collection("courses").document(courseName).collection("talks").getDocuments { [weak self] (querySnapshot, error) in
                   if let error = error {
                       print("Error fetching talks: \(error.localizedDescription)")
                       return
                   }
                   
                   guard let documents = querySnapshot?.documents else {
                       print("No talks available for the course.")
                       return
                   }
                   
                   self?.talks = documents.compactMap { Talk(data: $0.data()) }
                   
                   DispatchQueue.main.async {
                       if self?.talks.isEmpty == true {
                           let noTalksLabel = UILabel(frame: self?.tableView.bounds ?? CGRect.zero)
                           noTalksLabel.text = "No talk for this event"
                           noTalksLabel.textAlignment = .center
                           noTalksLabel.textColor = UIColor.gray
                           self?.tableView.backgroundView = noTalksLabel
                       } else {
                           self?.tableView.backgroundView = nil
                       }
                       self?.tableView.reloadData()
                   }
               }
           }
           
           // MARK: - Navigation to External Course Info
           @objc func viewMoreInfoButtonTapped(_ sender: UIButton) {
               guard let infoLink = courseInfoLink, let url = URL(string: infoLink) else {
                   print("Invalid or missing URL for course information.")
                   return
               }
               let safariVC = SFSafariViewController(url: url)
               present(safariVC, animated: true)
           }
           
           // MARK: - Table View Data Source Methods
           func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
               return talks.count
           }
           
           func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
               guard let cell = tableView.dequeueReusableCell(withIdentifier: "TalkCell", for: indexPath) as? TalkTableViewCell else {
                   return UITableViewCell()
               }
               
               let talk = talks[indexPath.row]
               cell.titleLabel.text = talk.title
               cell.timeLabel.text = talk.time
               cell.venueLabel.text = "\(talk.building ?? "N/A"), Room: \(talk.room ?? "N/A")"
               
               return cell
           }
           
           // MARK: - Geofencing Logic
           private func setupGeofencing() {
               geolocationManager = GeolocationManager.shared
              // geolocationManager?.delegate = self
               geolocationManager?.setupGeofencing(for: db, collection: "buildings")
              
           }
           
           func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
               guard let circularRegion = region as? CLCircularRegion else { return }
               sendNotification(title: "Welcome!", body: "You are near the building: \(circularRegion.identifier).")
               fetchScheduledTalksForBuilding(buildingName: circularRegion.identifier)
           }
           
           func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
               guard let circularRegion = region as? CLCircularRegion else { return }
               sendNotification(title: "Goodbye!", body: "You have left the building: \(circularRegion.identifier).")
           }
           
           // MARK: - Central Notification Method
           private func sendNotification(title: String, body: String) {
               let content = UNMutableNotificationContent()
               content.title = title
               content.body = body
               content.sound = .default
               
               let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
               UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
           }
           
           // MARK: - Fetch Scheduled Talks for Building
           private func fetchScheduledTalksForBuilding(buildingName: String) {
               db.collection("courses").document(courseName ?? "").collection("talks").whereField("building", isEqualTo: buildingName).getDocuments { [weak self] (querySnapshot, error) in
                   guard let documents = querySnapshot?.documents, error == nil else {
                       print("Error fetching talks for building: \(error?.localizedDescription ?? "Unknown error")")
                       return
                   }
                   
                   if let upcomingTalk = documents.compactMap({ Talk(data: $0.data()) }).first {
                       self?.notifyUserOfUpcomingTalk(talk: upcomingTalk)
                   }
               }
           }
           
           private func notifyUserOfUpcomingTalk(talk: Talk) {
               let content = UNMutableNotificationContent()
               content.title = "Upcoming Talk Alert"
               content.body = "There is an upcoming talk titled '\(talk.title)' happening soon in \(talk.building ?? "the building")."
               content.sound = .default
               
               let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
               UNUserNotificationCenter.current().add(request) { (error) in
                   if let error = error {
                       print("Error adding notification: \(error.localizedDescription)")
                   }
               }
           }
    }

