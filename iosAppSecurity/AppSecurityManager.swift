//
//  AppSecurityManager.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 3.02.2022.
//

import Foundation

public final class AppSecurityManager {
    public static let shared = AppSecurityManager()
    private var resultProducers = Array<ResultProducer>()
    private var results = Dictionary<ResultType, Result>()
    private var configuration: AppSecurityConfiguration?
    private var uiHardeningHandler: UIHardening?
    private var proxyChecker: NetworkSettingsHealthCheck?
    private var emulatorChecker: EmulatorChecker?
    private var reverseEngineringChecker: ReverseEngineeringToolsChecker?
    private var jailbreakChecker: JailbreakChecker?
    
    private init() {}
    
    public func setup(with config: AppSecurityConfiguration) {
        configuration = config
        uiHardeningHandler = UIHardening(configuration: config.uiHardeningConfiguration)
        if config.enableProxyCheck {
            proxyChecker = NetworkSettingsHealthCheck()
            proxyChecker?.delegate = self
            resultProducers.append(proxyChecker!)
        }
        if config.enableEmulatorCheck {
            emulatorChecker = EmulatorChecker()
            emulatorChecker?.delegate = self
            resultProducers.append(emulatorChecker!)
        }
        if config.enableReverseEngineeringCheck {
            reverseEngineringChecker = ReverseEngineeringToolsChecker()
            reverseEngineringChecker?.delegate = self
            resultProducers.append(reverseEngineringChecker!)
        }
        if config.enableJailbreakCheck {
            jailbreakChecker = JailbreakChecker()
            jailbreakChecker?.delegate = self
            resultProducers.append(jailbreakChecker!)
        }
         
    }
    
    public func run() {
        for producer in resultProducers {
            producer.run()
        }
        print(results)
    }
}

extension AppSecurityManager: ResultDelegate {
    func saveResult(with result: Result) {
        results[result.resultType] = result
    }
}
