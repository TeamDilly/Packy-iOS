//
//  UINavigationController+PopGesture.swift
//  Packy
//
//  Created by Mason Kim on 1/10/24.
//

import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()

        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return UserDefaultsClient.liveValue.boolForKey(.isPopGestureEnabled) && viewControllers.count > 1
    }
}
