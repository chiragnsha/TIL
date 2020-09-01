/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to implement the OperationObserver protocol.
*/

import Foundation

/**
    The `BlockObserver` is a way to attach arbitrary blocks to significant events
    in an `Operation`'s lifecycle.
*/
struct BlockObserver: OperationObserver {
    // MARK: Properties
    
    private let startHandler: ((Operation1) -> Void)?
    private let produceHandler: ((Operation1, Operation) -> Void)?
    private let finishHandler: ((Operation1, [NSError]) -> Void)?
    
    init(startHandler: ((Operation1) -> Void)? = nil, produceHandler: ((Operation1, Operation) -> Void)? = nil, finishHandler: ((Operation1, [NSError]) -> Void)? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: OperationObserver
    
    func operationDidStart(operation: Operation1) {
        startHandler?(operation)
    }
    
    func operation(operation: Operation1, didProduceOperation newOperation: Operation) {
        produceHandler?(operation, newOperation)
    }
    
    func operationDidFinish(operation: Operation1, errors: [NSError]) {
        finishHandler?(operation, errors)
    }
}
