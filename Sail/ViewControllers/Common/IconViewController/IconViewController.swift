//
//  IconViewController.swift
//  Sail
//
//  Created by user on 2019/08/31.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Mew
import SeaAPI
import Nuke

class IconViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = SeaUser
    typealias Environment = Void
    let environment: Environment
    var input: Input
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        label.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.25)
        self.input(input)
    }
    
    func input(_ input: Input) {
        if let file = input.avatarFile, let variant = file.variants.first {
            imageView.image = nil
            Nuke.loadImage(with: variant.url, into: imageView)
            imageView.isHidden = false
            label.isHidden = true
        } else {
            label.text = input.name.first.map { String($0).uppercased() }
            imageView.isHidden = true
            label.isHidden = false
        }
    }
}
