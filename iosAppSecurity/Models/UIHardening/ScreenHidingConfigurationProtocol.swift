//
//  ScreenHidingConfiguration.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 3.02.2022.
//

import class UIKit.UIView

protocol ScreenHidingConfigurationProtocol {
    var hidingView: UIView? { get }
}

/// If hiding view is provided present that, e.g. splash image cean be used
/// If hiding view is null apply opacity to the current view
public struct ScreenHidingConfiguration: ScreenHidingConfigurationProtocol {
    let hidingView: UIView?
    
    public init(hidingView: UIView?) {
        self.hidingView = hidingView
    }
}
