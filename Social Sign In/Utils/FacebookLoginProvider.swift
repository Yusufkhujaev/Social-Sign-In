//
//  FacebookLoginProvider.swift
//  Social Sign In
//
//  Created by Khusan Yusufkhujaev on 06/10/21.
//

import FBSDKLoginKit

final class FacebookLoginProvider: SocialLoginProvider {
    weak var viewController: UIViewController?

    private lazy var loginManager = LoginManager()

    func openURL(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }

    func login(completionHandler: @escaping (SocialLoginProvider.LoginResult) -> Void) {
        if let token = AccessToken.current, !token.isExpired { loginManager.logOut() }
        loginManager.logIn(permissions: ["public_profile", "email"], from: viewController) { result, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }

            if result?.isCancelled ?? false { return }

            Profile.loadCurrentProfile { profile, error in
                if let error = error {
                    completionHandler(.failure(error))
                    return
                }

                completionHandler(.success(
                    .init(
                        name: profile?.firstName,
                        surname: profile?.lastName,
                        email: profile?.email
                    )
                ))
            }
        }
    }
}
