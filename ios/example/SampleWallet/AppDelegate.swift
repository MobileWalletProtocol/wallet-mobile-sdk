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
    
    private var ownPrivateKey: PrivateKey?
    private var peerPublicKey: PublicKey?
    private var requestMessage: RequestMessage?
    private var peerCallback: URL?
}

extension AppDelegate: UIAlertViewDelegate {
    typealias AlertView = UIAlertView
    
    private var symmetricKey: SymmetricKey? {
        guard let o = ownPrivateKey, let p = peerPublicKey else {
            return nil
        }
        
        return try? MWPHost.deriveSymmetricKey(with: o, p)
    }
    
    func handleWalletSegue(url: URL) {
        guard let request: RequestMessage = try? MWPHost.decode(url, with: symmetricKey) else { return }
        
        self.requestMessage = request
        if case .handshake(_, let callback, _, _, _) = request.content {
            self.peerCallback = callback
        }
        
        let alert = AlertView(
            title: "Request",
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
        let sender: PublicKey
        if buttonIndex == 0 { // cancel
            content = .failure(
                requestId: requestMessage.uuid,
                description: "Request denied"
            )
            sender = self.peerPublicKey ?? requestMessage.sender
        } else {
            let returnValues: [ResponseContent.Value]
            switch requestMessage.content {
            case .handshake:
                self.peerPublicKey = requestMessage.sender
                self.ownPrivateKey = PrivateKey()
                let account = Account(chain: "eth", networkId: 0, address: "0x571a6a108adb08f9ca54fe8605280F9EE0eD4AF6")
                returnValues = [
                    .result(value: JSONString(encode: account)!)
                ]
            case let .request(actions, _):
                let error: ResponseContent.Value = .error(code: 713, message: "New CBWallet app will be able to actually handle those requests")
                returnValues = actions.map({ _ in error })
            }
            
            content = .response(
                requestId: requestMessage.uuid,
                values: returnValues
            )
            sender = self.ownPrivateKey!.publicKey
        }
        
        let response = ResponseMessage(
            sender: sender,
            content: content
        )
        
        let url = try! MWPHost.encode(
            response,
            to: peerCallback!,
            with: symmetricKey
        )
        
        UIApplication.shared.open(url)
    }
}
