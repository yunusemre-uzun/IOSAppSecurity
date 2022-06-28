//
//  ReverseEngineeringChecker.swift
//  iosAppSecurity
//
//  Created by Uzun, Yunus on 13.06.2022.
//

import Foundation
import MachO // dyld

final class ReverseEngineeringToolsChecker: ResultProducer {
    weak var delegate: ResultDelegate?
    private var suspiciousDydlFound = false
    private var suspiciousFileFound = false
    private var suspiciousOpenPortsFound = false
    private lazy var isReverseEngineered = (suspiciousFileFound ||
                                            suspiciousDydlFound ||
                                            suspiciousOpenPortsFound)
    
    func run() {
        checkIfReverseEngineered()
    }
    
    init() {}
    
    func checkIfReverseEngineered() {
        suspiciousDydlFound = checkDYLD()
        suspiciousFileFound = checkExistenceOfSuspiciousFiles()
        suspiciousOpenPortsFound = checkOpenedPorts()
        constructResults()
    }
    
    private func checkDYLD() -> Bool {
        
        let suspiciousLibraries = [
            "FridaGadget",
            "frida", // Needle injects frida-somerandom.dylib
            "cynject",
            "libcycript"
        ]
        
        for libraryIndex in 0..<_dyld_image_count() {
            // _dyld_get_image_name returns const char * that needs to be casted to Swift String
            guard let loadedLibrary = String(validatingUTF8: _dyld_get_image_name(libraryIndex)) else {
                continue
            }
            
            for suspiciousLibrary in suspiciousLibraries {
                if loadedLibrary.lowercased().contains(suspiciousLibrary.lowercased()) {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func checkExistenceOfSuspiciousFiles() -> Bool {
        
        let paths = [
            "/usr/sbin/frida-server"
        ]
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        return false
    }
    
    private func checkOpenedPorts() -> Bool {
        let ports = [
            27042, // default Frida
            4444 // default Needle
        ]
        
        for port in ports {
            if canOpenLocalConnection(port: port) {
                return true
            }
        }
        return false
    }
    
    private func canOpenLocalConnection(port: Int) -> Bool {
        var serverAddress = sockaddr_in()
        serverAddress.sin_family = sa_family_t(AF_INET)
        serverAddress.sin_addr.s_addr = inet_addr("127.0.0.1")
        serverAddress.sin_port = swapBytesIfNeeded(port: in_port_t(port))
        let sock = socket(AF_INET, SOCK_STREAM, 0)
        
        let result = withUnsafePointer(to: &serverAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
            }
        }
        
        defer {
            close(sock)
        }
        
        if result != -1 {
            return true // Port is opened
        }
        
        return false
    }
    
    private func swapBytesIfNeeded(port: in_port_t) -> in_port_t {
        let littleEndian = Int(OSHostByteOrder()) == OSLittleEndian
        return littleEndian ? _OSSwapInt16(port) : port
    }
    
    private func constructResults() {
        let reverseEngineeringResult = Result(
            resultType: .reverseEngineeringCheck,
            severity: isReverseEngineered ? .critical : .none,
            isDetected: isReverseEngineered
        )
        delegate?.saveResult(with: reverseEngineeringResult)
    }
}
