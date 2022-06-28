//
//  Configuration.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 3.02.2022.
//

import Foundation

public struct AppSecurityConfiguration {
    let enableCertPinningForWebView: Bool // Enable cert pinning for WKWebView, provide trusted certs
    let trustedCertificates: TrustedCertificates?
    let enablePListCheck: Bool // Enabled only debug mode
    let uiHardeningConfiguration: UIHardeningConfiguration
    let enableUserDefaultsWriteCheck: Bool // Check for saved data with user defaults
    let enableProxyCheck: Bool
    let enableEmulatorCheck: Bool
    let enableReverseEngineeringCheck: Bool
    let enableJailbreakCheck: Bool
    
    public init(
        enableCertPinningForWebView: Bool,
        trustedCertificates: TrustedCertificates?,
        enablePListCheck: Bool,
        UIHardeningConfiguration: UIHardeningConfiguration,
        enableUserDefaultsWriteCheck: Bool,
        enableProxyCheck: Bool,
        enableEmulatorCheck: Bool,
        enableReverseEnginerringCheck: Bool,
        enableJailbreakCheck: Bool
    ) {
        self.enableCertPinningForWebView = enableCertPinningForWebView
        self.trustedCertificates = trustedCertificates
        self.enablePListCheck = enablePListCheck
        self.uiHardeningConfiguration = UIHardeningConfiguration
        self.enableUserDefaultsWriteCheck = enableUserDefaultsWriteCheck
        self.enableProxyCheck = enableProxyCheck
        self.enableEmulatorCheck = enableEmulatorCheck
        self.enableReverseEngineeringCheck = enableReverseEnginerringCheck
        self.enableJailbreakCheck = enableJailbreakCheck
    }
}
