//
//  MessageTableViewCell.swift
//  Takenoko
//
//  Created by Ngân Phan on 14/10/2023.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var avatarView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
     
    }
    
    func setupView(){
        avatarView.layer.cornerRadius = avatarView.frame.height / 2
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.lightGray.cgColor
        avatarView.clipsToBounds = true
        
        notificationView.layer.cornerRadius = notificationView.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

      
    }
    
}
