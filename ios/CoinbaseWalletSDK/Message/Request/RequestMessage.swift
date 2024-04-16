//
//  RequestMessage.swift
//  MobileWalletProtocol
//
//  Created by Jungho Bang on 6/9/22.
//

import Foundation

public enum RequestContent: UnencryptedContent {
    case handshake(appId: String, callback: URL, name: String?, iconUrl: URL?, initialActions: [Action]?)
    case request(actions: [Action], account: Account? = nil)
}

public typealias RequestMessage = Message<RequestContent>
