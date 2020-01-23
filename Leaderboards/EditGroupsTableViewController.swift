//
//  EditGroupsTableViewController.swift
//  Leaderboards
//
//  Created by Tinkertanker on 17/1/20.
//  Copyright © 2020 SST Inc. All rights reserved.
//

import UIKit

class EditGroupsTableViewController: UITableViewController {
    var identifier: String = "newRoom"
    var names: [String] = []
    var groups = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(exitPressed))
        self.navigationItem.titleView?.tintColor = #colorLiteral(red: 0.262745098, green: 0.3411764706, blue: 0.6784313725, alpha: 1)
        self.navigationItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.4117647059, green: 0.5294117647, blue: 0.7882352941, alpha: 1)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return names.count
    }

    @IBAction func addGroup(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Group", message: "What is this group named?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            let textField = alert.textFields?[0]
            guard let text = textField?.text else {
                let errAlert = UIAlertController(title: "Invalid Name", message: "You must provide a name!", preferredStyle: .alert)
                errAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                return
            }
            self.names.append(text)
            self.tableView.reloadData()
        }))
        self.present(alert, animated: true)
    }
    func reloadRows(sectionIndex: Int = 0) {
        var reloadPaths = [IndexPath]()
        (0..<tableView.numberOfRows(inSection: sectionIndex)).indices.forEach { rowIndex in
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            reloadPaths.append(indexPath)
        }
        tableView.reloadRows(at: reloadPaths, with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        cell.textLabel?.text = names[indexPath.row]
        // Configure the cell...

        return cell
    }
    
    @objc func exitPressed() {
        if identifier == "newRoom" {
            performSegue(withIdentifier: "backToNewRoom", sender: self)
        } else {
            performSegue(withIdentifier: "backToEditRoom", sender: self)
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            names.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
        }
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var groupText = ""
        for (index,key) in names.enumerated() {
            if index == names.count - 1 {
                groupText += "\(key)"
            } else {
                groupText += "\(key), "
            }
        }
        print(groupText)
        if segue.identifier == "backToNewRoom" {
            let dest = segue.destination as! NewRoomTableViewController
            dest.groupText = groupText
        } else {
            let dest = segue.destination as! EditRoomTableViewController
            dest.groupText = groupText
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//        if segue.identifier == "editRoomEditGroups" {
//            let dest = segue.destination as! EditRoomTableViewController
//            dest.groupNamesTextField.text = groups
//        } else {
//            let dest = segue.destination as! NewRoomTableViewController
//            dest.groupNamesTextField.text = groups
//        }
    }

}
