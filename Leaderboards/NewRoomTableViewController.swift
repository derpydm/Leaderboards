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
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var maxScoreTextField: UITextField!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var groupNamesTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        let code = generateCode()
        codeLabel.text = String(code)
        // Test of reading stuff from Firebase
        
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        
        var groups: [String:Int] = [:]
        for name in groupNamesArray {
            groups.updateValue(0, forKey: name)
        }
        
        // Create room, add it to Firebase
        let newRoom = Room(name: name, code: code, groups: groups, maxScore: intMaxScore)
        self.ref.child("rooms").child(code).child("name").setValue(newRoom.name)
        self.ref.child("rooms").child(code).child("code").setValue(newRoom.code)
        self.ref.child("rooms").child(code).child("groups").setValue(newRoom.groups)
        self.ref.child("rooms").child(code).child("maxScore").setValue(newRoom.maxScore)
        
        
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
