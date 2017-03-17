//
//  Double.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 3/15/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation

extension Double {
    
    func roundTo(places: Int) -> Double {
        let divisor = pow(10, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}
