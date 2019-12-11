//
//  SeaAccountToken.swift
//  SailCore
//
//  Created by user on 2019/11/20.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation
import GRDB
import KeychainAccess
import SeaAPI

private let AccountTokenKeychain = Keychain(service: "net.rinsuki.apps.Sail.sea-token", accessGroup: KeychainGroup)

public struct SeaAccountToken: Codable, MutablePersistableRecord, FetchableRecord {
    public static let databaseTableName = "accounts"
    
    public private(set) var id = UUID()
    public var name: String
    public var screenName: String
    public var host: String
    public var createdAt = Date()
    
    public var token: String? {
        get {
            try! AccountTokenKeychain.get(self.id.description)
        }
        set {
            if let newValue = newValue {
                try! AccountTokenKeychain.set(newValue, key: self.id.description)
            } else {
                try! AccountTokenKeychain.remove(self.id.description)
            }
        }
    }
    
    public var userCredential: SeaUserCredential {
        return .init(baseUrl: URL(string: "https://\(host)")!, token: token!)
    }
    
    public init(id: UUID = .init(), name: String, screenName: String, host: String) {
        self.id = id
        self.name = name
        self.screenName = screenName
        self.host = host
    }
}
