//
//  TopLeftTableViewController.swift
//  Sail
//
//  Created by user on 2019/11/16.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import SailCore
import GRDB

class TopLeftTableViewController: UITableViewController {
    enum Section {
        case accounts
        case addAccount
    }
    
    enum Content: Hashable {
        case account(id: UUID)
        case addAccount
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy private var dataSource = UITableViewDiffableDataSource<Section, Content>(
        tableView: self.tableView,
        cellProvider: self.cellProvider)
    
    private var observer: TransactionObserver?
    
    private var accounts = [SeaAccountToken]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sail"
    }
    
    var firstUpdate = true
    
    override func viewWillAppear(_ animated: Bool) {
        guard observer == nil else {
            print("already observing...")
            return
        }
        let observation = ValueObservation.tracking { db in
            try SeaAccountToken.fetchAll(db)
        }
        observer = try? observation.start(in: dbQueue, onChange: { [weak self] accounts in
            guard let strongSelf = self else { return }
            strongSelf.accounts = accounts
            strongSelf.reloadContents(animated: !strongSelf.firstUpdate)
            strongSelf.firstUpdate = false
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("stop observing")
        observer = nil
    }
    
    func reloadContents(animated: Bool) {
        var snapshot = dataSource.plainSnapshot
        snapshot.appendSections([.accounts, .addAccount])
        snapshot.appendItems(accounts.map { .account(id: $0.id) }, toSection: .accounts)
        snapshot.appendItems([.addAccount], toSection: .addAccount)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    private func cellProvider(tableView: UITableView, indexPath: IndexPath, content: Content) -> UITableViewCell? {
        let cell: UITableViewCell
        switch content {
        case .account(let id):
            cell = .init(style: .subtitle, reuseIdentifier: nil)
            let account = accounts.first { $0.id == id }!
            cell.textLabel?.text = account.name
            cell.detailTextLabel?.text = "@\(account.screenName)@\(account.host)"
        case .addAccount:
            cell = .init()
            cell.imageView?.image = UIImage(systemName: "plus.circle")
            cell.textLabel?.text = "アカウントを追加"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let content = dataSource.itemIdentifier(for: indexPath) else {
             return
        }
        switch content {
        case .account(let id):
            let account = accounts.first { $0.id == id }!
            showDetailViewController(
                UINavigationController(rootViewController: TimelineViewController.instantiate(environment: account)),
                sender: nil
            )
        case .addAccount:
            let vc = ModalNavigationViewController(rootViewController: LoginInputHostViewController())
            vc.modalPresentationStyle = .formSheet
            present(vc, animated: true, completion: nil)
        }
    }
}
