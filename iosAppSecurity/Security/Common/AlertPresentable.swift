//
//  AlertPresentable.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 7.06.2022.
//

import UIKit

protocol AlertPresentable {
    func show(alert: UIAlertController)
}

extension AlertPresentable where Self: ViewHelperMethods {
    
    func show(alert: UIAlertController) {
        guard checkPresentedViewControllerIsNotAlert() else {
            return
        }
        
        let viewController = getTopMostViewController()
        viewController?.show(alert, sender: nil)
    }
    
    private func checkPresentedViewControllerIsNotAlert() -> Bool {
        !(getTopMostViewController()?.presentedViewController is UIAlertController)
    }
}

protocol ScreenShotAlertPresentable: AlertPresentable {
    var screenShotAlertConfiguration: ScreenCaptureAlertConfiguration { get }
}

protocol ScreenRecordingAlertPresentable: AlertPresentable {
    var screenRecordingAlertConfiguration: ScreenCaptureAlertConfiguration { get }
    var screenCaptureStatus: Bool { get }
    func handleScreenCaptureStatusDidChange()
}

extension ScreenRecordingAlertPresentable {
    
    func didMainScreenCaptured() -> Bool {
        UIScreen.main.isCaptured
    }
}
