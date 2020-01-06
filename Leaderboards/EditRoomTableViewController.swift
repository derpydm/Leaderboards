//
//  EditRoomTableViewController.swift
//  Leaderboards
//
//  Created by Sean Wong on 2/1/20.
//  Copyright © 2020 Tinkertanker. All rights reserved.
//

import UIKit
import FirebaseDatabase

// This class is an edited bersion of NewRoomTableViewController
// It grabs data from the room it is given
class EditRoomTableViewController: UITableViewController {
    var ref: DatabaseReference!
    var room: Room!
    var groupNames: [String]!
    var scores: [Int]!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var maxScoreTextField: UITextField!
    @IBOutlet weak var groupNamesTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        codeLabel.text = room.code
        nameTextField.text = room.name
        maxScoreTextField.text = String(room.maxScore)
        var groupText = ""
        let keys = groupNames!
        for (index,key) in keys.enumerated() {
            if index == keys.count - 1 {
                groupText += "\(key)"
            } else {
                groupText += "\(key), "
            }
        }
        groupNamesTextField.attributedText = coloredCommas(with: groupText)
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
        guard let intMaxScore = Int(maxScore) else {
            let alert = UIAlertController(title: "Invalid Max Score", message: "Max score must be an integer!", preferredStyle: .alert)
                       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                       self.present(alert, animated: true)
                       return
        }
        
        // Grab the new group names
        // For each group name, check if it has a value not equal to zero - in which case, set the value
        
        let groupNamesArray = groupNames.components(separatedBy: ", ")
        for (index,score) in scores.enumerated() {
            if score > intMaxScore {
                scores[index] = intMaxScore
            }
        }
        let oldGroups = Dictionary(uniqueKeysWithValues: zip(self.groupNames, scores))
        var groups: [String:Int] = [:]
        for name in groupNamesArray {
            print("\(name): \(oldGroups[name])")
            if ((oldGroups[name] ?? 0) == 0) {
                groups.updateValue(0, forKey: name)
            } else {
                let origValue = oldGroups[name]!
                print("\(origValue) \(name)")
                groups.updateValue(origValue, forKey: name)
            }
            
        }
        
        // Create room, update Firebase values
        let newRoom = Room(name: name, code: code, groups: groups, maxScore: intMaxScore)
        self.ref.child("rooms").child(code).updateChildValues(["name": newRoom.name, "code": newRoom.code, "groups": newRoom.groups, "maxScore": intMaxScore])
        
        // Go back to the room
        dismiss(animated: true, completion: nil)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
