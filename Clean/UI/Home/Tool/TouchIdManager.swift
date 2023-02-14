//
//  TouchIdManager.swift
//  Clean
//
//  Created by liqi on 2020/11/3.
//

import Foundation
import LocalAuthentication

class TouchIdManager {
    
    static var isCanUseTouchIdOrFaceId: (Bool, LAContext) {
        let context = LAContext()
        let can = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return (can, context)
    }
    
    class func auth(completion: @escaping (Bool)->()) {
        let context = LAContext()
        let touchAuthenticationReason = "用于打开私密空间"
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: touchAuthenticationReason) { (success, error) in
                DispatchQueue.main.async {
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        } else {
            completion(true)
        }
    }
    
}
