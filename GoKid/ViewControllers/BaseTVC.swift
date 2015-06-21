//
//  BaseTVC.swift
//  
//
//  Created by Bingwen Fu on 6/20/15.
//
//

import UIKit

class BaseTVC: UITableViewController {
    
    var dataManager = DataManager.sharedInstance
    var userManager = UserManager.sharedInstance
    var colorManager = ColorManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
