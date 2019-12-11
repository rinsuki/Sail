//
//  AuthClient.swift
//  Sail
//
//  Created by user on 2019/09/04.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation
import SeaAPI

fileprivate func getAuthClient() -> Dictionary<String, SeaClientCredential> {
    let data = try! Data(contentsOf: Bundle.main.url(forResource: "AuthClient", withExtension: "plist")!)
    return try! PropertyListDecoder().decode(Dictionary<String, SeaClientCredential>.self, from: data)
}

let AuthClient = getAuthClient()
