//
//  Helper Functions.swift
//  Leaderboards
//
//  Created by Sean Wong on 3/11/19.
//  Copyright © 2019 Tinkertanker. All rights reserved.
//

import Foundation
import UIKit

func coloredCommas(with string: String) -> NSAttributedString {
    let mutableString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.184713006, green: 0.2980033159, blue: 0.5609270334, alpha: 1)])
    let colorAttribute = [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.6019130945, green: 0.7103144526, blue: 1, alpha: 1)]
    
    let indices = string.indicesOf(string: ",")
    
    for i in indices {
        mutableString.addAttributes(colorAttribute, range: NSRange(location: i, length: 1))
    }
    
    return mutableString
}

public extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
}
