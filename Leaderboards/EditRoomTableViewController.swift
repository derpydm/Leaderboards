//
//  EditRoomTableViewController.swift
//  Leaderboards
//
//  Created by Sean Wong on 2/1/20.
//  Copyright © 2020 Tinkertanker. All rights reserved.
//

import UIKit
import FirebaseDatabase
import DictionaryCoding
// This class is an edited bersion of NewRoomTableViewController
// It grabs data from the room it is given
class EditRoomTableViewController: UITableViewController {
    var ref: DatabaseReference!
    var roomRef: DatabaseReference!
    var room: Room!
    var groupText: String = ""
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var maxScoreTextField: UITextField!
    @IBOutlet weak var groupNamesTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = true
        ref = Database.database().reference()
        roomRef = ref.child("rooms").child(room.code)
        codeLabel.text = room.code
        nameTextField.text = room.name
        maxScoreTextField.text = String(room.maxScore)
        
        for (index,group) in room.groups.enumerated() {
            if index == room.groups.count - 1 {
                groupText += "\(group.name)"
            } else {
                groupText += "\(group.name), "
            }
        }
        groupNamesTextField.attributedText = coloredCommas(with: groupText)
        
    }
    
    func reloadGroupText() {
        groupNamesTextField.attributedText = coloredCommas(with: groupText)
        // Grab the new group names
        // For each group name, check if it has a value not equal to zero - in which case, set the value
        var updatedGroups: [Group] = []
        let newGroups = groupText.components(separatedBy: ", ")
        for name in newGroups {
            if let index = room.groups.firstIndex(where: { (grp) -> Bool in grp.name == name }) {
                updatedGroups.append(room.groups[index])
            } else {
                updatedGroups.append(Group(name, 0))
            }
        }
        self.room.groups = updatedGroups
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row != 2 {
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "editRoomEditGroups", sender: self)
        }
    }
    
    @IBAction func backToEdit(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        reloadGroupText()
    }
    @IBAction func updateNewRoom(_ sender: Any) {
        
        // If name or groupnames are missing, then warn user and do not proceed
        let name = nameTextField.text ?? ""
        if name == "" {
            let alert = UIAlertController(title: "Missing Name", message: "Please enter in a name!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let groupNames = groupNamesTextField.text ?? ""
        
        if groupNames == "" {
            let alert = UIAlertController(title: "Missing Group Names", message: "Please enter at least one group name!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let code = codeLabel.text!
        
        var maxScore = maxScoreTextField.text ?? "1000"
        if maxScore == "" {
            maxScore = "1000"
        }
        guard Int(maxScore) != nil else {
            let alert = UIAlertController(title: "Invalid Max Score", message: "Max score must be an integer!", preferredStyle: .alert)
                       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                       self.present(alert, animated: true)
                       return
        }
        
        // Grab the new group names
        // For each group name, check if it has a value not equal to zero - in which case, set the value
        var updatedGroups: [Group] = []
        let newGroups = groupText.components(separatedBy: ", ")
        for name in newGroups {
            if let index = room.groups.firstIndex(where: { (grp) -> Bool in grp.name == name }) {
                updatedGroups.append(room.groups[index])
            } else {
                updatedGroups.append(Group(name, 0))
            }
        }
        var encodedGroups: [[String:Any]] = []
        let dictEncoder = DictionaryEncoder()
        for group in updatedGroups {
            encodedGroups.append(try! dictEncoder.encode(group))
        }
        roomRef.setValue(["name": name, "code": code, "maxScore": maxScore, "groups": encodedGroups])
        // Go back to the room
        performSegue(withIdentifier: "backToRoom", sender: self)
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    

    @IBAction func groupNameTextFieldDidChange(_ sender: UITextField) {
        sender.attributedText = coloredCommas(with: sender.text ?? "")
    }
    

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        if segue.identifier == "editRoomEditGroups" {
            let nav = segue.destination as! UINavigationController
            let dest = nav.viewControllers[0] as! EditGroupsTableViewController
            dest.identifier = "editGroups"
            dest.groups = room.groups
        }
     
        
    }

    
}
