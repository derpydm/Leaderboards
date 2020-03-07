//
//  NewRoomTableViewController.swift
//  Leaderboards
//
//  Created by Sean Wong on 2/11/19.
//  Copyright © 2019 Tinkertanker. All rights reserved.
//

import UIKit
import FirebaseDatabase
class NewRoomTableViewController: UITableViewController {
    var ref: DatabaseReference!
    var roomRef: DatabaseReference!
    var groupText: String!
    var groupNames: String!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var maxScoreTextField: UITextField!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var groupNamesTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        tableView.allowsSelection = true
        let code = generateCode()
        codeLabel.text = String(code)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func reloadGroupText() {
        groupNamesTextField.attributedText = coloredCommas(with: groupText)
    }
    func generateCode() -> Int {
        var isDupe = false
        // Generate code
        // If it is found then we generate a new one
        let code = Int.random(in: 100000...999999)
        self.ref.child("groups").child("\(code)").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if snapshot.exists() {
                isDupe = true
            }
        }
        if isDupe {
            return self.generateCode()
        }
        return code
    }
    @IBAction func backToNewRoom(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        reloadGroupText()
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
            performSegue(withIdentifier: "newRoomEditGroups", sender: self)
        }
    }
    @IBAction func createNewRoom(_ sender: Any) {
        
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
        let code = codeLabel.text!
        
        
        let groupNamesArray = groupNames.components(separatedBy: ", ")
        
        var groups: [[String:Any]] = []
        for name in groupNamesArray {
            groups.append(["name": name, "score": 0])
        }
        self.roomRef = self.ref.child("rooms").child(code)
        self.roomRef.child("name").setValue(name)
        self.roomRef.child("code").setValue(code)
        self.roomRef.child("groups").setValue(groups)
        self.roomRef.child("maxScore").setValue(intMaxScore)
        
        
        performSegue(withIdentifier: "unwindFromNewToHome", sender: self)
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    @IBAction func groupNamesTextChanged(_ sender: UITextField) {
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
