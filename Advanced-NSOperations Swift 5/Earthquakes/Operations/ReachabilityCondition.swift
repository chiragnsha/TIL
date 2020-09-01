/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

import Foundation
import SystemConfiguration

/**
    This is a condition that performs a very high-level reachability check.
    It does *not* perform a long-running reachability check, nor does it respond to changes in reachability.
    Reachability is evaluated once when the operation to which this is attached is asked about its readiness.
*/
struct ReachabilityCondition: OperationCondition {
    
    func dependencyForOperation(operation: Operation1) -> Operation? {
        return nil
    }
    
    static let hostKey = "Host"
    static let name = "Reachability"
    static let isMutuallyExclusive = false
    
    let host: NSURL
    
    
    init(host: NSURL) {
        self.host = host
    }
    
    func dependencyForOperation(operation: Operation1) -> Operation1? {
        return nil
    }
    
    func evaluateForOperation(operation: Operation1, completion: @escaping (OperationConditionResult) -> Void) {
        ReachabilityController.requestReachability(url: host) { reachable in
            if reachable {
                completion(.Satisfied)
            }
            else {
                let error = NSError(code: .ConditionFailed, userInfo: [
                    OperationConditionKey: type(of: self).name,
                    type(of: self).hostKey: self.host
                ])
                
                completion(.Failed(error))
            }
        }
    }
    
}

/// A private singleton that maintains a basic cache of `SCNetworkReachability` objects.
private class ReachabilityController {
    static var reachabilityRefs = [String: SCNetworkReachability]()
    
//    static let reachabilityQueue = dispatch_queue_create("Operations.Reachability", DISPATCH_QUEUE_SERIAL)

    
    static let reachabilityQueue = DispatchQueue(label: "Operations.Reachability", attributes: .concurrent)
    
    static func requestReachability(url: NSURL, completionHandler: @escaping (Bool) -> Void) {
        if let host = url.host {
            reachabilityQueue.async {
                var ref = self.reachabilityRefs[host]

                if ref == nil {
                    let hostString = host as NSString
                    ref = SCNetworkReachabilityCreateWithName(nil, hostString.utf8String!)
                }
                
                if let ref = ref {
                    self.reachabilityRefs[host] = ref
                    
                    var reachable = false
                    var flags: SCNetworkReachabilityFlags = []
                    if SCNetworkReachabilityGetFlags(ref, &flags) != false {
                        /*
                            Note that this is a very basic "is reachable" check.
                            Your app may choose to allow for other considerations,
                            such as whether or not the connection would require
                            VPN, a cellular connection, etc.
                        */
                        reachable = flags.contains(.reachable)
                    }
                    completionHandler(reachable)
                }
                else {
                    completionHandler(false)
                }
            }
        }
        else {
            completionHandler(false)
        }
    }
}
