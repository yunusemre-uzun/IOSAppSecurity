//
//  ResultDelegate.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 9.06.2022.
//

protocol ResultDelegate: AnyObject {
    func saveResult(with result: Result)
}

struct Result {
    let resultType: ResultType
    let severity: Severity
    let isDetected: Bool
    var additionalInformation: String?
}

enum ResultType: String {
    case proxyCheck
    case isHttpEnabled
    case exceptionDomainCheck
    case emulatorCheck
    case reverseEngineeringCheck
    case jailbreakCheck
}

enum Severity: Int {
    case none = 0
    case low
    case normal
    case high
    case critical
}


