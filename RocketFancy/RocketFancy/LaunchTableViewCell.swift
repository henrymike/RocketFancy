//
//  LaunchTableViewCell.swift
//  RocketFancy
//
//  Created by Mike Henry on 10/18/18.
//  Copyright © 2018 Mike Henry. All rights reserved.
//

import UIKit

class LaunchTableViewCell: UITableViewCell {

    //MARK: - Properties
    @IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var missionImageView: UIImageView!
    
    
    //MARK: - Display Methods
    func configureCellForLaunch(_ launch: Launch, launchDate: String) {
        missionLabel.text = launch.missionName
        locationLabel.text = launch.launchSite
        dateLabel.text = launchDate
        if let imageMissionPatchUrl = launch.imageMissionPatchUrl {
            if let imageUrl = URL(string: imageMissionPatchUrl) {
                missionImageView.af_setImage(withURL: imageUrl)
            }
        }
    }
}
