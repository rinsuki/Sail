//
//  TopViewController.swift
//  Sail
//
//  Created by user on 2019/11/16.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit

class TopViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewControllers = [
            UINavigationController(rootViewController: TopLeftTableViewController()),
        ]
        preferredDisplayMode = .allVisible
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
