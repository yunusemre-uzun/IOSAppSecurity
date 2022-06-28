//
//  ViewHelpers.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 7.06.2022.
//

import UIKit

protocol ViewHelperMethods {
    func getTopMostViewController() -> UIViewController?
}

extension ViewHelperMethods {
    func getTopMostViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        return rootViewController
    }
}
