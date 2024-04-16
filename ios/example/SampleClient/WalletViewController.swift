//
//  WalletViewController.swift
//  SampleClient
//
//  Created by Jungho Bang on 6/27/22.
//

import UIKit
import CoinbaseWalletSDK

class WalletViewController: UITableViewController {
    
    @IBOutlet weak var isWalletInstalledLabel: UILabel!
    @IBOutlet weak var isConnectedLabel: UILabel!
    @IBOutlet weak var ownPubKeyLabel: UILabel!
    @IBOutlet weak var peerPubKeyLabel: UILabel!
    @IBOutlet weak var logTextView: UITextView!
    
    var wallet: Wallet!
    private var mwpClient: MWPClient!
    private var address: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let wallet = wallet else { preconditionFailure() }
        
        self.title = wallet.name
        self.mwpClient = MWPClient.getInstance(to: wallet)
        
        isWalletInstalledLabel.text = "\(wallet.isInstalled)"
        updateSessionStatus()
        
        addLogNotificationObserver()
    }
    
    @IBAction func initiateHandshake() {
        mwpClient.initiateHandshake(
            initialActions: [
                Action(jsonRpc: .personal_sign(address: "", message: "message"))
            ]
        ) { result, account in
            self.updateSessionStatus()
            
            switch result {
            case .success(let response):
                self.log("Response: \(response.content)")
                
                guard let account = account else { return }
                self.logObject(label: "Account:\n", account)
                self.address = account.address
                
            case .failure(let error):
                self.log("\(error)")
            }
        }
    }
    
    @IBAction func resetConnection() {
        self.address = nil
        
        let result = mwpClient.resetSession()
        self.log("\(result)")
        
        updateSessionStatus()
    }
    
    @IBAction func makeRequest() {
        let address = self.address ?? ""
        if address.isEmpty {
            self.log("address hasn't been set.")
        }
        
        let typedData = [
            "types": [
                "EIP712Domain": [
                    ["name": "name", "type": "string"],
                    ["name": "version", "type": "string"],
                    ["name": "chainId", "type": "uint256"],
                    ["name": "verifyingContract", "type": "address"],
                    ["name": "salt", "type": "bytes32"],
                ],
                "Bid": [
                    ["name": "amount", "type": "uint256"],
                    ["name": "bidder", "type": "Identity"],
                ],
                "Identity": [
                    ["name": "userId", "type": "uint256"],
                    ["name": "wallet", "type": "address"],
                ],
            ],
            "domain": [
                "name": "DApp Browser Test DApp",
                "version": "1",
                "chainId": 1,
                "verifyingContract": "0x1C56346CD2A2Bf3202F771f50d3D14a367B48070",
                "salt": "0xf2d857f4a3edcb9b78b4d503bfe733db1e3f6cdc2b7971ee739626c97e86a558",
            ],
            "primaryType": "Bid",
            "message": [
                "amount": 100,
                "bidder": [
                    "userId": 323,
                    "wallet": "0x3333333333333333333333333333333333333333"
                ],
            ],
        ] as [String: Any]
        
        mwpClient.makeRequest(
            Request(actions: [
                Action(jsonRpc: .personal_sign(address: address, message: "message")),
                Action(jsonRpc: .eth_signTypedData_v3(
                    address: address,
                    typedDataJson: JSONString(encode: typedData)!
                ))
            ])
        ) { result in
            guard case .success(let response) = result else {
                self.log("error: \(result)")
                return
            }
            
            for returnValue in response.content {
                switch returnValue {
                case .success(let value):
                    self.log("result (raw JSON): \(value)")
                    if let decoded = value.decode() {
                        self.log("result (decoded): \(decoded)")
                    }
                case .failure(let error):
                    self.log("error \(error.code): \(error.message)")
                }
            }
        }
    }
    
    private func updateSessionStatus() {
        DispatchQueue.main.async {
            let isConnected = self.mwpClient.isConnected()
            self.isConnectedLabel.textColor = isConnected ? .green : .red
            self.isConnectedLabel.text = "\(isConnected)"
            
            self.ownPubKeyLabel.text = self.mwpClient.ownPublicKey.rawRepresentation.base64EncodedString()
            self.peerPubKeyLabel.text = self.mwpClient.peerPublicKey?.rawRepresentation.base64EncodedString() ?? "(nil)"
        }
    }
    
    // MARK: - Log
    
    private func addLogNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(logOpenExternalURL),
            name: kOpenExternalURLNotification,
            object: nil
        )
    }
    
    private func logObject<T: Encodable>(label: String = "", _ object: T, function: String = #function) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(object)
            let jsonString = String(data: data, encoding: .utf8)!
            self.log("\(label)\(jsonString)", function: function)
        } catch {
            self.log("\(error)")
        }
    }
    
    @objc func logOpenExternalURL(notification: Notification) {
        guard let url = notification.object as? URL else { return }
        self.log("URL: \(url)")
    }
    
    private func log(_ text: String, function: String = #function) {
        DispatchQueue.main.async {
            self.logTextView.text = "\(function): \(text)\n\n\(self.logTextView.text ?? "")"
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

