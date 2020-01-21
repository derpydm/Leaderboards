//
//  TeamLeaderboardsTableViewCell.swift
//  Leaderboards
//
//  Created by Sean Wong on 3/11/19.
//  Copyright © 2019 Tinkertanker. All rights reserved.
//

import UIKit

class TeamLeaderboardsTableViewCell: UITableViewCell {

    // Progress indicators
    @IBOutlet weak var coloredBackground: UIView!
    @IBOutlet weak var progressIndicator: UIView!
    @IBOutlet weak var editProgressIndicatorWidthContraint: NSLayoutConstraint!
    
    // Actually useful
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupRankLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        coloredBackground.layer.cornerRadius = 12
        coloredBackground.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
