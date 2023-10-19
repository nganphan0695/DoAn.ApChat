//
//  ChatViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 16/10/2023.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var messageTf: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var avatarImageView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupView()
    }
    
    func setupView(){
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor.lightGray.cgColor
        avatarImageView.clipsToBounds = true
        
        messageTf.layer.cornerRadius = 20
    }

    @IBAction func handleBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func optionButton(_ sender: Any) {
        showAlert(title: "Xin lỗi", message: "Tính năng này sẽ được phát triển sau")
    }
}
