//
//  Extensions.swift
//  Leaderboards
//
//  Created by Sean Wong on 3/11/19.
//  Copyright © 2019 Tinkertanker. All rights reserved.
//

import Foundation
import UIKit

extension UISearchBar {
    var textField: UITextField? {
        let subViews = subviews.flatMap { $0.subviews }
        return (subViews.filter { $0 is UITextField }).first as? UITextField
    }
}
