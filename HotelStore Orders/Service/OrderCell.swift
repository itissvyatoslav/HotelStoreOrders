//
//  OrderCell.swift
//  HotelStore Orders
//
//  Created by Svyatoslav Vladimirovich on 18.08.2020.
//  Copyright © 2020 Svyatoslav Vladimirovich. All rights reserved.
//

import UIKit

class OrderCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK:- CONSTRAINTS
    
    @IBOutlet weak var cons1: NSLayoutConstraint!
    @IBOutlet weak var cons2: NSLayoutConstraint!
    @IBOutlet weak var cons3: NSLayoutConstraint!
    @IBOutlet weak var cons4: NSLayoutConstraint!
    @IBOutlet weak var cons5: NSLayoutConstraint!
    
}
