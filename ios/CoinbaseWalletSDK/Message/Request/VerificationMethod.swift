//
//  VerificationConfig.swift
//  Pods
//
//  Created by Jungho Bang on 2/26/24.
//

import Foundation

/// domain ownership verification
public enum VerificationMethod: Equatable, Codable {
    case callbackConfirmation
    /// Advanced configuration with public key-based domain ownership verification.
    case publicKeyVerification(message: String, signature: String, publicKeySubpath: String?)
}
