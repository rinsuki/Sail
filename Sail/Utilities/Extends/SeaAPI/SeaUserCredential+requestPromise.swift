//
//  SeaUserCredential+requestPromise.swift
//  Sail
//
//  Created by user on 2019/12/13.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation
import Hydra
import SeaAPI

extension SeaUserCredential {
    func requestPromise<Endpoint: SeaAPIEndpoint>(r: Endpoint) -> Promise<Endpoint.Response> where Endpoint.Response: Decodable {
        return Promise { resolve, reject, status in
            let task = self.request(r: r) { result in
                switch result {
                case .success(let res):
                    resolve(res)
                case .failure(let error):
                    reject(error)
                }
            }
            task.resume()
        }
    }
}
