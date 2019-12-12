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

class TimelineViewController: UIViewControllerWithToolbar, Instantiatable {
    
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
        
        title = "Timeline"
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .compose, target: self, action: #selector(openNewPost))
        refreshControl.addTarget(self, action: #selector(checkLatestPosts), for: .valueChanged)
        
        var snapshot = diffableDataSource.snapshot()
        snapshot.appendSections([.main])
        diffableDataSource.apply(snapshot, animatingDifferences: false, completion: nil)
        
        checkLatestPosts()
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
