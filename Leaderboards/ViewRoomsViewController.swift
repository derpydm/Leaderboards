//
//  ViewRoomsViewController.swift
//  Leaderboards
//
//  Created by Sean Wong on 3/11/19.
//  Copyright © 2019 Tinkertanker All rights reserved.
//

import UIKit
import FirebaseDatabase
import DictionaryCoding
import DeepDiff
class ViewRoomsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var subTitleTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    // Recieve room from another viewcontroller
    var room: Room!
    var shouldAnimate = false
    var ref: DatabaseReference!
    var roomRef: DatabaseReference!
    var doNotAnimate: [IndexPath:Bool] = [:]
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        self.roomRef = ref.child("rooms").child(room.code)
        
        
        // Initialise UI
        setUpTableView()
        setUpGroups(newGroups: room.groups)
        setUpTitleLabel()
        // Get room updates
        roomRef.observe(.childChanged) { (snapshot) in
            if snapshot.exists() {
                if (snapshot.value as? [[String:String]]) != nil {
                    return
                }
                if let newName = snapshot.value as? String {
                    self.room.name = newName
                    self.setUpTitleLabel()
                }
                if let newMaxScore = snapshot.value as? Int {
                    self.room.maxScore = newMaxScore
                }
                
                if let newGroups = snapshot.value as? [[String:Any]] {
                    var groups: [Group] = []
                    let dictDecoder = DictionaryDecoder()
                    for groupData in newGroups {
                        let group = try! dictDecoder.decode(Group.self, from: groupData)
                        groups.append(group)
                    }
                    self.doNotAnimate.removeAll()
                    self.setUpGroups(newGroups: groups)
                    return
                }
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { (_) in
            self.tableView.reloadData()
        }
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
    
    func setUpGroups(newGroups: [Group]) {
        // Sort the values and match them with the names
        let oldGroups = room.groups
        let sortedGroups = newGroups.sorted { (a, b) -> Bool in
            a.score > b.score
        }
        var changes = diff(old: oldGroups, new: sortedGroups)
        
        // REMOVE ALL REPLACE CHANGES
        // I have no idea why this happens but random replaces happen which are terrible for us so we remove them
        changes.removeAll { (chg) -> Bool in
            chg.replace != nil
        }
        tableView.reload(changes: changes, updateData: {
            room.groups = sortedGroups
        }) { _ in
            self.tableView.reloadData()
        }
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
            
        } else if segue.identifier == "unwindToHomeFromRoom" {
            let dest = segue.destination as! HomeTableViewController
            dest.rooms.removeAll()
            dest.collectionView.reloadData()
        }
    }
    	
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return room.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "team", for: indexPath) as! TeamLeaderboardsTableViewCell
        cell.contentView.layoutIfNeeded()
        cell.selectionStyle = .none
        // Set up labels
        cell.groupRankLabel.text = String(indexPath.row + 1)
        
        cell.scoreLabel.text = String(room.groups[indexPath.row].score)
        
        // Update progress indicator
        let maxWidth = cell.coloredBackground.frame.width
        let greenComponent = #colorLiteral(red: 0.4666666667, green: 0.8666666667, blue: 0.4666666667, alpha: 1).withAlphaComponent(CGFloat(room.groups[indexPath.row].score) / CGFloat(room.maxScore))
        let yellowComponent = #colorLiteral(red: 0.9921568627, green: 0.9921568627, blue: 0.5882352941, alpha: 1).withAlphaComponent((CGFloat(room.maxScore - room.groups[indexPath.row].score) / CGFloat(room.maxScore)))
        cell.progressIndicator.backgroundColor = greenComponent + yellowComponent
        cell.editProgressIndicatorWidthContraint.constant = maxWidth * CGFloat(room.groups[indexPath.row].score)/CGFloat(room.maxScore)
        if doNotAnimate[indexPath] == nil {
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.view.superview?.layoutIfNeeded()
            }, completion: nil)
            doNotAnimate[indexPath] = true
        }
        // Set up group name
        cell.groupNameLabel.text = room.groups[indexPath.row].name
        cell.alpha = 0
        return cell
    }
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        // We animate the cells here.
//        // We only want the animation to play at first and when the view updates.
//        if let _ = doNotAnimate[indexPath] {
//            return
//        }
//
//
//        doNotAnimate[indexPath] = true
//        let fadeOut = AnimationFactory.makeFadeOut(duration: 0.25, delayFactor: 0.1)
//        let slideIn = AnimationFactory.makeSlideIn(duration: 1, delayFactor: 0.3)
//        let animator = Animator(animation: fadeOut)
//        let animator2 = Animator(animation: slideIn)
//        animator.animate(cell: cell, at: indexPath, in: tableView)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            animator2.animate(cell: cell, at: indexPath, in: tableView)
//        }
//
//
//
//    }
    
    
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var sign = 1
        let signAlert = UIAlertController(title: "Edit Points", message: "Do you want to add or subtract points?", preferredStyle: .actionSheet)
        let pointsAlert = UIAlertController(title: "Points to Add", message: "How many points would you like to add?", preferredStyle: .alert)
        
        signAlert.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        
        
        pointsAlert.addTextField { (field) in
            field.placeholder = "Points"
            field.keyboardType = .numberPad
        }
        pointsAlert.addTextField { (field) in
            field.placeholder = "Reason (blank by default)"
        }
        pointsAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
            let pointsField = pointsAlert.textFields![0]
            guard let change = Int(pointsField.text!) else {
                if pointsField.text!.count > 0 {
                    let alert = UIAlertController(title: "Error", message: "You didn't enter a number!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            guard change > 0 else {
                let alert = UIAlertController(title: "Error", message: "The number must be positive!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let finalScore = self.room.groups[indexPath.row].score + (sign * change)
            guard finalScore >= 0 && finalScore <= self.room.maxScore else {
                let alert = UIAlertController(title: "Error", message: "You're exceeding or going below the score limit!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            var reason = "no reason given"
            
            let reasonField = pointsAlert.textFields![1]
            if reasonField.text != "" {
                reason = reasonField.text!
            }

            
            // Firstly, we log this change
            self.roomRef.child("log").observeSingleEvent(of: .value) { (snapshot) in
                
                let formatter = DateFormatter()
                formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
                let date = formatter.string(from: Date())
                let newLog = ["change":"\(sign * change)","date":date,"group":self.room.groups[indexPath.row].name,"reason":reason]
                
                if snapshot.exists() {
                    var log = snapshot.value as! [[String:String]]
                    log.append(newLog)
                    self.roomRef.child("log").setValue(log)
                } else {
                    self.roomRef.child("log").setValue([newLog])
                }
            }
            
            // Then we update the score
            self.room.groups[indexPath.row].score += (sign * change)
            
            let dictEncoder = DictionaryEncoder()
            
            var newGroups: [[String:Any]] = []
            for group in self.room.groups {
                newGroups.append(try! dictEncoder.encode(group))
            }
            self.roomRef.child("groups").setValue(newGroups)
        }))
        pointsAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        signAlert.addAction(UIAlertAction(title: "Add Points", style: .default, handler: { (_) in
                self.present(pointsAlert, animated: true)
        }))
        signAlert.addAction(UIAlertAction(title: "Subtract Points", style: .default, handler: { (_) in
            sign = -1
            pointsAlert.title = "Points to Subtract"
            pointsAlert.message = "How many points would you like to subtract?"
            self.present(pointsAlert, animated: true)
        }))
        signAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(signAlert, animated: true, completion: nil)
    }
}
