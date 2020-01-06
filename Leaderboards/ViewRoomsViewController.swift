//
//  RoomViewController.swift
//  Leaderboards
//
//  Created by Sean Wong on 3/11/19.
//  Copyright © 2019 Tinkertanker All rights reserved.
//

import UIKit
import FirebaseDatabase
class ViewRoomsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    // Recieve room from another viewcontroller
    var room: Room!
    var shouldAnimate = true
    var groupScores: [Int]! = []
    var groupNames: [String]! = []
    var ref: DatabaseReference!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise UI
        setUpTableView()
        setUpGroups()
        setUpTitleLabel()
        
       // Set up Firebase listener
        
        self.ref = Database.database().reference()
        ref.child("rooms").child(room.code).observe(.childChanged) { (snapshot) in
            print(snapshot)
            if snapshot.exists() {
                // Inform tableView that it is ok to animate now
                self.shouldAnimate = true
                // Check which value is changed
                let value = snapshot.value!
                let code = value as? String ?? self.room.code
                let name = value as? String ?? self.room.name
                let groups = value as? [String:Int] ?? self.room.groups
                let maxScore = value as? Int ?? self.room.maxScore
                // Update the room and reload everything
                let newRoom = Room(name: name, code: code, groups: groups, maxScore: maxScore)
                print(groups)
                self.room = newRoom
                self.setUpGroups()
                self.setUpTitleLabel()
                self.tableView.reloadData()
            }
        }
        
        // Debug
        print("Room \(room.code) with name \(room.name) and groups \(groupNames)")
        
    }
    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setUpTitleLabel() {
        titleLabel.text = room.name
    }
    
    func setUpGroups() {
        // Sort the values and match them with the names
        
        let groups = room.groups
        let sortedValues = groups.sorted { $0.1 > $1.1 }
        groupScores.removeAll()
        groupNames.removeAll()
        for tup in sortedValues {
            groupScores.append(tup.value)
            groupNames.append(tup.key)
        }
        return
        
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "editRoom" {
            let dest = segue.destination as! EditRoomTableViewController
            dest.room = room
            dest.groupNames = groupNames
            dest.scores = groupScores
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupScores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "team", for: indexPath) as! TeamLeaderboardsTableViewCell
        
        cell.selectionStyle = .none
        // Set up labels
        cell.groupRankLabel.text = String(indexPath.row + 1)
        
        cell.scoreLabel.text = String(groupScores[indexPath.row])
        
        // Update progress indicator
        let maxWidth = UIScreen.main.bounds.width
        let segmentWidth = maxWidth / CGFloat(room.maxScore)
        cell.editProgressIndicatorWidthContraint.constant = segmentWidth * CGFloat(groupScores[indexPath.row])
        
        // Set up group name
        cell.groupNameLabel.text = groupNames[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // We animate the cells here.
        // We only want the animation to play at first and when the view updates.
        if shouldAnimate {
            let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 1.0, delayFactor: 0.2)
            let animator = Animator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
        }
        if shouldAnimate && tableView.isLastVisibleCell(at: indexPath) {
            shouldAnimate = false
        }
        
    }
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var sign = 1
        let signAlert = UIAlertController(title: "Changing Points", message: "Are you adding or subtracting points?", preferredStyle: .actionSheet)
        
        
        
        // We establish the points alert now so we can display it after the signAlert
        // Title and message will be added later
        let pointsAlert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        pointsAlert.addTextField { (textField) in
            textField.placeholder = "Points"
        }
        pointsAlert.addAction(UIAlertAction(title: "Update Points", style: .default, handler: { (action) in
            pointsAlert.dismiss(animated: true) {
                let textField = pointsAlert.textFields![0]
                let newScore = textField.text ?? "0"
                
                    
                if var newIntScore = Int(newScore) {
                    // Apply sign then add the original score
                    newIntScore = newIntScore * sign
                    newIntScore += self.groupScores[indexPath.row]
                    // Check if it exceeds the max score points
                    if newIntScore > self.room.maxScore {
                        
                        let errAlert = UIAlertController(title: "Error", message: "The value is too large! Scores must be below \(self.room.maxScore).", preferredStyle: .alert)
                        errAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                        self.present(errAlert, animated: true)
                    } else {
                        // Update score and then save it in Firebase
                        self.groupScores[indexPath.row] = newIntScore
                        let newDict = Dictionary(uniqueKeysWithValues: zip(self.groupNames, self.groupScores))
                        self.ref.child("rooms").child(self.room.code).child("groups").setValue(newDict)
                    }
                    
                } else {
                    let errAlert = UIAlertController(title: "Error", message: "The value must be an integer!", preferredStyle: .alert)
                    errAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errAlert, animated: true)
                }
                
                
            }
        }))
        
        // If they want to add sign doesn't change
        
        signAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            
            pointsAlert.title = "Add Points"
            pointsAlert.message = "How many points do you want to add?"
            self.present(pointsAlert, animated: true)
            
        }))
        
        // If they want to subtract the sign changes along with the message
        
        signAlert.addAction(UIAlertAction(title: "Subtract", style: .default, handler: { (_) in
            
            sign = -1
            pointsAlert.title = "Subtract Points"
            pointsAlert.message = "How many points do you want to subtract?"
            self.present(pointsAlert, animated: true)
            
        }))
        self.present(signAlert, animated: true)
    }
}
