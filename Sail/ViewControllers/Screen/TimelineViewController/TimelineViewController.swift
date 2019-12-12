//
//  TimelineViewController.swift
//  Sail
//
//  Created by user on 2019/08/30.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Mew
import SailCore
import SeaAPI
import SnapKit
import Ikemen

class TimelineViewController: UIViewController, Instantiatable {
    
    typealias Input = Void
    typealias Environment = SeaAccountToken
    
    var environment: Environment

    enum Section {
        case main
    }
    
    lazy var diffableDataSource: UITableViewDiffableDataSource<Section, SeaPost> = .init(tableView: tableView, cellProvider: self.cellProvider)
    let tableView = UITableView(frame: .zero, style: .plain) ※ { v in
        v.keyboardDismissMode = .interactive
    }
    let refreshControl = UIRefreshControl()
    let toolBar = UIToolbar()
    lazy var quickPostField = UITextField() ※ { v in
        v.borderStyle = .roundedRect
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentHuggingPriority(.init(100), for: .horizontal)
        v.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    lazy var quickSendButton = UIButton() ※ { v in
        v.setImage(UIImage(systemName: "paperplane"), for: .normal)
    }
    lazy var quickSendIndicator = UIActivityIndicatorView() ※ { v in
        v.style = .medium
    }
    
    var currentlyLoading = false {
        didSet {
            quickPostField.isEnabled = !currentlyLoading
            quickSendButton.isHidden = currentlyLoading
            if currentlyLoading {
                quickSendIndicator.startAnimating()
            } else {
                quickSendIndicator.stopAnimating()
            }
            toolBar.layoutIfNeeded()
        }
    }
    
    required init(with input: Void, environment: Environment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableViewCell<CompactPostViewController>.register(to: tableView)


        tableView.dataSource = diffableDataSource
        tableView.refreshControl = refreshControl
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.center.size.equalToSuperview()
        }
        
        quickSendButton.addTarget(self, action: #selector(sendPost), for: .touchUpInside)
        view.addSubview(toolBar)
        toolBar.setItems([
            .init(customView: UIStackView(arrangedSubviews: [
                quickPostField,
                quickSendButton,
                quickSendIndicator,
            ]) ※ { v in
                v.axis = .horizontal
                v.spacing = 8
            }),
        ], animated: false)
        toolBar.snp.makeConstraints { make in
            make.centerX.width.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(44)
        }
        self.additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: 44, right: 0)
        
        title = "Timeline"
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .compose, target: self, action: #selector(openNewPost))
        refreshControl.addTarget(self, action: #selector(checkLatestPosts), for: .valueChanged)
        
        var snapshot = diffableDataSource.snapshot()
        snapshot.appendSections([.main])
        diffableDataSource.apply(snapshot, animatingDifferences: false, completion: nil)
        
        checkLatestPosts()
        
        for name in [
            UIResponder.keyboardWillHideNotification,
            UIResponder.keyboardWillChangeFrameNotification,
        ] {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardHeightChanged(_:)), name: name, object: nil)
        }
    }
    
    func cellProvider(_ tableView: UITableView, indexPath: IndexPath, post: SeaPost) -> UITableViewCell {
        return TableViewCell<CompactPostViewController>.dequeued(
            from: tableView,
            for: indexPath,
            input: post,
            parentViewController: self
         )
    }
    
    @objc func openNewPost() {
        let vc = NewPostViewController.instantiate(.init(text: quickPostField.text), environment: environment)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func checkLatestPosts() {
        refreshControl.beginRefreshing()
        let snapshot = diffableDataSource.snapshot()
        let sinceId = snapshot.itemIdentifiers(inSection: .main).first?.id
        let request = SeaAPI.PublicTimeline(count: sinceId != nil ? 100 : nil, sinceId: sinceId)
        let task = environment.userCredential.request(r: request) { result in
            switch result {
            case .success(let posts):
                var snapshot = self.diffableDataSource.snapshot()
                if let topPost = snapshot.itemIdentifiers(inSection: .main).first {
                    snapshot.insertItems(posts, beforeItem: topPost)
                } else {
                    snapshot.appendItems(posts, toSection: .main)
                }
                DispatchQueue.main.sync {
                    self.diffableDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
                }
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
        task.resume()
    }
    
    @objc func keyboardHeightChanged(_ notification: Notification) {
        print(notification.name)
        guard var rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        print(notification.userInfo)
        let isHideNotify = notification.name == UIResponder.keyboardWillHideNotification
        if isHideNotify {
            rect.size.height = 0
        }
        let actualSafeArea = view.superview?.safeAreaInsets.bottom ?? 0
        var bottom = 44 + rect.size.height - actualSafeArea
        if bottom < 44 {
            bottom = 44
        }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            print("duration is nil or invalid")
            return
        }
        guard let animationCurveRawValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            print("animationCurveRawValue is nil or invalid")
            return
        }
        let options = UIView.AnimationOptions(rawValue: animationCurveRawValue)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: bottom, right: 0)
            self.view.layoutIfNeeded()
        })
        print(rect.size.height)
    }
    
    @objc func sendPost() {
        guard let text = quickPostField.text else { return }
        currentlyLoading = true
        let request = SeaAPI.CreatePost(text: text)
        let task = environment.userCredential.request(r: request) { result in
            DispatchQueue.main.async {
                self.currentlyLoading = false
            }
            switch result {
            case .success(let res):
                DispatchQueue.main.async {
                    self.quickPostField.text = nil
                    self.checkLatestPosts()
                }
            case .failure(let error):
                print(error)
            }
        }
        task.resume()
    }
}
