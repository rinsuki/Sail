//
//  DatabaseInitializer.swift
//  SailCore
//
//  Created by user on 2019/11/20.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation
import GRDB

func getDatabasePath() -> String {
    let url = AppGroupUrl.appendingPathComponent("database.sqlite")
    let path = url.path
    print(path)
    return path
}

func getDatabase() -> DatabaseQueue {
    let dbQueue = try! DatabaseQueue(path: getDatabasePath())
    var migrator = DatabaseMigrator()
    migrator.registerMigration("v1.AddAccountsTable") { db in
        try db.create(table: "accounts") { t in
            t.column("id", .text).primaryKey()
            t.column("name", .text).notNull()
            t.column("screenName", .text).notNull()
            t.column("host", .text).notNull()
            t.column("createdAt", .datetime).notNull()
        }
    }
    try! migrator.migrate(dbQueue)
    return dbQueue
}

public let dbQueue = getDatabase()
