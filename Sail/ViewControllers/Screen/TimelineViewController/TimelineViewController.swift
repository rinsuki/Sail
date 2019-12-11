//
//  TimelineViewController.swift
//  Sail
//
//  Created by user on 2019/08/30.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import SwiftUI
import Mew
import SailCore
import SeaAPI

class TimelineViewController: UIViewController, Instantiatable {
    
    typealias Input = Void
    typealias Environment = SeaAccountToken
    
    var environment: Environment

    enum Section {
        case main
    }
    
    lazy var diffableDataSource: UITableViewDiffableDataSource<Section, SeaPost> = .init(tableView: tableView, cellProvider: self.cellProvider)
    let tableView = UITableView(frame: .zero, style: .plain)
    let refreshControl = UIRefreshControl()
    
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
        
        title = "Timeline"
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .compose, target: self, action: #selector(openNewPost))
        refreshControl.addTarget(self, action: #selector(checkLatestPosts), for: .valueChanged)
        
        var snapshot = diffableDataSource.snapshot()
        snapshot.appendSections([.main])
        diffableDataSource.apply(snapshot, animatingDifferences: false, completion: nil)
        
        checkLatestPosts()
    }
    
    override func loadView() {
        view = tableView
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
        let vc = NewPostViewController.instantiate(environment: self.environment)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func checkLatestPosts() {
        refreshControl.beginRefreshing()
        let snapshot = diffableDataSource.snapshot()
        let sinceId = snapshot.itemIdentifiers(inSection: .main).first?.id
        let request = environment.userCredential.request(r: SeaAPI.PublicTimeline(count: 100, sinceId: sinceId)) { result in
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
        request.resume()
    }
}
