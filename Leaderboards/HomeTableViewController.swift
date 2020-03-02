//
//  HomeTableViewController.swift
//  Leaderboards
//
//  Created by Sean Wong on 2/11/19.
//  Copyright © 2019 Tinkertanker. All rights reserved.
//

import UIKit
import FirebaseDatabase
import DictionaryCoding
class HomeTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var shouldAnimate = true
    var rooms: [Room] = []
    @IBOutlet weak var userGreetingsLabel: UILabel!
    var ref: DatabaseReference!
    var sentRoom: Room!
    let haptics = UIImpactFeedbackGenerator()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLTGR()
        self.ref = Database.database().reference()
        reloadRooms()
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
            actionSheet.popoverPresentationController?.sourceView = collectionView.cellForItem(at: index)
            haptics.impactOccurred()
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                let row = index.row
                self.ref.child("rooms").child(self.rooms[row].code).removeValue()
                self.rooms.remove(at: row)
                self.shouldAnimate = true
                self.collectionView.reloadData()
            }))
            self.present(actionSheet, animated: true)
        }
    }
    fileprivate func reloadRooms() {
        // Check for rooms again
        
        ref.child("rooms").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                self.shouldAnimate = true
                let value = snapshot.value as! NSDictionary
                let keys = value.allKeys as! [String]
                
                // Clear all rooms as we are reinitialising them
                
                self.rooms.removeAll()
                for roomCode in keys {
                    // Force downcast for all of these as we already know the room exists
                    let room = value[roomCode]! as! NSDictionary
                    let code = room["code"] as! String
                    let groups = room["groups"] as! [[String:Any]]
                    let name = room["name"] as! String
                    let maxScore = room["maxScore"] as! Int
                    var groupsArray: [Group] = []
                    let dictDecoder = DictionaryDecoder()
                    for group in groups {
                        groupsArray.append(try! dictDecoder.decode(Group.self, from: group))
                    }
                    let newRoom = Room(name: name, code: code, groups: groupsArray, maxScore: maxScore)
                    self.rooms.append(newRoom)
                }
                
            }
            
            // Reload data
            self.shouldAnimate = true
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func unwindToHome(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        reloadRooms()
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
        return 3
    }
    
    // MARK: - CollectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // We animate the cells here.
        // We only want the animation to play at first and when the view updates.
        if shouldAnimate {
            let animation = AnimationFactory.makeFade(duration: 1.0, delayFactor: 0.2)
            let animator = CollectionViewAnimator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: collectionView)
        }
        if indexPath.row == rooms.endIndex - 1 {
            shouldAnimate = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myroom", for: indexPath) as! MyRoomsCollectionViewCell
        let room = rooms[indexPath.row]
        cell.titleLabel.text = room.name
        cell.roomCodeLabel.text = room.code
        cell.layer.cornerRadius = 12
        cell.clipsToBounds = true
        
        return cell
    }
    
    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Grab the new room from Firebase again in case the room was deleted from loading till now
        
        sentRoom = rooms[indexPath.row]
        ref.child("rooms").child(sentRoom.code).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let value = snapshot.value as! NSDictionary
                let name = value["name"] as! String
                let code = value["code"] as! String
                let maxScore = value["maxScore"] as! Int
                let rawGroups = value["groups"] as! [[String:Any]]
                let dictDecoder = DictionaryDecoder()
                var groups: [Group] = []
                for group in rawGroups {
                    groups.append(try! dictDecoder.decode(Group.self, from: group))
                }
                let room = Room(name: name, code: code, groups: groups, maxScore: maxScore)
                self.sentRoom = room
                self.performSegue(withIdentifier: "showRoom", sender: nil)
                
            }
        }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoom" {
            let nav = segue.destination as! UINavigationController
            let dest = nav.viewControllers[0] as! ViewRoomsViewController
            dest.room = sentRoom
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
