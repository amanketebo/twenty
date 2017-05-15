//
//  RoundedRectangle.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/25/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class RoundedCornersButton: UIButton {
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        clipsToBounds = true
        layer.cornerRadius = 5
    }
    
}
