//
//  TaskManager.swift
//  MobileWalletProtocol
//
//  Created by Jungho Bang on 6/9/22.
//

import Foundation

@available(iOS 13.0, *)
class TaskManager {
    private static var tasks = [UUID: Task]()
    
    static func registerResponseHandler(
        for request: RequestMessage,
        host: URL,
        _ handler: @escaping ResponseHandler
    ) {
        let uuid = request.uuid
        tasks[uuid] = Task(
            request: request,
            host: host,
            handler: handler,
            timestamp: Date()
        )
    }
    
    @discardableResult static func runResponseHandler(with response: ResponseMessage) -> Bool {
        let requestId = response.content.requestId
 
        guard let task = tasks[requestId] else {
            return false
        }
        
        task.handler(response.result)
        tasks.removeValue(forKey: requestId)
        return true
    }
    
    static func findTask(for requestId: UUID) -> Task? {
        return tasks[requestId]
    }
    
    static func reset(host: URL) {
        tasks = tasks.filter { $0.value.host != host }
    }
    
}
