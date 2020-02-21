//
//  Group.swift
//  Leaderboards
//
//  Created by Tinkertanker on 21/2/20.
//  Copyright © 2020 SST Inc. All rights reserved.
//

import Foundation
import DeepDiff

struct Group: Codable, DiffAware {
    var diffId: DiffId {
        self.name
    }
            
    static func compareContent(_ a: Group, _ b: Group) -> Bool {
        return a.score == b.score
    }
    
    typealias DiffId = String
    
    
    init(_ name: String, _ score: Int) {
        self.name = name
        self.score = score
    }
    var name: String
    var score: Int
}
