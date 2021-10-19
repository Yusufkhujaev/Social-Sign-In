//
//  GoogleLoginProvider.swift
//  Social Sign In
//
//  Created by Khusan Yusufkhujaev on 06/10/21.
//

import GoogleSignIn

final class GoogleLoginProvider: SocialLoginProvider {
    weak var viewController: UIViewController?

    private lazy var gidSignIn: GIDSignIn = .sharedInstance

    private let signInConfig = GIDConfiguration(
        clientID: "PUT YOUR CLIENT ID HERE"
    )

    func openURL(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        gidSignIn.handle(url)
    }

    func login(completionHandler: @escaping (SocialLoginProvider.LoginResult) -> Void) {
        checkLoginState { [weak self] isAlreadySignedIn in
            guard let self = self else { return }
            guard let viewController = self.viewController else {
                assertionFailure("Please set View Controller")
                return
            }

            if isAlreadySignedIn { self.gidSignIn.signOut() }
            self.gidSignIn.signIn(with: self.signInConfig, presenting: viewController) { [weak self] user, error in
                if let error = error {
                    completionHandler(.failure(error))
                    return
                }

                guard let user = user else { return }
                let userData = UserData(
                    name: user.profile?.givenName,
                    surname: user.profile?.familyName,
                    email: user.profile?.email
                )

                let scopes: [String] = [
                    "https://www.googleapis.com/auth/user.birthday.read",
                    "https://www.googleapis.com/auth/user.phonenumbers.read"
                ]

                self?.gidSignIn.addScopes(scopes, presenting: viewController) { _, _ in
                    // TODO: - User birthday and phone can be granted after approving an app by Google
                }

                completionHandler(.success(userData))
            }
        }
    }

    private func checkLoginState(completionHandler: @escaping (Bool) -> Void) {
        gidSignIn.restorePreviousSignIn { user, error in
            completionHandler(error == nil || user != nil)
        }
    }
}
