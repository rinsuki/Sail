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
import Hydra
import CommonCrypto

class NewPostViewController: UIViewControllerWithToolbar, Instantiatable, Injectable {
    struct Input {
        var text: String?
        var inReplyToPost: SeaPost?
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
        let uploadUrls = attachedMediaListVC.input
        let userCredential = environment.userCredential

        let alert = UIAlertController(title: "送信中", message: "しばらくお待ちください", preferredStyle: .alert)
        present(alert, animated: true)
        
        async { _ -> SeaPost in
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .init(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyyMMdd'_'HHmmss"
            let dateStr = dateFormatter.string(from: .init())
            
            let uploadRequests: [SeaAPI.UploadFileToAlbum] = try uploadUrls
                .map { try Data(contentsOf: $0) }
                .map {
                    return .init(
                        data: $0,
                        name: "UploadFromSail_\(dateStr)_\(String(format: "%08x", Int.random(in: 0..<4294967296)))"
                    )
                }
            let files = try await(Hydra.all(uploadRequests.map { userCredential.requestPromise(r: $0) }))
            let postRequest = SeaAPI.CreatePost(
                text: text,
                fileIds: files.map { $0.id },
                inReplyToId: self.input.inReplyToPost?.id
            )
            return try await(userCredential.requestPromise(r: postRequest))
        }.then(in: .main) { post in
            alert.dismiss(animated: true)
            self.navigationController?.popViewController(animated: true)
        }.catch(in: .main) { error in
            alert.title = "エラー"
            alert.message = "エラーが起きました \n\n\(error)"
            alert.addAction(.init(title: "Close", style: .cancel, handler: nil))
        }

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
        } else if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.1) {
            let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(UUID().uuidString + ".jpeg")
            try! data.write(to: url)
            resultUrl = url
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
