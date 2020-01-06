//
//  HomeTableViewController.swift
//  Leaderboards
//
//  Created by Sean Wong on 2/11/19.
//  Copyright © 2019 Tinkertanker. All rights reserved.
//

import UIKit
import FirebaseDatabase
class HomeTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var shouldAnimate = true
    var roomNames: [String]! = []
    var roomCodes: [String]! = []
    var roomGroups: [[String:Int]]! = []
    @IBOutlet weak var userGreetingsLabel: UILabel!
    var ref: DatabaseReference!
    var sentRoom: Room!
    let haptics = UIImpactFeedbackGenerator()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLTGR()
        self.ref = Database.database().reference()
        
        // Grab rooms
        
        ref.child("rooms").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let rooms = snapshot.value as! NSDictionary
                let keys = rooms.allKeys as! [String]
                
                // Clear all rooms as we are reinitialising them
                
                self.roomCodes.removeAll()
                self.roomNames.removeAll()
                self.roomGroups.removeAll()
                
                for roomCode in keys {
                    
                    // Force downcast for all of these as we already know the room exists
                    let room = rooms[roomCode]! as! NSDictionary
                    let code = room["code"] as! String
                    let groups = room["groups"] as! [String:Int]
                    let name = room["name"] as! String
                    print(code)
                    print(groups)
                    print(name)
                    self.roomNames.append(name)
                    self.roomCodes.append(code)
                    self.roomGroups.append(groups)
                    
                }
                
            }
            
            // Reload data
            self.shouldAnimate = true
            self.collectionView.reloadData()
            
        }
        setUpUserGreetingLabel()
    }
    
    func setupLTGR() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.75
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
    }
    
    @objc func handleLongPress(_ gestureReconizer: UILongPressGestureRecognizer) {
        if !(gestureReconizer.state == UIGestureRecognizer.State.began) {
            return
        }
        
        let p = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: p)
        let actionSheet = UIAlertController(title: "Delete Room", message: "Deleting this room will remove it permanently. Are you sure?", preferredStyle: .actionSheet)
        if let index = indexPath {
            // do stuff with your cell, for example print the indexPath
            actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                let row = index.row
                self.ref.child("rooms").child(self.roomCodes[row]).removeValue()
                self.roomNames.remove(at: index.row)
                self.roomGroups.remove(at: index.row)
                self.roomCodes.remove(at: index.row)
                self.shouldAnimate = true
                self.collectionView.reloadData()
            }))
            self.present(actionSheet, animated: true)
        } else {
            print("Could not find index path")
        }
    }
    @IBAction func unwindToHome(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        
        // Check for rooms again
        
        ref.child("rooms").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                self.shouldAnimate = true
                let rooms = snapshot.value as! NSDictionary
                let keys = rooms.allKeys as! [String]
                
                // Clear all rooms as we are reinitialising them
                
                self.roomCodes.removeAll()
                self.roomNames.removeAll()
                self.roomGroups.removeAll()
                
                for roomCode in keys {
                    
                    // Force downcast for all of these as we already know the room exists
                    let room = rooms[roomCode]! as! NSDictionary
                    let code = room["code"] as! String
                    let groups = room["groups"] as! [String:Int]
                    let name = room["name"] as! String
                    print(code)
                    print(groups)
                    print(name)
                    self.roomNames.append(name)
                    self.roomCodes.append(code)
                    self.roomGroups.append(groups)
                    
                }
                
            }
            
            // Reload data
            self.shouldAnimate = true
            self.collectionView.reloadData()
            
        }
    }
    
    // MARK: - User interface
    func setUpUserGreetingLabel() {
        // NSAttributedString for bolding the username
        let defaultAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)]
        
        let attributes = NSMutableAttributedString(string: "Welcome.", attributes: defaultAttributes)
        
        
        userGreetingsLabel.attributedText = attributes
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    // MARK: - CollectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roomNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // We animate the cells here.
        // We only want the animation to play at first and when the view updates.
        if shouldAnimate {
            let animation = AnimationFactory.makeCollFade(duration: 1.0, delayFactor: 0.2)
            let animator = CollectionViewAnimator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: collectionView)
        }
        if indexPath.row == roomNames.endIndex - 1 {
            shouldAnimate = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myroom", for: indexPath) as! MyRoomsCollectionViewCell
        cell.titleLabel.text = roomNames[indexPath.row]
        cell.roomCodeLabel.text = roomCodes[indexPath.row]
        cell.layer.cornerRadius = 12
        cell.clipsToBounds = true
        
        return cell
    }
    
    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Grab the new room from Firebase again in case there were changes from loading till now
        
        ref.child("rooms").child(roomCodes[indexPath.row]).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                
                // grab data
                
                let value = snapshot.value as! NSDictionary
                let code = value["code"] as! String
                let name = value["name"] as! String
                let groups = value["groups"] as! [String:Int]
                let maxScore = value["maxScore"] as! Int
                // make a new room
                
                self.sentRoom = Room(name: name, code: code, groups: groups, maxScore: maxScore)
                
                // segue to the room itself
                
                self.performSegue(withIdentifier: "showRoom", sender: nil)
                
            }
        }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoom" {
            // make a new instance of
            let dest = segue.destination as! ViewRoomsViewController
            dest.room = sentRoom
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
