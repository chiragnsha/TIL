/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

#if os(iOS)

import UIKit
    
private let RemoteNotificationQueue = OperationQueue()
private let RemoteNotificationName = "RemoteNotificationPermissionNotification"

public enum RemoteRegistrationResult {
    case Token(NSData)
    case Error(NSError)
}

/// A condition for verifying that the app has the ability to receive push notifications.
struct RemoteNotificationCondition: OperationCondition {
    func dependencyForOperation(operation: Operation1) -> Operation? {
        return RemoteNotificationPermissionOperation.init(application: application) { (_) in
            
        }
    }
    
    static let name = "RemoteNotification"
    static let isMutuallyExclusive = false
    
    static func didReceiveNotificationToken(token: NSData) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RemoteNotificationName), object: nil, userInfo: [
            "token": token
        ])
    }
    
    static func didFailToRegister(error: NSError) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RemoteNotificationName), object: nil, userInfo: [
            "error": error
        ])
    }
    
    let application: UIApplication
    
    init(application: UIApplication) {
        self.application = application
    }
    
    func dependencyForOperation(operation: Operation1) -> Operation1? {
        return RemoteNotificationPermissionOperation(application: application, handler: { (_) in })
    }
    
    func evaluateForOperation(operation: Operation1, completion: @escaping (OperationConditionResult) -> Void) {
        /*
            Since evaluation requires executing an operation, use a private operation
            queue.
        */
       
        RemoteNotificationQueue.addOperation(RemoteNotificationPermissionOperation.init(application: application, handler: { (result) in
            switch result {
                case .Token(_):
                    completion(.Satisfied)

                case .Error(let underlyingError):
                    let error = NSError(code: .ConditionFailed, userInfo: [
                        OperationConditionKey: type(of: self).name,
                        NSUnderlyingErrorKey: underlyingError
                    ])

                    completion(.Failed(error))
            }
            
        }))
        
//        RemoteNotificationQueue.addOperation(RemoteNotificationPermissionOperation(application: application) { result in
//            switch result {
//                case .Token(_):
//                    completion(.Satisfied)
//
//                case .Error(let underlyingError):
//                    let error = NSError(code: .ConditionFailed, userInfo: [
//                        OperationConditionKey: type(of: self).name,
//                        NSUnderlyingErrorKey: underlyingError
//                    ])
//
//                    completion(.Failed(error))
//            }
//        })
    }
}

/**
    A private `Operation` to request a push notification token from the `UIApplication`.
    
    - note: This operation is used for *both* the generated dependency **and**
        condition evaluation, since there is no "easy" way to retrieve the push
        notification token other than to ask for it.

    - note: This operation requires you to call either `RemoteNotificationCondition.didReceiveNotificationToken(_:)` or
        `RemoteNotificationCondition.didFailToRegister(_:)` in the appropriate
        `UIApplicationDelegate` method, as shown in the `AppDelegate.swift` file.
*/
public class RemoteNotificationPermissionOperation: Operation1 {
    let application: UIApplication
    
    public let handler: (RemoteRegistrationResult) -> Void
    
    public init(application: UIApplication, handler: @escaping (RemoteRegistrationResult)  -> Void) {
        self.application = application
        self.handler = handler

        super.init()
        
        /*
            This operation cannot run at the same time as any other remote notification
            permission operation.
        */
        
        addCondition(condition: MutuallyExclusive<RemoteNotificationPermissionOperation>())
    }
    
    override func execute() {
        DispatchQueue.main.async {
            let notificationCenter = NotificationCenter.default
            
            notificationCenter.addObserver(self, selector: #selector(RemoteNotificationPermissionOperation.didReceiveResponse(_:)), name: NSNotification.Name(rawValue: RemoteNotificationName), object: nil)
            
            self.application.registerForRemoteNotifications()
        }
    }
    
    @objc func didReceiveResponse(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self)
        
        let userInfo = notification.userInfo

        if let token = userInfo?["token"] as? NSData {
            handler(.Token(token))
        }
        else if let error = userInfo?["error"] as? NSError {
            handler(.Error(error))
        }
        else {
            fatalError("Received a notification without a token and without an error.")
        }

        finish()
    }
}
    
#endif
