//
//  TDSwitchCell.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class TDSwitchCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!
    var switcherAction: ((UISwitch)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        switcher.addTarget(self, action: "switched:", forControlEvents: .ValueChanged)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func switched(_switch_: UISwitch) {
        switcherAction?(_switch_)
    }
}
