//
//  PageHeaderView.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 14/11/2024.
//

import UIKit

class PageHeaderView: UITableViewHeaderFooterView {

    static let reuseIdentifier = "PageHeaderView"
    
    let monthLabel = UILabel()
    let yearLabel = UILabel()
     let dayLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        // Add a background view if not already added in storyboard
               if backgroundView == nil {
                   backgroundView = UIView()
               }
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
       yearLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(monthLabel)
        contentView.addSubview(yearLabel)
        contentView.addSubview(dayLabel)
        
        NSLayoutConstraint.activate([
            //for dayLabel
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            //for monthLabel
            monthLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            monthLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            
            //for yearLabel
            yearLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            yearLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            
        ])
        
        dayLabel.textColor = .black
        monthLabel.textColor = .black
        yearLabel.textColor = .black
        dayLabel.font = .boldSystemFont(ofSize: 14)
        monthLabel.font = .boldSystemFont(ofSize: 14)
        yearLabel.font = .boldSystemFont(ofSize: 14)
    }


}
