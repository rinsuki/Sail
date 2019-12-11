//
//  UITableViewDiffableDataSource+plainSnapshot.swift
//  Sail
//
//  Created by user on 2019/11/23.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit

extension UITableViewDiffableDataSource {
    var plainSnapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        return .init()
    }
}
