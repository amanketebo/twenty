//
//  BlurredView.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 7/4/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class BlurredView: UIVisualEffectView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        effect = UIBlurEffect.init(style: .dark)
    }
}
