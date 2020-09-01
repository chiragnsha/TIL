/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to make an operation that efficiently waits.
*/

import Foundation

/**
    `DelayOperation` is an `Operation` that will simply wait for a given time
    interval, or until a specific `NSDate`.

    It is important to note that this operation does **not** use the `sleep()`
    function, since that is inefficient and blocks the thread on which it is called.
    Instead, this operation uses `dispatch_after` to know when the appropriate amount
    of time has passed.

    If the interval is negative, or the `NSDate` is in the past, then this operation
    immediately finishes.
*/
class DelayOperation: Operation1 {
    // MARK: Types

    private enum Delay {
        case Interval(TimeInterval)
        case Date(NSDate)
    }
    
    // MARK: Properties
    
    private let delay: Delay
    
    // MARK: Initialization
    
    init(interval: TimeInterval) {
        delay = .Interval(interval)
        super.init()
    }
    
    init(until date: NSDate) {
        delay = .Date(date)
        super.init()
    }
    
    override func execute() {
        let interval: TimeInterval
        
        // Figure out how long we should wait for.
        switch delay {
            case .Interval(let theInterval):
                interval = theInterval

            case .Date(let date):
                interval = date.timeIntervalSinceNow
        }
        
        guard interval > 0 else {
            finish()
            return
        }

//        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)))
//        dispatch_after(when, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
//            // If we were cancelled, then finish() has already been called.
//            if !self.cancelled {
//                self.finish()
//            }
//        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(Int(interval * Double(NSEC_PER_SEC)))) {
            if !self.isCancelled {
                self.finish()
            }
        }
    }
    
    override func cancel() {
        super.cancel()
        // Cancelling the operation means we don't want to wait anymore.
        self.finish()
    }
}
