//
//  AttachedMediaListViewController.swift
//  Sail
//
//  Created by user on 2019/12/13.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Mew
import Ikemen

class AttachedMediaListViewController: UIViewController, Instantiatable, Injectable, Interactable {
    typealias Input = [URL]
    typealias Environment = Any
    typealias Output = [URL]
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
    
    let layout = UICollectionViewFlowLayout() ※ { l in
        l.scrollDirection = .horizontal
        l.sectionInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        l.minimumInteritemSpacing = 4
    }
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout) ※ { v in
        v.backgroundColor = .clear
        v.alwaysBounceHorizontal = true
    }

    enum Section {
        case onlyOne
    }
    
    lazy var dataSource = UICollectionViewDiffableDataSource<Section, URL>(
        collectionView: collectionView,
        cellProvider: self.cellSource
    )
    
    lazy var heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
    
    override func loadView() {
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        heightConstraint.isActive = true
        CollectionViewCell<AttachedMediaViewController>.register(to: collectionView)
        self.input(input)
    }
    
    func input(_ input: Input) {
        self.input = input
        var snapshot = NSDiffableDataSourceSnapshot<Section, URL>()
        snapshot.appendSections([.onlyOne])
        snapshot.appendItems(input)
        dataSource.apply(snapshot, animatingDifferences: false)

        heightConstraint.constant = input.count > 0 ? (44 + 20) : 0
    }
    
    func output(_ handler: ((Output) -> Void)?) {
        self.handler = handler
    }
    
    func cellSource(_ collectionView: UICollectionView, indexPath: IndexPath, item: URL) -> UICollectionViewCell {
        let cell = CollectionViewCell<AttachedMediaViewController>.dequeued(
            from: collectionView, for: indexPath,
            input: item,
            parentViewController: self
        )
        return cell
    }
}
