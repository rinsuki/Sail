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
    let textView = UITextView() ※ { v in
        v.isScrollEnabled = false
        v.isEditable = false
        v.font = .preferredFont(forTextStyle: .body)
        v.textContainerInset = .init(top: 4, left: 0, bottom: 4, right: 0)
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
}
