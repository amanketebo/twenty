//
//  BlurredView.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 7/4/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class BlurredView: UIVisualEffectView {
    override func awakeFromNib() {
        effect = UIBlurEffect(style: .dark)
    }
}
