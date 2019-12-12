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

class NewPostViewController: UIViewControllerWithToolbar, Instantiatable, Injectable {
    struct Input {
        var text: String?
    }
    typealias Environment = SeaAccountToken
    let environment: Environment
    var input: Input
    
    let textView = UITextView() ※ { v in
        v.font = .preferredFont(forTextStyle: .body)
        v.backgroundColor = .clear
    }
    
    let mediaContainerView = ContainerView()
    
    var isMediaKeyboardMode = false {
        didSet {
            if isMediaKeyboardMode {
                textView.inputView = InputMediaView(viewController: self)
            } else {
                textView.inputView = nil
            }
            textView.reloadInputViews()
        }
    }
    
    let attachedMediaListVC: AttachedMediaListViewController
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        attachedMediaListVC = .instantiate([], environment: environment)
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.input(input)
        
        let stackView = ContainerView() ※ { s in
            s.addArrangedSubview(textView)
            s.addArrangedViewController(attachedMediaListVC, parentViewController: self)
            s.axis = .vertical
            s.backgroundColor = .clear
        }
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.centerX.width.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        textView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        title = "New Post"
        
        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "paperplane"), style: .plain, target: self, action: #selector(send))
        
        toolBar.setItems([
            .init(image: UIImage(systemName: "photo.on.rectangle"), style: .plain, target: self, action: #selector(showPhotoSelector))
        ], animated: false)
        
        view.bringSubviewToFront(toolBar)
        view.backgroundColor = .systemBackground
    }
    
    func input(_ input: Input) {
        textView.text = input.text
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
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
    
    @objc func showPhotoSelector() {
        isMediaKeyboardMode.toggle()
    }
}

extension NewPostViewController: UINavigationControllerDelegate {}

extension NewPostViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let resultUrl: URL?
        if let url = (info[.imageURL] ?? info[.mediaURL]) as? URL {
            resultUrl = url
        } else if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0) {
            print(data)
            resultUrl = nil
        } else {
            print(info)
            resultUrl = nil
        }
        if let url = resultUrl {
            attachedMediaListVC.input(attachedMediaListVC.input + [url])
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
