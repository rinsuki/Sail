//
//  NewPostViewController.swift
//  Sail
//
//  Created by user on 2019/12/11.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Mew
import SailCore
import Ikemen
import SnapKit
import SeaAPI

class NewPostViewController: UIViewController, Instantiatable, Injectable {
    typealias Input = Void
    typealias Environment = SeaAccountToken
    let environment: Environment
    var input: Input
    
    let textView = UITextView() ※ { v in
        v.font = .preferredFont(forTextStyle: .body)
    }
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.input(input)
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.center.size.equalToSuperview()
        }
        
        title = "New Post"
        
        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "paperplane"), style: .plain, target: self, action: #selector(send))
        
        textView.becomeFirstResponder()
    }
    
    func input(_ input: Input) {
    }
    
    @objc func send() {
        let text = textView.text ?? ""
        let alert = UIAlertController(title: "送信中", message: "しばらくお待ちください", preferredStyle: .alert)
        let request = environment.userCredential.request(r: SeaAPI.CreatePost(text: text)) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    alert.dismiss(animated: true)
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    alert.title = "エラー"
                    alert.message = "エラーが起きました \n\n\(error)"
                    alert.addAction(.init(title: "Close", style: .cancel, handler: nil))
                }
            }
        }
        present(alert, animated: true) { request.resume() }
    }
}
