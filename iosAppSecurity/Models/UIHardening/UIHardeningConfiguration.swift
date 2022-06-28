//
//  UIHardeningConfiguration.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 7.06.2022.
//

public struct UIHardeningConfiguration {
    let enableScreenHidingInBackground: Bool
    let screenHidingConfiguration: ScreenHidingConfigurationProtocol?
    let enableScreenShotAlert: Bool
    let screenShotAlertConfiguration: ScreenCaptureAlertConfiguration?
    let enableScreenRecordingAlert: Bool
    let screenRecordingAlertConfiguration: ScreenCaptureAlertConfiguration?
    
    public init(
        enableScreenHidingInBackground: Bool,
        screenHidingConfiguration: ScreenHidingConfiguration?,
        enableScreenShotAlert: Bool,
        screenShotAlertConfiguration: ScreenCaptureAlertConfiguration?,
        enableScreenRecordingAlert: Bool,
        screenRecordingAlertConfiguration: ScreenCaptureAlertConfiguration?
    ) {
        self.enableScreenHidingInBackground = enableScreenHidingInBackground
        self.screenHidingConfiguration = screenHidingConfiguration
        self.enableScreenShotAlert = enableScreenShotAlert
        self.screenShotAlertConfiguration = screenShotAlertConfiguration
        self.enableScreenRecordingAlert = enableScreenRecordingAlert
        self.screenRecordingAlertConfiguration = screenRecordingAlertConfiguration
    }
}
