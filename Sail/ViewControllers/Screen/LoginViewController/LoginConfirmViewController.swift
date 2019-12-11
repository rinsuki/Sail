//
//  LoginConfirmViewController.swift
//  Sail
//
//  Created by user on 2019/09/04.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import UIKit
import Mew
import Eureka
import EurekaFormBuilder
import SeaAPI
import AuthenticationServices
import Combine
import SailCore

class LoginConfirmViewController: FormViewController, Instantiatable, Injectable {
    typealias Input = SeaAuthApp
    typealias Environment = Void
    let environment: Environment
    var input: Input
    
    required init(with input: Input, environment: Environment) {
        self.input = input
        self.environment = environment
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.input(input)
        
        title = "Authorize"
        navigationItem.largeTitleDisplayMode = .never
        
        form.append {
            Section(
                header: "現時点では、Seaはログインしていないと認証画面を開くことができません。\nそのため、先にログインしてください。",
                footer: "ログイン後はキャンセルを押して戻ってください。"
            ) {
                ButtonRow { row in
                    row.title = "ログイン"
                }.cellUpdate { cell, row in
                    cell.textLabel?.textAlignment = .left
                    cell.accessoryType = .disclosureIndicator
                    cell.textLabel?.textColor = nil
                }.onCellSelection { [unowned self] cell, row in
                    self.openLogin()
                }
            }
            Section() {
                ButtonRow { row in
                    row.title = "Seaで認証"
                }.cellUpdate { cell, row in
                    cell.textLabel?.textAlignment = .left
                    cell.accessoryType = .disclosureIndicator
                    cell.textLabel?.textColor = nil
                }.onCellSelection { [unowned self] cell, row in
                    self.openAuthorize()
                }
            }
        }
    }
    
    func input(_ input: Input) {
        self.input = input
    }
    
    var session: ASWebAuthenticationSession?
    
    func openLogin() {
        let url = URL(string: "/login", relativeTo: input.baseUrl)!
        session = ASWebAuthenticationSession(url: url, callbackURLScheme: nil) { url, error in }
        session?.presentationContextProvider = self
        session?.start()
    }
    
    var disposeBag = Set<AnyCancellable>()
    
    func openAuthorize() {
        let url = input.getOAuthUrl()
        session = ASWebAuthenticationSession(url: url, callbackURLScheme: nil) { [weak self] url, error in
            guard
                let url = url,
                let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let items = urlComponents.queryItems,
                let code = items.first(where: { $0.name == "code" })?.value
            else { return }
            self?.oauthTokenRequest(code: code)
        }
        session?.presentationContextProvider = self
        session?.start()
    }
    
    func oauthTokenRequest(code: String) {
        print("oauth token request", code)
        let task = input.getOAuthToken(code: code) { [weak self] result in
            switch result {
            case .success(let token, let user):
                self?.onTokenReceived(token: token, user: user)
            case .failure(let error):
                print(error)
            }
        }
        task.resume()
    }
    
    func onTokenReceived(token: String, user: SeaUser) {
        var accountToken = SeaAccountToken(name: user.name, screenName: user.screenName, host: input.baseUrl.host!)
        accountToken.token = token
        try! dbQueue.inDatabase { db in
            try accountToken.save(db)
        }
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
}

extension LoginConfirmViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}
