//
//  UIViewControllerWithToolbar.swift
//  Sail
//
//  Created by user on 2019/12/12.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit

class UIViewControllerWithToolbar: UIViewController {
    let toolBar = UIToolbar()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(toolBar)
        toolBar.snp.makeConstraints { make in
            make.centerX.width.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(44)
        }
        additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: 44, right: 0)
        
        for name in [
            UIResponder.keyboardWillHideNotification,
            UIResponder.keyboardWillChangeFrameNotification,
        ] {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardHeightChanged(_:)), name: name, object: nil)
        }
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
}
