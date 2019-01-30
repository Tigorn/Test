//
//  DatabaseService.swift
//  Reader
//
//  Created by Igor Trukhin on 30/01/2019.
//  Copyright © 2019 Igor Trukhin. All rights reserved.
//

import GRDB

typealias SQL = String

final class DatabaseService {
    
    private var dbQueue: DatabaseQueue
    
    init?() {
        var configuration = Configuration()
        configuration.readonly = true
        configuration.foreignKeysEnabled = true
        
        do {
            let databaseURL = try FileManager.default
                .url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("metadata.db")
            self.dbQueue = try DatabaseQueue(path: databaseURL.path, configuration: configuration)
        } catch let err {
            return nil
        }
    }
    
    enum DatabaseServiceError: Error {
        case fetchAllFailure(error: Error)
    }
    
}

extension DatabaseService: DatabaseServiceProtocol {
    
    func fetchAll<T>(_ type: T.Type, sql: SQL) throws -> [T] where T: FetchableRecord {
        do {
            let items = try dbQueue.read { db in
                try T.fetchAll(db, sql)
            }
            return items
        } catch let error {
            throw DatabaseServiceError.fetchAllFailure(error: error)
        }
    }
    
}
