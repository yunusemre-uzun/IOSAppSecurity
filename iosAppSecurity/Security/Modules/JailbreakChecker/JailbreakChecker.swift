    //
    //  JailbreakChecker.swift
    //  iosAppSecurity
    //
    //  Created by Uzun, Yunus on 28.06.2022.
    //

import Foundation
import MachO
import class UIKit.UIApplication

final class JailbreakChecker: ResultProducer {
    weak var delegate: ResultDelegate?
    private let emulatorChecker = EmulatorChecker()
    private var emulatorResult: Result?
    private var isJailbreakDetected = false
    private var jailbreakDetectionResultMessage: [String] = []
    
    private enum JailbreakCheck: CaseIterable {
        case urlSchemes
        case existenceOfSuspiciousFiles
        case suspiciousFilesCanBeOpened
        case restrictedDirectoriesWriteable
        case fork
        case symbolicLinks
        case dyld
    }
    
    private typealias CheckResult = (passed: Bool, failMessage: String)
    
    init() {
        emulatorChecker.delegate = self
    }
    
    func run() {
        emulatorChecker.run()
        performChecks()
        constructResult()
    }
    
    private func constructResult() {
        let result = Result(
            resultType: .jailbreakCheck,
            severity: isJailbreakDetected ? .critical : .none ,
            isDetected: isJailbreakDetected,
            additionalInformation: jailbreakDetectionResultMessage.joined(separator: "\n")
        )
        delegate?.saveResult(with: result)
    }
    
    private func performChecks() {
        var result: CheckResult = (true, "")
        
        for check in JailbreakCheck.allCases {
            switch check {
            case .urlSchemes:
                result = checkURLSchemes()
            case .existenceOfSuspiciousFiles:
                result = checkExistenceOfSuspiciousFiles()
            case .suspiciousFilesCanBeOpened:
                result = checkSuspiciousFilesCanBeOpened()
            case .restrictedDirectoriesWriteable:
                result = checkRestrictedDirectoriesWriteable()
            case .fork:
                if let emulatorResult = emulatorResult,
                   emulatorResult.isDetected {
                    debugPrint("App run in the emulator, skipping the fork check.")
                    result = (false, "")
                } else {
                    result = checkFork()
                }
            case .symbolicLinks:
                result = checkSymbolicLinks()
            case .dyld:
                result = checkDYLD()
            }
            
            isJailbreakDetected = isJailbreakDetected && (!result.passed)
        
            guard !result.passed else {
                continue
            }
            
            jailbreakDetectionResultMessage.append(result.failMessage)
        }
    }
    
    private func canOpenUrlFromList(urlSchemes: [String]) -> CheckResult {
        for urlScheme in urlSchemes {
            if let url = URL(string: urlScheme) {
                if UIApplication.shared.canOpenURL(url) {
                    return(false, "\(urlScheme) URL scheme detected")
                }
            }
        }
        return (true, "")
    }
    
