//
//  EventTableViewCell.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 13/11/2024.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    let arrowLabel = UILabel()
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        eventNameLabel.numberOfLines = 0
        timeLabel.numberOfLines = 0
        locationLabel.numberOfLines = 0

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

