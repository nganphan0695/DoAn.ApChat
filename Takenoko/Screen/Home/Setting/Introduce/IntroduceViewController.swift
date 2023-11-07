//
//  IntroduceViewController.swift
//  Takenoko
//
//  Created by Ngân Phan on 30/10/2023.
//

import UIKit

class IntroduceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @IBAction func handleBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
