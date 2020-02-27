//
//  Room.swift
//  Leaderboards
//
//  Created by Tinkertanker on 21/2/20.
//  Copyright © 2020 SST Inc. All rights reserved.
//

import Foundation

struct Room: Codable {
    init(name: String, code: String, groups: [Group], maxScore: Int) {
        self.name = name
        self.code = code
        self.groups = groups
        self.maxScore = maxScore
    }
    var name: String
    var code: String
    var groups: [Group]
    var maxScore: Int = 1000
}
