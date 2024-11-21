//
//  TimetableViewClass.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 13/11/2024.
//

import UIKit

class TimetableViewClass: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var dayLabel : UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    var events: [Event] = []
    var sections: [EventSection] = []// array of sections
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDate()
        configureTableView()
        loadEventData()
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseIdentifier)
        setupHeader()

        
    }
    
    /// Sets up the header for the page with the title.
       private func setupHeader() {
           let header = headerView
           header?.backgroundColor = .systemYellow
           let headerLabel = UILabel()
           headerLabel.text = "Timetable"
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
    func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView() // Removes extra separators
            tableView.sectionHeaderHeight = UITableView.automaticDimension
            tableView.estimatedSectionHeaderHeight = 300
        tableView.alwaysBounceVertical = true
        tableView.layer.cornerRadius = 15
        tableView.layer.masksToBounds = true
        tableView.estimatedRowHeight = 100 // Standard row height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isScrollEnabled = true

    }
    func setupDate() {
     
        let currentDate = Date()
        dayLabel.text = currentDate.format("dd")
        monthLabel.text = currentDate.format("MMMM")
        yearLabel.text = currentDate.format("yyyy")
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section] .isExpanded ? sections[section].events.count :0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventTableViewCell else {
               return UITableViewCell() // Return an empty cell if the cast fails
           }
        let event = sections[indexPath.section].events[indexPath.row]
           cell.timeLabel.text = event.time
           cell.eventNameLabel.text = event.name
           cell.locationLabel.text = event.location
           return cell
       }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.reuseIdentifier) as? SectionHeaderView else { return nil }
        header.titleLabel.text = sections[section].title
        header.backgroundView? .backgroundColor = .systemYellow
        header.backgroundView? . layer.cornerRadius = 5
        header.toggleExpanded(isExpanded: sections[section].isExpanded)
        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSection(_:))))
        header.tag = section
        return header
    }
    
    
    @objc func toggleSection(_ sender: UITapGestureRecognizer) {
        guard let sectionIndex = sender.view?.tag else { return }
        sections[sectionIndex].isExpanded.toggle()
        tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
    
    func loadEventData(){
        
        let events1 = EventSection(title: " Essential Talks", events: [
            Event(name: " Welcome to ARU (30mins) ", time: " 10:00am & 10:45am", location: " LAB 026"),
            Event(name: " Accomodation (20mins) ", time: " 10:10am & 12:15pm", location: " LAB 003"),
            Event(name: " Student Finance (30mins) ", time: " 10:45am & 12:45pm", location: " LAB 003"),
            Event(name: " Disability & Dyslexia Support", time: " 11:30am & 1:00pm", location: " LAB 026"),
            Event(name: " Personal Statement(30mins) ", time: " 11:30am & 1:30pm", location: " LAB 003"),
            Event(name: " Student Sport at ARU ", time: " 1:00pm", location: " Sci 303(Science Center third floor)")
        
        ])
        let events2 = EventSection(title: " Info Hub ", events: [
            Event(name: " Admissions", time: " 10:00am - 2:00pm", location: " Science Center foyer"),
            Event(name: " Accomodation", time: " 10:00am - 2:00pm", location: " Science Center foyer"),
            Event(name: " Global Opportunities", time: " 10:00am - 2:00pm", location: " Science Center foyer"),
            Event(name: " Personal statement advice", time: " 10:00am - 2:00pm", location: " Science Center foyer"),
            Event(name: " Sport at ARU", time: " 10:00am - 2:00pm", location: " Science Center foyer")
        ])
        
        let events3 = EventSection(title: " Essential Tours", events: [
            Event(name: " Accomodation Tours", time: " 10:00am - 2:00pm", location: " Science Center foyer"),
            Event(name: " Campus Tours", time: " 10:00am - 2:00pm", location: " iCentre"),
            Event(name: " Library Tours", time: " 10:00am - 2:00pm", location: " Library foyer"),
            Event(name: " Sport Facilities Tours", time: " 10:00am - 2:00pm", location: " Science Center foyer")
        
        ])
        
        let events4 = EventSection(title: " Apprenticeships and Foundation Courses", events: [
            Event(name: " ARU college drop-in", time: " 10:00am - 2:00pm", location: " Science Center foyer"),
            Event(name: " Degrees at work & policing apprenticeships drop-in", time: " 10:00am - 2:00pm ", location: " LAB 211"),
            Event(name: " Policing Apprenticeships talk (30mins)", time: " 10:30am", location: " LAB 211"),
            Event(name: " Degree Apprenticeships talk", time: " 12:00pm", location: " LAB 211"),
            Event(name: " ARU college foundation courses talk", time: " 12:30pm", location: " LAB 026")
        
        ])
        
        let events5 = EventSection(title: " Open Sessions", events: [
            Event(name: " Humanities and social sciences taster lecture ", time: " 11:30am ", location: " LAB 207"),
            Event(name: " English and Literature taster lecture", time: " 12:30pm ", location: " LAB 207"),
            Event(name: " Criminology taster lecture", time: " 1:15pm", location: " LAB 207")
            
        ])
        
        let events6 = EventSection(title: "Wellbeing Hub", events: [
            Event(name: " Counselling and wellbeing ", time: " 10:00am - 2:00pm", location: " Student Union"),
            Event(name: " Employability", time: " 10:00am - 2:00pm", location: " Student Union"),
            Event(name: " Money Advice", time: " 10:00am - 2:00pm", location: " Student Union"),
            Event(name: " Students' Union", time: " 10:00am - 2:00pm", location: " Student Union")
            
        ])
        sections.append(contentsOf: [events1, events2, events3, events4, events5, events6])
        tableView.reloadData() // Reload data to display the sections
    }
    
    
    //func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // let event = events[indexPath.row]
        // Trigger geofencing or navigation to the event location
   // }

}

