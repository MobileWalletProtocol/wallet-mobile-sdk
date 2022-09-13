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
    
    // MARK: - Constructor
    
    static private var host: URL?
    static private var callback: URL?
    static public var isConfigured: Bool {
        return host != nil && callback != nil
    }
    
    static public func configure(
        host: URL = URL(string: "https://wallet.coinbase.com/wsegue")!,
        callback: URL
    ) {
        guard isConfigured == false else {
            assertionFailure("`CoinbaseWalletSDK.configure` should be called only once.")
            return
        }
        
        self.host = host
        if callback.pathComponents.count < 2 { // [] or ["/"]
            self.callback = callback.appendingPathComponent("wsegue")
        } else {
            self.callback = callback
        }
    }
    
    static public var shared: CoinbaseWalletSDK = {
        guard let host = CoinbaseWalletSDK.host,
              let callback = CoinbaseWalletSDK.callback else {
            preconditionFailure("Missing configuration: call `CoinbaseWalletSDK.configure` before accessing the `shared` instance.")
        }
        
        return CoinbaseWalletSDK(host: host, callback: callback)
    }()
    
    // MARK: - Properties
    
    private let appId: String
    private let host: URL
    private let callback: URL
    
    private lazy var keyManager: KeyManager = {
        KeyManager(host: self.host)
    }()
    private lazy var taskManager: TaskManager = {
        TaskManager()
    }()
    
    private init(
        host: URL,
        callback: URL
    ) {
        self.host = host
        self.callback = callback
        
        self.appId = Bundle.main.bundleIdentifier!
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
            callbackUrl: callback.absoluteString
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
            callbackUrl: callback.absoluteString
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
            
            self.taskManager.registerResponseHandler(for: request, onResponse)
        }
    }
    
    // MARK: - Receive message
    
    private func isWalletSegueMessage(_ url: URL) -> Bool {
        return url.host == callback.host && url.path == callback.path
    }

    /// Handle incoming deep links
    /// - Parameter url: deep link url
    /// - Returns: `false` if the input was not response message type, `true` if SDK handled the input, or throws error if it failed to decode response.
    @discardableResult
    public func handleResponse(_ url: URL) throws -> Bool {
        guard isWalletSegueMessage(url) else {
            return false
        }
        
        let response = try decodeResponse(url)
        taskManager.runResponseHandler(with: response)
        return true
    }
    
    private func decodeResponse(_ url: URL) throws -> ResponseMessage {
        if let symmetricKey = keyManager.symmetricKey {
            return try MessageConverter.decode(url, with: symmetricKey)
        }
        
        // no symmetric key yet
        let encryptedResponse: EncryptedResponseMessage = try MessageConverter.decodeWithoutDecryption(url)
        let request = taskManager.findRequest(for: encryptedResponse)
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
            taskManager.reset()
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
