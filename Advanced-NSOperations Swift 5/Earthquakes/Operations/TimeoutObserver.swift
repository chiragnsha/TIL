/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to implement the OperationObserver protocol.
*/

import Foundation

/**
    `TimeoutObserver` is a way to make an `Operation` automatically time out and
    cancel after a specified time interval.
*/
struct TimeoutObserver: OperationObserver {
    // MARK: Properties

    static let timeoutKey = "Timeout"
    
    private let timeout: TimeInterval
    
    // MARK: Initialization
    
    init(timeout: TimeInterval) {
        self.timeout = timeout
    }
    
    // MARK: OperationObserver
    
    func operationDidStart(operation: Operation1) {
        // When the operation starts, queue up a block to cause it to time out.
//        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(timeout * Double(NSEC_PER_SEC)))
//
//        dispatch_after(when, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
//            /*
//                Cancel the operation if it hasn't finished and hasn't already
//                been cancelled.
//            */
//            if !operation.finished && !operation.cancelled {
//                let error = NSError(code: .ExecutionFailed, userInfo: [
//                    self.dynamicType.timeoutKey: self.timeout
//                ])
//
//                operation.cancelWithError(error)
//            }
//        }
        
        
        DispatchQueue.global().asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(Int(timeout * Double(NSEC_PER_SEC))), execute: {
            if !operation.isFinished && !operation.isCancelled {
                let error = NSError(code: .ExecutionFailed, userInfo: [
                    type(of: self).timeoutKey: self.timeout
                ])

                operation.cancelWithError(error: error)
            }
        })
    }

    func operation(operation: Operation1, didProduceOperation newOperation: Operation) {
        // No op.
    }

    func operationDidFinish(operation: Operation1, errors: [NSError]) {
        // No op.
    }
}
