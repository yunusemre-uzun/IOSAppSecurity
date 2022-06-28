//
//  TrustedCerts.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 3.02.2022.
//

import Foundation


public struct TrustedCertificates {
    let certificatePairs: [String: SecCertificate] // Domain and certificate pair
    
    public init(certificatePairs: [String: SecCertificate]) {
        self.certificatePairs = certificatePairs
    }
}
