//
//  SectionHeaderView.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 14/11/2024.
//

import UIKit

class SectionHeaderView: UITableViewHeaderFooterView {

    static let reuseIdentifier = "SectionHeaderView"
        
        let titleLabel = UILabel()
        let arrowLabel = UILabel()

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
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            arrowLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(titleLabel)
            contentView.addSubview(arrowLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
                titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                
                arrowLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
                arrowLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
            
            arrowLabel.text = ">"
            arrowLabel.textColor = .black
            titleLabel.textColor = .black
            arrowLabel.font = .boldSystemFont(ofSize: 12)
            titleLabel.font = .boldSystemFont(ofSize: 12)
        }
        
        func toggleExpanded(isExpanded: Bool) {
            arrowLabel.text = isExpanded ? "v" : ">"
        }
    
}
