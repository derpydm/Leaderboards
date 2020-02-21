//
//  Animator.swift
//  Leaderboards
//
//  Created by Tinkertanker on 6/1/20.
//  Copyright © 2020 SST Inc. All rights reserved.
//

import Foundation
import UIKit

final class CollectionViewAnimator {
    private var hasAnimatedAllCells = false
    private let animation: CollectionViewAnimation
    init(animation: @escaping CollectionViewAnimation) {
        self.animation = animation
    }
    func animate(cell: UICollectionViewCell, at indexPath: IndexPath, in collectionView: UICollectionView) {
        guard !hasAnimatedAllCells else {
            return
        }
        
        animation(cell, indexPath, collectionView)
        
        hasAnimatedAllCells = collectionView.isLastVisibleCell(at: indexPath)
    }
}


