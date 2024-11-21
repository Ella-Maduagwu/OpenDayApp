//
//  BuildingCollectionViewCell.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 19/11/2024.
//

import UIKit

class BuildingCollectionViewCell: UICollectionViewCell {
    static let identifier = "BuildingCollectionViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView() // Set up the initial view for the cell
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView() // Set up the initial view for the cell when initialized from storyboard
    }
    
    /// Sets up the view properties and layout constraints for the cell.
    private func setupView() {
        contentView.addSubview(nameLabel)
        contentView.backgroundColor = .lightGray
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    /// Configures the cell with the provided building name.
    func configure(with buildingName: String) {
        nameLabel.text = buildingName
        nameLabel.accessibilityLabel = "Building: \(buildingName)" // Set an accessibility label for the building name
    }
}
