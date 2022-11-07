//
//  CoinbaseWalletSDK.swift
//  WalletSegue
//
//  Created by Jungho Bang on 5/20/22.
//

import Foundation
import CryptoKit
import UIKit

@available(iOS 13.0, *)
public final class CoinbaseWalletSDK {
    
    static public func isCoinbaseWalletInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "cbwallet://")!)
    }
    
    static public func configure(callback: URL) {
        if callback.pathComponents.count < 2 { // [] or ["/"]
            self.callback = callback.appendingPathComponent("wsegue")
        } else {
            self.callback = callback
        }
    }
    
    static public func getInstance(hostWallet: Wallet) -> CoinbaseWalletSDK? {
        guard callback != nil else {
            assertionFailure("`CoinbaseWalletSDK.configure` should be called prior to retrieving an instance.")
            return nil
        }
        
        let host = URL(string: hostWallet.url)!
        if (instances[host] == nil) {
            let newInstance = CoinbaseWalletSDK(host: host)
            instances[host] = newInstance
        }

        return instances[host]!
    }

    private static var instances: [URL: CoinbaseWalletSDK] = [:]// host url -> instance
    // MARK: - Properties
    
    private let appId: String
    private let host: URL
    static private var callback: URL?
    
    private lazy var keyManager: KeyManager = {
        KeyManager(host: self.host)
    }()
    
    private init(host: URL) {
        self.host = host
        
        self.appId = Bundle.main.bundleIdentifier!

        CoinbaseWalletSDK.instances[host] = self
    }

    deinit {
        CoinbaseWalletSDK.instances.removeValue(forKey: self.host)
    }
    
    // MARK: - Send message
    
    /// Make handshake request to get session key from wallet
    /// - Parameters:
    ///   - initialActions: Batch of actions that you'd want to execute after successful handshake. `eth_requestAccounts` by default.
    ///   - onResponse: Response callback with regular response result and optional parsed `Account` object.
    public func initiateHandshake(
        initialActions: [Action]? = [Action(jsonRpc: .eth_requestAccounts)],
        onResponse: @escaping (ResponseResult, Account?) -> Void
    ) {
        let hasUnsupportedAction = initialActions?.contains(where: {
            let action = $0
            return unsupportedHandShakeMethod.contains(where: {action.method == $0 })
        })
        
        guard hasUnsupportedAction != true else {
            onResponse(.failure(Error.invalidHandshakeRequest), nil)
            return
        }
        
        guard let callback = CoinbaseWalletSDK.callback else {
            assertionFailure("`CoinbaseWalletSDK.configure` should be called prior to retrieving an instance.")
            return
        }
        
        try? keyManager.resetOwnPrivateKey()
        let message = RequestMessage(
            uuid: UUID(),
            sender: keyManager.ownPublicKey,
            content: .handshake(
                appId: appId,
                callback: callback,
                initialActions: initialActions
            ),
            version: CoinbaseWalletSDK.version,
            timestamp: Date(),
            callbackUrl: CoinbaseWalletSDK.callback!.absoluteString
        )
        self.send(message) { result in
            guard
                let requestAccountsIndex = initialActions?.firstIndex(where: { $0.method == "eth_requestAccounts" }),
                let content = try? result.get().content,
                content.indices.contains(requestAccountsIndex),
                case .success(let accountJson) = content[requestAccountsIndex],
                let account = try? accountJson.decode(as: Account.self)
            else {
                onResponse(result, nil)
                return
            }
            
            onResponse(result, account)
        }
    }
    
    /// Make regular requests. It requires session key you get after successful handshake.
    public func makeRequest(_ request: Request, onResponse: @escaping ResponseHandler) {
        let message = RequestMessage(
            uuid: UUID(),
            sender: keyManager.ownPublicKey,
            content: .request(actions: request.actions, account: request.account),
            version: CoinbaseWalletSDK.version,
            timestamp: Date(),
            callbackUrl: CoinbaseWalletSDK.callback!.absoluteString
        )
        return self.send(message, onResponse)
    }
    
    private func send(_ request: RequestMessage, _ onResponse: @escaping ResponseHandler) {
        let url: URL
        do {
            url = try MessageConverter.encode(request, to: host, with: keyManager.symmetricKey)
        } catch {
            onResponse(.failure(error))
            return
        }
        
        UIApplication.shared.open(
            url,
            options: [.universalLinksOnly: url.isHttp]
        ) { result in
            guard result == true else {
                onResponse(.failure(Error.openUrlFailed))
                return
            }
            
            TaskManager.registerResponseHandler(for: request, host: self.host, onResponse)
        }
    }
    
    // MARK: - Receive message
    
    static private func isWalletSegueMessage(_ url: URL) -> Bool {
        return url.host == CoinbaseWalletSDK.callback!.host && url.path == CoinbaseWalletSDK.callback!.path
    }

    /// Handle incoming deep links
    /// - Parameter url: deep link url
    /// - Returns: `false` if the input was not response message type, `true` if SDK handled the input, or throws error if it failed to decode response.
    @discardableResult
    static public func handleResponse(_ url: URL) throws -> Bool {
        guard isWalletSegueMessage(url) else {
            return false
        }
        
        let encryptedResponse: EncryptedResponseMessage = try MessageConverter.decodeWithoutDecryption(url)
        let request = TaskManager.getHost(for: encryptedResponse)
        guard let instance = instances[request!] else {
            throw Error.walletInstanceNotFound
        }

        let response = try instance.decodeResponse(url, encryptedResponse)
        TaskManager.runResponseHandler(with: response)
        return true
    }
    
    private func decodeResponse(_ url: URL,_ encryptedResponse: EncryptedResponseMessage) throws -> ResponseMessage {
        if let symmetricKey = keyManager.symmetricKey {
            return try MessageConverter.decode(url, with: symmetricKey)
        }
        
        // no symmetric key yet
        let request = TaskManager.findRequest(for: encryptedResponse)
        guard case .handshake = request?.content else {
            throw Error.missingSymmetricKey
        }
        
        try handleHandshakeResponse(encryptedResponse)
        
        return try encryptedResponse.decrypt(with: keyManager.symmetricKey)
    }
    
    // MARK: - Session
    
    public func isConnected() -> Bool {
        return keyManager.symmetricKey != nil
    }
    
    public var ownPublicKey: PublicKey {
        return keyManager.ownPublicKey
    }
    
    public var peerPublicKey: PublicKey? {
        return keyManager.peerPublicKey
    }
    
    @discardableResult
    public func resetSession() -> Result<Void, Swift.Error> {
        do {
            TaskManager.reset(host: host)
            try keyManager.resetOwnPrivateKey()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    private func handleHandshakeResponse(_ response: EncryptedResponseMessage) throws {
        if case .failure = response.content {
            return
        }
        
        try keyManager.storePeerPublicKey(response.sender)
    }
}
