//
//  InAppSettingsController.swift
//  KS Mechanic
//
//  Created by Brian Alvarez on 8/25/18.
//  Copyright © 2018 Kryptic Studios. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class InAppSettingsController: UITableViewController {
    
    let cellId = "cellId"
    
    @IBOutlet var settingsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    @IBAction func handleLogout(_ sender:Any) {
        try! Auth.auth().signOut()
        self.dismiss(animated: false, completion: nil)
    }
    
    override func tableView(_ settingsTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTable.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        cell.textLabel?.text = "Something"
        
        return cell
    }
}
