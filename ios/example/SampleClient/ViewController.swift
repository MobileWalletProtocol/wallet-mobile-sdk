//
//  ViewController.swift
//  SampleWeb3App
//
//  Created by Jungho Bang on 6/27/22.
//

import UIKit
import CoinbaseWalletSDK

class ViewController: UITableViewController {
    
    @IBOutlet weak var isCBWalletInstalledLabel: UILabel!
    @IBOutlet weak var isConnectedLabel: UILabel!
    @IBOutlet weak var ownPubKeyLabel: UILabel!
    @IBOutlet weak var peerPubKeyLabel: UILabel!
    
    @IBOutlet weak var logTextView: UITextView!
    let walletProvider: MobileWalletProviderProtocol = MobileWalletProvider()
    private var wallets: [Wallet] = []
    private var addressMap: [String: String] = [:]
    private let typedData = [
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isCBWalletInstalledLabel.text = "\(CoinbaseWalletSDK.isCoinbaseWalletInstalled())"
        updateSessionStatus()
        
        self.wallets = walletProvider.getWallets()
    }
    
    @IBAction func initiateHandshake() {
        let actions = wallets.map { wallet in
            UIAlertAction(title: wallet.name, style: .default) { (action) in
                self.handhsake(wallet: wallet)
            }
        }
        
        showAlert(actions: actions, title: "Connect Wallet - Handshake")
    }
    
    func handhsake(wallet: Wallet) {
        guard let sdkClient = CoinbaseWalletSDK.getInstance(hostWallet: wallet) else {
            assertionFailure("`CoinbaseWalletSDK.instance`could not be found.")
            return
        }
        sdkClient.initiateHandshake(
            initialActions: [
                Action(jsonRpc: .eth_requestAccounts)
            ]
        ) { result, account in
            switch result {
            case .success(let response):
                self.log("Response: \(response.content)")
                
                guard let account = account else { return }
                self.logObject(label: "Account:\n", account)
                self.addressMap[wallet.url] = account.address
                
            case .failure(let error):
                self.log("\(error)")
            }
            self.updateSessionStatus()
        }
    }
    
    @IBAction func resetConnection() {
        let actions = wallets.map { wallet in
            UIAlertAction(title: wallet.name, style: .default) { (action) in
                self.resetConnection(wallet: wallet)
            }
        }
        showAlert(actions: actions, title: "Reset Wallet Connection")
    }
    
    func resetConnection(wallet: Wallet) {
        self.addressMap[wallet.url] = nil
        guard let sdkClient = CoinbaseWalletSDK.getInstance(hostWallet: wallet) else {
            assertionFailure("`CoinbaseWalletSDK.instance`could not be found.")
            return
        }
        let result = sdkClient.resetSession()
        self.log("\(result)")
        
        updateSessionStatus()
    }
    
    @IBAction func makeRequest() {
        let actions = wallets.map { wallet in
            UIAlertAction(title: wallet.name, style: .default) { (action) in
                self.request(wallet: wallet)
            }
        }
        showAlert(actions: actions, title: "Connect Wallet - Request")
    }
    
    func request(wallet: Wallet) {
        let address = self.addressMap[wallet.url] ?? ""
        if address.isEmpty {
            self.log("address hasn't been set.")
        }
        guard let sdkClient = CoinbaseWalletSDK.getInstance(hostWallet: wallet) else {
            assertionFailure("`CoinbaseWalletSDK.instance`could not be found.")
            return
        }
        sdkClient.makeRequest(
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
        var isConnected = false
        self.isConnectedLabel.textColor = .red
        self.isConnectedLabel.text = "\(isConnected)"
        self.ownPubKeyLabel.text = ""
        self.peerPubKeyLabel.text = ""
        
        guard let (client, name) = wallets.compactMap({
            let sdkClient = CoinbaseWalletSDK.getInstance(hostWallet: $0)
            return sdkClient?.isConnected() == true ? (sdkClient, $0.name) : nil
        }).first else {
            return
        }
        
        isConnected = client?.isConnected() ?? false
        self.isConnectedLabel.textColor = isConnected ? .green : .red
        self.isConnectedLabel.text = "\(isConnected) \(name)"
        
        self.ownPubKeyLabel.text = client?.ownPublicKey.rawRepresentation.base64EncodedString()
        self.peerPubKeyLabel.text = client?.peerPublicKey?.rawRepresentation.base64EncodedString() ?? "(nil)"
    }
    
    func showAlert(actions: [UIAlertAction], title: String) {
        let alert = UIAlertController(title: title,
                                      message: "Select a wallet",
                                      preferredStyle: .actionSheet)
        actions.forEach { action in
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
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
    
    func logURL(_ url: URL?, function: String = #function) {
        guard let url = url else { return }
        self.log("URL: \(url)", function: function)
    }
    
    private func log(_ text: String, function: String = #function) {
        DispatchQueue.main.async {
            self.logTextView.text = "\(function): \(text)\n\n\(self.logTextView.text ?? "")"
            //  self.logTextView.text += "\(function): \(text)\n\n"
            //  self.logTextView.scrollRangeToVisible(NSMakeRange(self.logTextView.text.count - 1, 1))
        }
    }
}

