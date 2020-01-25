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
import SafariServices

class CompactPostViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = SeaPost
    typealias Environment = SeaAccountToken
    let environment: Environment
    var input: Input
    
    let content = CompactPostView()
    
    let iconViewController: IconViewController
    
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
        view.addSubview(content)
        content.snp.makeConstraints { make in
            make.center.size.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
        content.iconContainerView.addArrangedViewController(iconViewController, parentViewController: self)
//        textView.textContainerInset = .zero
//        textView.textContainer.lineFragmentPadding = 0
        content.tapImageCallback = { [weak self] file in
            guard let strongSelf = self else { return }
            guard let variant = file.variants.filter({ $0.mime != "image/webp" }).first else { return }
            let safariVC = SFSafariViewController(url: variant.url)
            strongSelf.present(safariVC, animated: true, completion: nil)
        }
        self.input(input)
    }
    
    func input(_ input: Input) {
        iconViewController.input(input.user)
        content.nameLabel.text = input.user.name
        content.textView.text = input.text
        content.screenNameLabel.text = "@\(input.user.screenName)"
        content.viaLabel.text = "via \(input.application.name)"
        content.botFlagLabel.isHidden = !input.application.isAutomated
        content.files = input.files
    }
}
