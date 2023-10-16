//
//  SettingTableViewCell.swift
//  Takenoko
//
//  Created by Ngân Phan on 16/10/2023.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
}
