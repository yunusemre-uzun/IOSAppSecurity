//
//  UIHardening.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 7.06.2022.
//

import class Foundation.NotificationCenter
import UIKit

final class UIHardening {
    private let configuration: UIHardeningConfiguration
    private var hidingView: UIView?
    var screenShotAlertConfiguration: ScreenCaptureAlertConfiguration = .init(alertController: nil, alertActions: nil)
    var screenRecordingAlertConfiguration: ScreenCaptureAlertConfiguration = .init(alertController: nil, alertActions: nil)
    var screenCaptureStatus = false
    
    // MARK: - init
    
    init(configuration: UIHardeningConfiguration) {
        self.configuration = configuration
        configure()
    }
    
    // MARK: - Private methods
    
    private func configure() {
        if configuration.enableScreenHidingInBackground,
           let screenHidingconfiguration = configuration.screenHidingConfiguration{
            confiureEnableScreenHidingInBackground(with: screenHidingconfiguration)
        }
        
        if configuration.enableScreenShotAlert,
           let screenShotAlertConfiguration = configuration.screenShotAlertConfiguration {
                configureScreenShotAlert(with: screenShotAlertConfiguration)
        }
        
        if configuration.enableScreenRecordingAlert,
           let screenRecordingAlertConfiguration = configuration.screenRecordingAlertConfiguration {
            configureScreenRecordingAlert(with: screenRecordingAlertConfiguration)
        }
    }
    
    private func confiureEnableScreenHidingInBackground(with screenHidingconfiguration: ScreenHidingConfigurationProtocol) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackround),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    private func configureScreenShotAlert(with screenShotAlertConfiguration: ScreenCaptureAlertConfiguration) {
        self.screenShotAlertConfiguration = screenShotAlertConfiguration
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
        #if targetEnvironment(simulator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationCenter.default.post(name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        }
        #endif
    }
    
    private func configureScreenRecordingAlert(with screenRecordingAlertConfiguration: ScreenCaptureAlertConfiguration) {
        self.screenRecordingAlertConfiguration = screenRecordingAlertConfiguration
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(capturedDidChange),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
        #if targetEnvironment(simulator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            NotificationCenter.default.post(name: UIScreen.capturedDidChangeNotification, object: nil)
        }
        #endif
    }
    
    private func showAlert(with configuration: ScreenCaptureAlertConfiguration) {
        guard let alertController = configuration.alertController else {
            let alertController = UIAlertController(
                title: configuration.alertTitle,
                message: configuration.alertMessage,
                preferredStyle: .alert
            )
            let alertAction = UIAlertAction(title: "OK", style: .destructive)
            alertController.addAction(alertAction)
            show(alert: alertController)
            return
        }
        show(alert: alertController)
    }
    
    @objc private func userDidTakeScreenshot() {
        showAlert(with: screenShotAlertConfiguration)
    }
    
    @objc private func capturedDidChange() {
        handleScreenCaptureStatusDidChange()
    }
}

// MARK: - ViewHelperMethods, AlertPresentable

extension UIHardening: ViewHelperMethods, AlertPresentable {}

// MARK: - ScreenRecordingAlertPresentable

extension UIHardening: ScreenRecordingAlertPresentable {
    func handleScreenCaptureStatusDidChange() {
        guard didMainScreenCaptured() else {
            return
        }
        showAlert(with: screenRecordingAlertConfiguration)
    }
}

// MARK: - ScreenShotAlertPresentable

extension UIHardening: ScreenShotAlertPresentable {}

// MARK: - Background hiding view implementations

extension UIHardening {
    
    @objc private func applicationDidEnterBackround() {
        guard let hidingView = configuration.screenHidingConfiguration?.hidingView else {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let hidingView = UIVisualEffectView(effect: blurEffect)
            addHidingView(with: hidingView)
            return
        }
        addHidingView(with: hidingView)
    }
    
    @objc private func applicationWillEnterForeground() {
        removeHidingView()
    }
    
    private func addHidingView(with hidingView: UIView) {
        guard let topMostViewController = getTopMostViewController(),
              let view = topMostViewController.view else {
            return
        }
        
        guard let blurView = hidingView as? UIVisualEffectView else {
            addArrangeSubview(to: view, subview: hidingView)
            return
        }
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
        self.hidingView = blurView
    }
    
    private func addArrangeSubview(to view: UIView, subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
        let horizontalConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        )
        let verticalConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        )
        let widthConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: view.layer.bounds.width
        )
        let heightConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: view.layer.bounds.height
        )
        view.addConstraints([
            horizontalConstraint,
            verticalConstraint,
            widthConstraint,
            heightConstraint
        ])
        self.hidingView = subview
    }
    
    private func removeHidingView() {
        self.hidingView?.removeFromSuperview()
    }
}


