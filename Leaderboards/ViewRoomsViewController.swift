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
    
    @IBOutlet weak var subTitleTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    // Recieve room from another viewcontroller
    var room: Room!
    var shouldAnimate = false
    var groupScores: [Int]! = []
    var groupNames: [String]! = []
    var ref: DatabaseReference!
    var roomRef: DatabaseReference!
    var doNotAnimate: [IndexPath:Bool] = [:]
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise UI
        setUpTableView()
        setUpGroups()
        setUpTitleLabel()
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        tableView.reloadData()
        
        // Set up Firebase listener
        
        self.ref = Database.database().reference()
        self.roomRef = ref.child("rooms").child(room.code)
        roomRef.observe(.childChanged) { (snapshot) in
            print(snapshot)
            if snapshot.exists() {
                // Inform tableView that it is ok to animate now
                self.shouldAnimate = true
                // Check which value is changed
                let value = snapshot.value!
                // The code doesn't ever change for a single room so we don't touch it
                let code = self.room.code
                let name = value as? String ?? self.room.name
                let groups = value as? [String:Int] ?? self.room.groups
                let maxScore = value as? Int ?? self.room.maxScore
                // Update the room and reload everything
                let newRoom = Room(name: name, code: code, groups: groups, maxScore: maxScore)
                print(groups)
                self.room = newRoom
                self.setUpGroups()
                self.setUpTitleLabel()
                self.doNotAnimate.removeAll()
                self.tableView.reloadData()
            }
        }
        
            
        
        // Debug
        print("Room \(room.code) with name \(room.name) and groups \(groupNames)")
        
    }
    deinit {
       NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func rotated() {
        // Re-dequeue cells and layout everything again
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.reloadData()
    }
    
    // Unused function
    func getTableViewCellIndexPaths(sectionIndex: Int = 0) {
        var reloadPaths = [IndexPath]()
        (0..<tableView.numberOfRows(inSection: sectionIndex)).indices.forEach { rowIndex in
            let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
            reloadPaths.append(indexPath)
        }
        tableView.reloadRows(at: reloadPaths, with: .automatic)
    }
    
    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
        
    }
    
    func setUpTitleLabel() {
        self.navigationItem.title = room.name
        self.navigationItem.backBarButtonItem?.title = room.name
        subTitleTextLabel.text = "Room code: \(room.code)."
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)
    }
    
    @IBAction func unwindToRoom(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
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
        performSegue(withIdentifier: "unwindToHomeFromRoom", sender: self)
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
        } else if segue.identifier == "unwindToHomeFromRoom" {
            let dest = segue.destination as! HomeTableViewController
            dest.roomGroups.removeAll()
            dest.roomNames.removeAll()
            dest.roomCodes.removeAll()
            dest.collectionView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupScores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "team", for: indexPath) as! TeamLeaderboardsTableViewCell
        cell.contentView.layoutIfNeeded()
        cell.selectionStyle = .none
        // Set up labels
        cell.groupRankLabel.text = String(indexPath.row + 1)
        
        cell.scoreLabel.text = String(groupScores[indexPath.row])
        
        // Update progress indicator
        let maxWidth = cell.coloredBackground.frame.width
        cell.editProgressIndicatorWidthContraint.constant = maxWidth * CGFloat(groupScores[indexPath.row])/CGFloat(room.maxScore)
        
        // Set up group name
        cell.groupNameLabel.text = groupNames[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // We animate the cells here.
        // We only want the animation to play at first and when the view updates.
        if let _ = doNotAnimate[indexPath] {
            return
        }
        
        
        doNotAnimate[indexPath] = true
        let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 1.0, delayFactor: 0.2)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
        
        
        
    }
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var sign = 1
        let signAlert = UIAlertController(title: "Changing Points", message: "Are you adding or subtracting points?", preferredStyle: .actionSheet)
        signAlert.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        // We establish the points alert now so we can display it after the signAlert
        // Title and message will be added later
        let pointsAlert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        pointsAlert.addTextField { (textField) in
            textField.placeholder = "Points"
            textField.keyboardType = .numberPad
        }
        pointsAlert.addAction(UIAlertAction(title: "Update Points", style: .default, handler: { (action) in
            pointsAlert.dismiss(animated: true) {
                
                let textField = pointsAlert.textFields![0]
                let newScore = textField.text ?? "0"
                
                
                if var newIntScore = Int(newScore) {
                    // Apply sign then add the original score
                    let change = newIntScore
                    if newIntScore < 0 {
                        let errAlert = UIAlertController(title: "Error", message: "You entered in a negative value! Enter in a value above 0.", preferredStyle: .alert)
                        errAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errAlert, animated: true)
                    }
                    newIntScore = newIntScore * sign
                    newIntScore += self.groupScores[indexPath.row]
                    // Check if it exceeds the max score points
                    if newIntScore > self.room.maxScore {
                        
                        let errAlert = UIAlertController(title: "Error", message: "The value is too large! Scores must be below \(self.room.maxScore).", preferredStyle: .alert)
                        errAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errAlert, animated: true)
                    } else {
                        // Save the reason in the log
                        
                        var reason = ""
                        let reasonAlert = UIAlertController(title: "Reason for Update", message: "Provide a reason for this update", preferredStyle: .alert)
                        reasonAlert.addTextField { (textField) in
                            textField.placeholder = "Reason"
                        }
                        reasonAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                            let textField = reasonAlert.textFields![0]
                            reason = textField.text ?? "no reason provided"
                            let formatter = DateFormatter()
                            formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
                            let date = formatter.string(from: Date())
                            let groupName = self.groupNames[indexPath.row]
                            // Get the log and update it - we only need to display in another view controller so we don't have to update values in this VC
                            let newLog = ["change": String(change), "date": date, "reason": reason, "group": groupName]
                            self.roomRef.child("log").observeSingleEvent(of: .value) { (snapshot) in
                                if snapshot.exists() {
                                    let value = snapshot.value as? NSArray
                                    self.roomRef.child("log").child(String(value!.count)).setValue(newLog)
                                } else {
                                    self.roomRef.child("log").child("0").setValue(newLog)
                                }
                            }
                            // Update score and then save it in Firebase
                            #warning("Implement a LCS (longest common subsequence) algo and then use it instead")
                            self.groupScores[indexPath.row] = newIntScore
                            let newDict = Dictionary(uniqueKeysWithValues: zip(self.groupNames, self.groupScores))
                            self.roomRef.child("groups").setValue(newDict)

                        }))
                        self.present(reasonAlert, animated: true)
                    
                        
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
        
        // Add cancel buttons
        
        signAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        pointsAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(signAlert,animated: true)
    }
}
