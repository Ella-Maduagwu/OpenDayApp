import Foundation

struct Talk {
    var title: String
    var time: String  // Time in string format like "10:00 AM"
    var building: String?
    var room: String?

    // Initializer to create a Talk instance from Firestore data.
    init?(data: [String: Any]) {
        guard let title = data["title"] as? String,
              let time = data["time"] as? String else {
            print("Error: Missing 'title' or 'time' field in talk data.")
            return nil
        }
        self.title = title
        self.time = time
        self.building = data["building"] as? String
        self.room = data["room"] as? String
    }

    // Computed property to convert the 'time' string to a Date object
    var timeAsDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"  // Assuming the time is in "10:00 AM" format
        return dateFormatter.date(from: time)
    }
}
