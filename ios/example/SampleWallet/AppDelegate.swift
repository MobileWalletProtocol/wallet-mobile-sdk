//
//  AppDelegate.swift
//  SampleWallet
//
//  Created by Jungho Bang on 7/1/22.
//

import UIKit
import CoinbaseWalletSDK
import CryptoKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        handleWalletSegue(url: url)
        return true
    }
    
    #warning("not persisted")
    private var ownPrivateKey: CoinbaseWalletSDK.PrivateKey?
    private var peerPublicKey: CoinbaseWalletSDK.PublicKey?
    private var requestMessage: RequestMessage?
    private var peerCallback: URL?
}

extension AppDelegate: UIAlertViewDelegate {
    typealias AlertView = UIAlertView
    
    private var symmetricKey: SymmetricKey? {
        guard let o = ownPrivateKey, let p = peerPublicKey else {
            return nil
        }
        
        return try? Cipher.deriveSymmetricKey(with: o, p)
    }
    
    func handleWalletSegue(url: URL) {
        guard let request: RequestMessage = try? MessageConverter.decode(url, with: symmetricKey) else { return }
        
        self.requestMessage = request
        if case .handshake(_, let callback, _) = request.content {
            self.peerCallback = callback
        }
        
        let alert = AlertView(
            title: "WalletSegue Request",
            message: "decrypted content: \(request.content)",
            delegate: self,
            cancelButtonTitle: "Deny",
            otherButtonTitles: "Confirm"
        )
        alert.show()
    }
    
    func alertView(_ alertView: AlertView, clickedButtonAt buttonIndex: Int) {
        guard let requestMessage = requestMessage else { preconditionFailure() }
        
        let content: ResponseContent
        let sender: CoinbaseWalletSDK.PublicKey
        if buttonIndex == 0 { // failure
            content = .failure(
                requestId: requestMessage.uuid,
                description: "Request denied"
            )
            sender = self.peerPublicKey ?? requestMessage.sender
        } else {
            let returnValues: [ReturnValue]
            switch requestMessage.content {
            case let .handshake(appId, callback, initialActions):
                self.peerPublicKey = requestMessage.sender
                self.ownPrivateKey = CoinbaseWalletSDK.PrivateKey()
                returnValues = [
                    .result(value: "0x571a6a108adb08f9ca54fe8605280F9EE0eD4AF6")
                ]
            case let .request(actions, account):
                let error = ReturnValue.error(code: 713, message: "New CBWallet app will be able to actually handle those requests")
                returnValues = actions.map({ _ in error })
            }
            
            content = .response(
                requestId: requestMessage.uuid,
                values: returnValues
            )
            sender = self.ownPrivateKey!.publicKey
        }
        
        let response = ResponseMessage(
            uuid: UUID(),
            sender: sender,
            content: content,
            version: "0.0.0",
            timestamp: Date()
        )
        
        let url = try! MessageConverter.encode(
            response,
            to: peerCallback!,
            with: symmetricKey
        )
        
        UIApplication.shared.open(url)
    }
}
