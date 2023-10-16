//
//  ProfileTableViewCell.swift
//  Takenoko
//
//  Created by Ngân Phan on 15/10/2023.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.autocorrectionType = .no
        
        setUpView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

      
    }
    
    func setUpView(){
        errorView.isHidden = true
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.black.cgColor
    }
    
    func error(textError: String){
        errorView.isHidden = false
        
        textField.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.97, alpha: 1.00)
        textField.layer.borderColor = UIColor(red: 0.76, green: 0.00, blue: 0.32, alpha: 1.00).cgColor
        errorLabel.text = textError
    }
    
}
