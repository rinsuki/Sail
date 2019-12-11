//
//  ModalNavigationViewController.swift
//  Sail
//
//  Created by user on 2019/11/16.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit

class ModalNavigationViewController: UINavigationController {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        rootViewController.navigationItem.leftBarButtonItems = [
            .init(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }

}
