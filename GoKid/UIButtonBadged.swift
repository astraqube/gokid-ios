//
//  UIButtonBadged.swift
//  GoKid
//
//  Created by Dean Quinanola on 9/2/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import JSBadgeView

class UIButtonBadged: UIButton {

    var badgeView: JSBadgeView!

    func setBadge(num: Int?) {
        if badgeView == nil {
            badgeView = JSBadgeView()
            badgeView.badgeAlignment = .TopRight
            addSubview(badgeView)
        }

        badgeView.badgeText = num?.description
        badgeView.hidden = num < 1
    }

}
