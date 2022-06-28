//
//  ProxyChecker.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 9.06.2022.
//

final class NetworkSettingsHealthCheck: ResultProducer {
    weak var delegate: ResultDelegate?
    private var settings = Dictionary<String, Any>()
    private var propertyList = NSDictionary()
    private var isProxyEnabled = false
    private var isHTTPEnabled = false
    private var isExceptionDomainFound = false
    private var exceptionDomains = Array<String>()
    
    init() {}
    
    func run() {
        getSystemProxySettings()
        loadPropertyList()
        checkDeviceProxySettings()
        checkHTTPEnabled()
        checkExceptionalDomains()
        constructResults()
    }
    
    private func getSystemProxySettings() {
        guard let unmanagedSettings = CFNetworkCopySystemProxySettings(),
              let settings = unmanagedSettings.takeRetainedValue() as? [String: Any] else {
            return
        }
        self.settings = settings
    }
    
    private func checkDeviceProxySettings() {
        isProxyEnabled = (settings.keys.contains("HTTPProxy") || settings.keys.contains("HTTPSProxy"))
    }
    
    private func checkHTTPEnabled() {
        guard let appTransportSecurity = propertyList["NSAppTransportSecurity"] as? [String: Any],
        let httpEnabled = appTransportSecurity["NSAllowsArbitraryLoads"] as? Bool else {
            return
        }
        isHTTPEnabled = httpEnabled
    }
    
    private func checkExceptionalDomains() {
        guard let appTransportSecurity = propertyList["NSAppTransportSecurity"] as? [String: Any],
              let exceptionDomains = appTransportSecurity["NSExceptionDomains"] as? [String: Any] else {
            return
        }
        self.exceptionDomains = exceptionDomains.keys.sorted()
        isExceptionDomainFound = !exceptionDomains.isEmpty
    }
    
    private func loadPropertyList() {
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")!
        guard let dict = NSDictionary(contentsOfFile: path) else {
            return
        }
        propertyList = dict
    }
    
    private func constructResults() {
        constructProxyCheckResult()
        constructHttpEnabledChekcResult()
        constructExceptionDomainCheckResult()
    }
    
    private func constructProxyCheckResult() {
        let proxyResult = Result(
            resultType: .proxyCheck,
            severity: isProxyEnabled ? .high : .none,
            isDetected: isProxyEnabled
        )
        delegate?.saveResult(with: proxyResult)
    }
    
    private func constructHttpEnabledChekcResult() {
        let httpCheckResult = Result(
            resultType: .isHttpEnabled,
            severity: isHTTPEnabled ? .high : .none,
            isDetected: isHTTPEnabled
        )
        delegate?.saveResult(with: httpCheckResult)
    }
    
    private func constructExceptionDomainCheckResult() {
        let exceptionDomainCheckResult = Result(
            resultType: .exceptionDomainCheck,
            severity: isExceptionDomainFound ? .normal: .none,
            isDetected: isExceptionDomainFound,
            additionalInformation: exceptionDomains.joined(separator: ",")
        )
        delegate?.saveResult(with: exceptionDomainCheckResult)
    }
}
