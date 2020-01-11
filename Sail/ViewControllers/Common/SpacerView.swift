//
//  SpacerView.swift
//  Sail
//
//  Created by user on 2020/01/12.
//  Copyright © 2020 rinsuki. All rights reserved.
//

import UIKit

class SpacerView: UIView {
    init() {
        super.init(frame: .zero)
        setContentHuggingPriority(.init(0), for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
