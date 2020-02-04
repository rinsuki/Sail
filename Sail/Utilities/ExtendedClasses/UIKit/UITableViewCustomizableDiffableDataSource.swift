//
//  UITableViewCustomizableDiffableDataSource.swift
//  Sail
//
//  Created by user on 2020/01/26.
//  Copyright © 2020 rinsuki. All rights reserved.
//

import UIKit

class UITableViewCustomizableDiffableDataSource<SectionIdentifierType: Hashable, ItemIdentifierType: Hashable>
    : UITableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType> {
    var isEditable: Bool = false
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditable
    }
}
