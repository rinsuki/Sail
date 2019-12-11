//
//  LoginInputHostViewController.swift
//  Sail
//
//  Created by user on 2019/09/02.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Eureka
import CryptoKit
import Ikemen
import SeaAPI

class LoginInputHostViewController: FormViewController {

    lazy private(set) var goBarButtonItem = UIBarButtonItem(
        image: UIImage(systemName: "arrow.right.circle.fill"), style: .done,
        target: self, action: #selector(self.goNext)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print()
        
        // Do any additional setup after loading the view.
        form.append {
            Section(header: "Seaのホスト名を入力してください") {
                TextRow("host") { row in
                    row.placeholder = "example.com"
                    row.cellSetup { cell, row in
                        cell.textField.autocapitalizationType = .none
                        cell.textField.autocorrectionType = .no
                        cell.textField.keyboardType = .URL
                    }
                }
                SwitchRow("useCustomClientCredential") { row in
                    row.title = "自前の認証情報を使う"
                }
            }
            Section(header: "自前の認証情報") {
                TextRow("customClientId") { row in
                    row.title = "Client ID"
                    row.placeholder = "0123456789abcdef"
                }
                TextRow("customClientSecret") { row in
                    row.title = "Client Secret"
                    row.placeholder = "0123456789abcdef"
                }
            } ※ { section in
                section.hidden = "$useCustomClientCredential != true"
            }
        }
        
        navigationItem.title = "Login"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = goBarButtonItem
        goBarButtonItem.isEnabled = false
    }
    
    override func valueHasBeenChanged(for: BaseRow, oldValue: Any?, newValue: Any?) {
        goBarButtonItem.isEnabled = isGoBarButtonEnabled()
    }
    
    private func isGoBarButtonEnabled() -> Bool{
        let formValues = self.form.values()
        print(formValues)
        guard let host = formValues["host"] as? String, host != "" else { return false }
        if let flag = formValues["useCustomClientCredential"] as? Bool, flag == true {
            guard let clientId = formValues["customClientId"] as? String, !clientId.isEmpty else { return false }
            guard let clientSecret = formValues["customClientSecret"] as? String, !clientSecret.isEmpty else { return false }
            return true
        } else {
            return true
        }
    }

    @objc func goNext() {
        let formValues = form.values()
        guard let host = formValues["host"] as? String else { fatalError("host is not string") }
        let credential: SeaClientCredential
        
        if let flag = formValues["useCustomClientCredential"] as? Bool, flag == true {
            guard let clientId = formValues["customClientId"] as? String, !clientId.isEmpty else { fatalError("clientId is empty") }
            guard let clientSecret = formValues["customClientSecret"] as? String, !clientSecret.isEmpty else { fatalError("clientSecret is empty") }
            credential = .init(id: clientId, secret: clientSecret)
        } else {
            var hasher = SHA256()
            hasher.update(data: host.data(using: .utf8)!)
            let digest = hasher.finalize().map { String(format: "%02x", $0) }.joined()
            print("digest is \(digest)")
            guard let cred = AuthClient[digest] else {
                let alertController = UIAlertController(title: "エラー", message: """
このインスタンスはSailに登録されていません。

Sailが対応しているであろう場合は、ドメインのタイプミスを確認してください。

Sailが対応していないであろう場合は、Sea内の /settings/my_developed_applications から自分で登録したClient ID/Secretを、「自前の認証情報を使う」に入れて再度お試しください。
""", preferredStyle: .alert)
                alertController.addAction(.init(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            credential = cred
        }
        let authApp = SeaAuthApp(baseUrl: URL(string: "https://\(host)/")!, credential: credential)
        let newVC = LoginConfirmViewController.instantiate(authApp, environment: Void())
        navigationController?.pushViewController(newVC, animated: true)
    }
}
