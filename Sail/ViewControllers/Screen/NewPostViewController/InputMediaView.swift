//
//  InputMediaViewController.swift
//  Sail
//
//  Created by user on 2019/12/12.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Mew
import Ikemen

class InputMediaView: UIView {
    unowned var viewController: NewPostViewController
    
    init(viewController: NewPostViewController) {
        self.viewController = viewController
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let buttons = [
            UIButton() ※ { v in
                v.setImage(UIImage(systemName: "camera"), for: .normal)
                v.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
            },
            UIButton() ※ { v in
                v.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
                v.addTarget(self, action: #selector(selectFromPhotoLibrary), for: .touchUpInside)
            },
            UIButton() ※ { v in
                v.setImage(UIImage(systemName: "folder"), for: .normal)
            },
        ]
        
        for button in buttons {
            button.backgroundColor = .systemBackground
            button.layer.cornerRadius = 8
            button.layer.shadowColor = UIColor.darkGray.cgColor
            button.layer.shadowOffset = .init(width: 0, height: 1)
            button.layer.shadowOpacity = 0.5
            button.layer.shadowRadius = 0
        }
        
        let buttonsStackView = UIStackView(arrangedSubviews: buttons) ※ { v in
            v.axis = .vertical
            v.alignment = .fill
            v.spacing = 8
            v.distribution = .fillEqually
            v.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
            v.isLayoutMarginsRelativeArrangement = true
            v.snp.makeConstraints { make in
                make.width.equalTo(72)
            }
        }
        
        let stackView = UIStackView(arrangedSubviews: [
            buttonsStackView,
            UILabel() ※ { v in
                v.text = "coming soon…"
                v.textColor = .systemGray
                v.textAlignment = .center
            },
        ]) ※ { v in
            v.axis = .horizontal
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.size.equalTo(safeAreaLayoutGuide)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func takePhoto() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = viewController
        viewController.present(vc, animated: true, completion: nil)
    }
    
    @objc func selectFromPhotoLibrary() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = viewController
        viewController.present(vc, animated: true, completion: nil)
    }
}
