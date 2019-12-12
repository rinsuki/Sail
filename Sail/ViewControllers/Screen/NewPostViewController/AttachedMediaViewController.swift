//
//  AttachedMediaViewController.swift
//  Sail
//
//  Created by user on 2019/12/13.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Mew
import Ikemen
import Nuke

class AttachedMediaViewController: UIViewController, Instantiatable, Injectable, Interactable {
    typealias Input = URL
    typealias Environment = Any
    typealias Output = Void
    let environment: Environment
    var input: Input
    var handler: ((Output) -> ())?
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.input(input)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.center.size.equalToSuperview()
        }
    }
    
    func input(_ input: Input) {
        Nuke.loadImage(with: input, into: imageView)
    }
    
    func output(_ handler: ((Output) -> Void)?) {
        self.handler = handler
    }
}
