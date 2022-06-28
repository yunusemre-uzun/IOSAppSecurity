//
//  ScreenShotHidingAlertConfiguration.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 3.02.2022.
//

import class UIKit.UIAlertController
import class UIKit.UIAlertAction

/// Provide an alert controller to be presented.
/// If alert controller is null, then create alert from title, message and actions
public struct ScreenCaptureAlertConfiguration {
    let alertController: UIAlertController?
    let alertTitle: String = "Warning"
    let alertMessage: String? = "Do not share your personal information with 3rd people."
    let alertActions: [UIAlertAction]?
    
    public init(alertController: UIAlertController?, alertActions: [UIAlertAction]?) {
        self.alertController = alertController
        self.alertActions = alertActions
    }
}
