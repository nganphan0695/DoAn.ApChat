//
//  ContactViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 16/10/2023.
//

import UIKit

class ContactViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addFriendView: UIView!
    @IBOutlet weak var plusView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView(){
        addFriendView.layer.cornerRadius = addFriendView.frame.height / 2
        addFriendView.layer.borderWidth = 1
        addFriendView.layer.borderColor = UIColor.white.cgColor
        addFriendView.clipsToBounds = true
        
        searchBar.layer.cornerRadius = 25
        searchBar.layer.masksToBounds = true
        searchBar.clipsToBounds = true
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.clear
        
        plusView.layer.cornerRadius = plusView.frame.height / 2
        plusView.clipsToBounds = true
    }
    
    @IBAction func handleAddFriend(_ sender: Any) {
    }
    


}
