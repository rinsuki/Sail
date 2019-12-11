//
//  CompactPostViewController.swift
//  Sail
//
//  Created by user on 2019/08/30.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Mew
import SeaAPI
import Nuke
import Mew
import SailCore

class CompactPostViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = SeaPost
    typealias Environment = SeaAccountToken
    let environment: Environment
    var input: Input
    
    var iconViewController: IconViewController
    @IBOutlet weak var iconContainerView: ContainerView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var viaAppLabel: UILabel!
    @IBOutlet weak var botLabel: UILabel!
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        iconViewController = .instantiate(input.user, environment: ())
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        iconContainerView.addArrangedViewController(iconViewController, parentViewController: self)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        self.input(input)
    }
    
    func input(_ input: Input) {
        iconViewController.input(input.user)
        nameLabel.text = input.user.name
        textView.text = input.text
        screenNameLabel.text = "@\(input.user.screenName)"
        viaAppLabel.text = "via \(input.application.name)"
        botLabel.isHidden = !input.application.isAutomated
    }
}
