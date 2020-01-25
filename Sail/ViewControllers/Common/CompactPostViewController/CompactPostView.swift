//
//  CompactPostView.swift
//  Sail
//
//  Created by user on 2020/01/12.
//  Copyright © 2020 rinsuki. All rights reserved.
//

import UIKit
import Mew
import Ikemen
import SeaAPI
import Nuke

class CompactPostView: UIStackView {
    let iconContainerView = ContainerView() ※ { v in
        v.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
    }
    let nameLabel = UILabel() ※ { v in
        v.font = .preferredFont(forTextStyle: .headline)
    }
    let screenNameLabel = UILabel() ※ { v in
        v.font = .preferredFont(forTextStyle: .subheadline)
        v.setContentHuggingPriority(.init(249), for: .horizontal)
    }
    let timeLabel = UILabel() ※ { v in
        v.font = .preferredFont(forTextStyle: .subheadline)
    }
    let textView = NotSelectableTextView() ※ { v in
        v.isScrollEnabled = false
        v.isEditable = false
        v.font = .preferredFont(forTextStyle: .body)
        v.textContainerInset = .init(top: 2, left: 0, bottom: 2, right: 0)
        v.textContainer.lineFragmentPadding = 0
    }
    let viaLabel = UILabel() ※ { v in
        v.font = .preferredFont(forTextStyle: .footnote)
    }
    let botFlagLabel = UILabel() ※ { v in
        v.text = " bot "
        v.backgroundColor = .secondaryLabel
        v.textColor = .systemBackground
        v.font = .preferredFont(forTextStyle: .footnote)
    }
    let imagesStackView = UIStackView() ※ { v in
        v.axis = .horizontal
        v.spacing = 8
        v.distribution = .fillEqually
        v.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }
    var files = [SeaFile]() {
        didSet {
            if files.count == 0 {
                imagesStackView.isHidden = true
                return
            } else {
                imagesStackView.isHidden = false
            }
            if imagesStackView.arrangedSubviews.count > files.count {
                for i in files.count..<imagesStackView.arrangedSubviews.count {
                    imagesStackView.arrangedSubviews[i].isHidden = true
                }
            } else {
                while imagesStackView.arrangedSubviews.count < files.count {
                    let imageView = UIImageView()
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapImage(_:)))
                    imageView.addGestureRecognizer(tapGestureRecognizer)
                    imageView.tag = imagesStackView.arrangedSubviews.count
                    imageView.isUserInteractionEnabled = true
                    imagesStackView.addArrangedSubview(imageView)
                }
            }
            for (i, view) in imagesStackView.arrangedSubviews.enumerated() {
                guard let imageView = view as? UIImageView else {
                    continue
                }
                guard i < files.count else {
                    break
                }
                imageView.image = nil
                let file = files[i]
                if let variant = file.variants.filter({ $0.type == "thumbnail" }).first {
                    Nuke.loadImage(with: variant.url, into: imageView)
                }
            }
        }
    }
    
    
    init() {
        super.init(frame: .zero)
        addArrangedSubview(iconContainerView)
        addArrangedSubview(UIStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [
                nameLabel,
                screenNameLabel,
                timeLabel,
            ]) ※ { v in
                v.spacing = 8
                v.axis = .horizontal
            },
            textView,
            imagesStackView,
            UIStackView(arrangedSubviews: [
                viaLabel,
                botFlagLabel,
                SpacerView(),
            ]) ※ { v in
                v.spacing = 4
                v.axis = .horizontal
            }
        ]) ※ { v in
            v.axis = .vertical
        })
        axis = .horizontal
        spacing = 8
        alignment = .top
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tapImageCallback: ((SeaFile) -> Void)?
    
    @objc func tapImage(_ event: UITapGestureRecognizer) {
        guard let tag = event.view?.tag else { return }
        tapImageCallback?(files[tag])
    }
}
