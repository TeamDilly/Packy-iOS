//
//  UIScreen+CheckScreenSize.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import UIKit

extension UIScreen {
    /// - Mini, SE: 375.0
    /// - pro: 390.0
    /// - pro max: 428.0
    var isWiderThan375pt: Bool { self.bounds.size.width > 375 }
}
