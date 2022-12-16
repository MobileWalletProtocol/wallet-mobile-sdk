import Flutter
import UIKit
import CoinbaseWalletSDK

// TODO: rename to MWPClientFlutterPlugin
public class SwiftCoinbaseWalletSdkFlutterPlugin: NSObject, FlutterPlugin {
    private static let success = "{ \"success\": true}"
    
    private var mwpClient: MWPClient? = nil
    
    public override init() {}
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "coinbase_wallet_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftCoinbaseWalletSdkFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            switch call.method {
            case "static_configure":
                return try configure(call.arguments, result: result)
            case "static_getWallets":
                return try getWallets(result: result)
            
            case "initiateHandshake":
                return try initiateHandshake(call.arguments, result: result)
            case "makeRequest":
                return try makeRequest(call.arguments, result: result)
            case "resetSession":
                return try resetSession(call.arguments, result: result)
            
            default:
                result(FlutterMethodNotImplemented)
                return
            }
        } catch {
            result(FlutterError(code: call.method, message: error.localizedDescription, details: nil))
        }
    }
    
    enum HandleMethodCallError: Swift.Error {
        case invalidArgumentFormat
        case noMWPClient
        case missingArgument
    }
    
    private func configure(_ args: Any?, result: @escaping FlutterResult) throws {
        guard
            let args = args as? [String: Any],
            let callback = args["callback"] as? String,
            let callbackURL = URL(string: callback)
        else {
            throw HandleMethodCallError.invalidArgumentFormat
        }
        MWPClient.configure(callback: callbackURL)
        MobileWalletProtocol.appendVersionTag("flutter")
        
        result(SwiftCoinbaseWalletSdkFlutterPlugin.success)
    }
    
    // MARK: - instance methods
    
    private func decodeArguments<T: Decodable>(_ args: Any?, extraArgType: T.Type) throws -> (Wallet, T?)  {
        guard
            let args = args as? String,
            let jsonData = args.data(using: .utf8)
        else {
            throw HandleMethodCallError.invalidArgumentFormat
        }
        
        let typedArgs = try JSONDecoder().decode(
            InstanceMethodArgument<T>.self,
            from: jsonData
        )
        return (typedArgs.wallet, typedArgs.argument)
    }
    
    private func initiateHandshake(_ args: Any?, result: @escaping FlutterResult) throws {
        let (wallet, actions) = try decodeArguments(args, extraArgType: [Action].self)
        
        guard let client = MWPClient.getInstance(to: wallet) else {
            throw HandleMethodCallError.noMWPClient
        }
        
        client.initiateHandshake(initialActions: actions) { responseResult, account in
            self.handleResponse(
                code: "initiateHandshake",
                responseResult: responseResult,
                account: account,
                result: result
            )
        }
    }
    
    private func makeRequest(_ args: Any?, result: @escaping FlutterResult) throws {
        let (wallet, request) = try decodeArguments(args, extraArgType: Request.self)
        
        guard let client = MWPClient.getInstance(to: wallet) else {
            throw HandleMethodCallError.noMWPClient
        }
        
        guard let request = request else {
            throw HandleMethodCallError.missingArgument
        }
        
        client.makeRequest(request) { responseResult in
            self.handleResponse(
                code: "makeRequest",
                responseResult: responseResult,
                account: nil,
                result: result
            )
        }
    }
    
    private func resetSession(_ args: Any?, result: @escaping FlutterResult) throws {
        let (wallet, _) = try decodeArguments(args, extraArgType: NoArgument.self)
        
        guard let client = MWPClient.getInstance(to: wallet) else {
            throw HandleMethodCallError.noMWPClient
        }
        
        let responseResult = client.resetSession()
        
        switch responseResult {
        case .success:
            result(SwiftCoinbaseWalletSdkFlutterPlugin.success)
        case .failure(let error):
            result(FlutterError(code: "resetSession", message: error.localizedDescription, details: nil))
        }
    }
    
    private func handleResponse(
        code: String,
        responseResult: ResponseResult,
        account: Account?,
        result: @escaping FlutterResult
    ) {
        do {
            switch responseResult {
            case .success(let returnValues):
                var toFlutter = [[String: Any]]()
                
                returnValues.content.forEach { it in
                    var response = [String: Any]()
                    
                    if let account = account {
                        response["account"] = [
                            "chain": account.chain,
                            "networkId": account.networkId,
                            "address": account.address
                        ]
                    }
                    switch it {
                    case .success(let value):
                        response["result"] = value.rawValue
                    case .failure(let error):
                        response["error"] = ["code": error.code, "message": error.message]
                    }
                    
                    toFlutter.append(response)
                }
                
                let data = try JSONSerialization.data(withJSONObject: toFlutter, options: [])
                let jsonString = String(data: data, encoding: .utf8)!
                
                result(jsonString)
            case .failure(let error):
                result(FlutterError(code: code, message: error.localizedDescription, details: nil))
            }
        } catch {
            result(FlutterError(code: code, message: error.localizedDescription, details: nil))
        }
    }
    
    private func getWallets(result: @escaping FlutterResult) throws {
        let dictArray = try Wallet.defaultWallets().map { wallet in
            var dictionary = try JSONSerialization.jsonObject(
                with: try JSONEncoder().encode(wallet),
                options: .allowFragments
            ) as! [String: Any]
            dictionary["isInstalled"] = wallet.isInstalled
            return dictionary
        }
        let encodedData = try JSONSerialization.data(withJSONObject: dictArray)
        let jsonString = String(data: encodedData, encoding: .utf8)
        result(jsonString)
    }
}
