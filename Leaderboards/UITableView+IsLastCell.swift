//
//  UITableView+IsLastCell.swift
//  Leaderboards
//
//  Created by Tinkertanker on 6/1/20.
//  Copyright © 2020 SST Inc. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func isLastVisibleCell(at indexPath: IndexPath) -> Bool {
        guard let lastIndexPath = indexPathsForVisibleRows?.last else {
            return false
        }

        return lastIndexPath == indexPath
    }
}

extension UICollectionView {
    func isLastVisibleCell(at indexPath: IndexPath) -> Bool {
        guard let lastIndexPath = indexPathsForVisibleItems.last else {
            return false
        }

        return lastIndexPath == indexPath
    }
}