    private func checkURLSchemes() -> CheckResult {
        var flag: CheckResult = (true, "")
        let urlSchemes = [
            "undecimus://",
            "cydia://",
            "sileo://",
            "zbra://",
            "filza://",
            "activator://"
        ]
        
        if Thread.isMainThread {
            flag = canOpenUrlFromList(urlSchemes: urlSchemes)
        } else {
            let semaphore = DispatchSemaphore(value: 0)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                flag = self.canOpenUrlFromList(urlSchemes: urlSchemes)
                semaphore.signal()
            }
            semaphore.wait()
        }
        return flag
    }
    
    private func checkExistenceOfSuspiciousFiles() -> CheckResult {
        var paths = [
            "/usr/sbin/frida-server", // frida
            "/etc/apt/sources.list.d/electra.list", // electra
            "/etc/apt/sources.list.d/sileo.sources", // electra
            "/.bootstrapped_electra", // electra
            "/usr/lib/libjailbreak.dylib", // electra
            "/jb/lzma", // electra
            "/.cydia_no_stash", // unc0ver
            "/.installed_unc0ver", // unc0ver
            "/jb/offsets.plist", // unc0ver
            "/usr/share/jailbreak/injectme.plist", // unc0ver
            "/etc/apt/undecimus/undecimus.list", // unc0ver
            "/var/lib/dpkg/info/mobilesubstrate.md5sums", // unc0ver
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/jb/jailbreakd.plist", // unc0ver
            "/jb/amfid_payload.dylib", // unc0ver
            "/jb/libjailbreak.dylib", // unc0ver
            "/usr/libexec/cydia/firmware.sh",
            "/var/lib/cydia",
            "/etc/apt",
            "/private/var/lib/apt",
            "/private/var/Users/",
            "/var/log/apt",
            "/Applications/Cydia.app",
            "/private/var/stash",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/cache/apt/",
            "/private/var/log/syslog",
            "/private/var/tmp/cydia.log",
            "/Applications/Icy.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/blackra1n.app",
            "/Applications/SBSettings.app",
            "/Applications/FakeCarrier.app",
            "/Applications/WinterBoard.app",
            "/Applications/IntelliScreen.app",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/Library/MobileSubstrate/CydiaSubstrate.dylib",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            "/Applications/Sileo.app",
            "/var/binpack",
            "/Library/PreferenceBundles/LibertyPref.bundle",
            "/Library/PreferenceBundles/ShadowPreferences.bundle",
            "/Library/PreferenceBundles/ABypassPrefs.bundle",
            "/Library/PreferenceBundles/FlyJBPrefs.bundle",
            "/usr/lib/libhooker.dylib",
            "/usr/lib/libsubstitute.dylib",
            "/usr/lib/substrate",
            "/usr/lib/TweakInject",
        ]
        // These files can give false positive in the emulator
        if let emulatorResult = emulatorResult,
           !emulatorResult.isDetected  {
            paths += [
                "/bin/bash",
                "/usr/sbin/sshd",
                "/usr/libexec/ssh-keysign",
                "/bin/sh",
                "/etc/ssh/sshd_config",
                "/usr/libexec/sftp-server",
                "/usr/bin/ssh"
            ]
        }
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return (false, "Suspicious file exists: \(path)")
            }
        }
        return (true, "")
    }
    
    private func checkSuspiciousFilesCanBeOpened() -> CheckResult {
        var paths = [
            "/.installed_unc0ver",
            "/.bootstrapped_electra",
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/etc/apt",
            "/var/log/apt"
        ]
        // These files can give false positive in the emulator
        if let emulatorResult = emulatorResult,
           !emulatorResult.isDetected  {
            paths += [
                "/bin/bash",
                "/usr/sbin/sshd",
                "/usr/bin/ssh"
            ]
        }
        for path in paths {
            if FileManager.default.isReadableFile(atPath: path) {
                return (false, "Suspicious file can be opened: \(path)")
            }
        }
        return (true, "")
    }
    
    private func checkRestrictedDirectoriesWriteable() -> CheckResult {
        let paths = [
            "/",
            "/root/",
            "/private/",
            "/jb/"
        ]
        // If library won't be able to write to any restricted directory the return(false, ...) is never reached
        // because of catch{} statement
        for path in paths {
            do {
                let pathWithSomeRandom = path+UUID().uuidString
                try "AmIJailbroken?".write(toFile: pathWithSomeRandom, atomically: true, encoding: String.Encoding.utf8)
                try FileManager.default.removeItem(atPath: pathWithSomeRandom) // clean if succesfully written
                return (false, "Wrote to restricted path: \(path)")
            } catch {}
        }
        
        return (true, "")
    }
    
    private func checkFork() -> CheckResult {
        let pointerToFork = UnsafeMutableRawPointer(bitPattern: -2)
        let forkPtr = dlsym(pointerToFork, "fork")
        typealias ForkType = @convention(c) () -> pid_t
        let fork = unsafeBitCast(forkPtr, to: ForkType.self)
        let forkResult = fork()
        
        if forkResult >= 0 {
            if forkResult > 0 {
                kill(forkResult, SIGTERM)
            }
            return (false, "Fork was able to create a new process (sandbox violation)")
        }
        return (true, "")
    }
    
    private func checkSymbolicLinks() -> CheckResult {
        
        let paths = [
            "/var/lib/undecimus/apt", // unc0ver
            "/Applications",
            "/Library/Ringtones",
            "/Library/Wallpaper",
            "/usr/arm-apple-darwin9",
            "/usr/include",
            "/usr/libexec",
            "/usr/share"
        ]
        
        for path in paths {
            do {
                let result = try FileManager.default.destinationOfSymbolicLink(atPath: path)
                if !result.isEmpty {
                    return (false, "Non standard symbolic link detected: \(path) points to \(result)")
                }
            } catch {}
        }
        
        return (true, "")
    }
    
    private func checkDYLD() -> CheckResult {
        
        let suspiciousLibraries = [
            "SubstrateLoader.dylib",
            "SSLKillSwitch2.dylib",
            "SSLKillSwitch.dylib",
            "MobileSubstrate.dylib",
            "TweakInject.dylib",
            "CydiaSubstrate",
            "cynject",
            "CustomWidgetIcons",
            "PreferenceLoader",
            "RocketBootstrap",
            "WeeLoader",
            "/.file", // HideJB (2.1.1) changes full paths of the suspicious libraries to "/.file"
            "libhooker",
            "SubstrateInserter",
            "SubstrateBootstrap",
            "ABypass",
            "FlyJB",
            "Substitute",
            "Cephei",
            "Electra",
        ]
        
        for libraryIndex in 0..<_dyld_image_count() {
            
                // _dyld_get_image_name returns const char * that needs to be casted to Swift String
            guard let loadedLibrary = String(validatingUTF8: _dyld_get_image_name(libraryIndex)) else { continue }
            
            for suspiciousLibrary in suspiciousLibraries {
                if loadedLibrary.lowercased().contains(suspiciousLibrary.lowercased()) {
                    return(false, "Suspicious library loaded: \(loadedLibrary)")
                }
            }
        }
        
        return (true, "")
    }
}

extension JailbreakChecker: ResultDelegate {
    func saveResult(with result: Result) {
        emulatorResult = result
    }
}
