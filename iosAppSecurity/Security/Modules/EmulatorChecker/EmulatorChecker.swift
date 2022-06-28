//
//  EmulatorChecker.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 13.06.2022.
//

import Foundation

final class EmulatorChecker: ResultProducer {
    weak var delegate: ResultDelegate?
    private var isRunningOnEmulator = false
    
    init() {}
    
    func run() {
        checkIsRunningOnEmulator()
        constructResult()
    }
    
    private func checkIsRunningOnEmulator() {
        isRunningOnEmulator = checkRuntime() || checkCompile() 
    }
    
    private func checkRuntime() -> Bool {
        return ProcessInfo().environment["SIMULATOR_DEVICE_NAME"] != nil
    }
    
    private func checkCompile() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    private func constructResult() {
        let result = Result(
            resultType: .emulatorCheck,
            severity: isRunningOnEmulator ? .high : .none,
            isDetected: isRunningOnEmulator
        )
        delegate?.saveResult(with: result)
    }
}
