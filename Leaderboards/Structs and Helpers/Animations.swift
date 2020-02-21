//
//  Animatons.swift
//  Leaderboards
//
//  Created by Sean Wong on 6/1/20.
//  Copyright © 2020 SST Inc. All rights reserved.
//

import Foundation
import UIKit
typealias CollectionViewAnimation = (UICollectionViewCell, IndexPath, UICollectionView) -> Void
enum AnimationFactory {

    static func makeFade(duration: TimeInterval, delayFactor: Double) -> CollectionViewAnimation {
        return { cell, indexPath, _ in
            cell.alpha = 0

            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                animations: {
                    cell.alpha = 1
            })
        }
    }
}
