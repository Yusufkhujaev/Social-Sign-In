//
//  SocialLoginManager.swift
//  Social Sign In
//
//  Created by Khusan Yusufkhujaev on 06/10/21.
//

import UIKit

protocol SocialLoginProvider {
    typealias LoginResult = Result<UserData, Error>

    func login(completionHandler: @escaping (LoginResult) -> Void)
}

class SocialLoginManager: NSObject {
    var socialType: SocialType?

    weak var viewController: UIViewController?

    // MARK: - Helpers

    func login(completionHandler: @escaping (SocialLoginProvider.LoginResult) -> Void) {
        guard let socialType = socialType else {
            assertionFailure("Please set social type")
            return
        }

        getProvider(from: socialType)?.login { result in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let data):
                completionHandler(.success(data.filteredData))
            }
        }
    }

    func getProvider(from socialType: SocialType) -> SocialLoginProvider? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }

        switch socialType {
        case .google:
            let googleLoginProvider = GoogleLoginProvider()
            googleLoginProvider.viewController = viewController
            appDelegate.openURL = googleLoginProvider.openURL(_:open:options:)

            return googleLoginProvider
        case .facebook:
            let facebookLoginProvider = FacebookLoginProvider()
            facebookLoginProvider.viewController = viewController
            appDelegate.openURL = facebookLoginProvider.openURL(_:open:options:)

            return facebookLoginProvider
        }
    }
}

// MARK: - SocialType

extension SocialLoginManager {
    enum SocialType {
        case google
        case facebook
    }
}

fileprivate extension String {
    var isAlphanumeric: Bool {
        !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        return emailPredicate.evaluate(with: self)
    }

    func isSoonerThan(year: UInt = 2003) -> Bool? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        guard let date = dateFormatter.date(from: self) else { return nil }
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year], from: date)
        guard let dateYear = dateComponents.year else { return nil }

        return dateYear > year
    }
}

fileprivate extension RangeReplaceableCollection where Self: StringProtocol {
    var digits: Self { filter(\.isWholeNumber) }
}

fileprivate extension UserData {
    var filteredData: Self {
        var formattedName: String?
        var formattedSurname: String?
        var formattedEmail: String?
        var formattedDate: String?
        var formattedPhone: String?

        if let name = name, !name.isEmpty {
            formattedName = name.isAlphanumeric ? name : "Invalid name format"
        }

        if let surname = surname, !surname.isEmpty {
            formattedSurname = surname.isAlphanumeric ? surname : "Invalid surname format"
        }

        if let email = email, !email.isEmpty {
            formattedEmail = email.isValidEmail ? email : "Email is invalid"
        }

        if let birthDate = birthDate, !birthDate.isEmpty {
            formattedDate = (birthDate.isSoonerThan() ?? true) ? birthDate : "Birthdate is sooner than 2003"
        }

        if let phoneNumber = phoneNumber, !phoneNumber.isEmpty {
            let digits = phoneNumber.digits
            formattedPhone = digits.isEmpty ? "Phone number is invalid" : "+\(phoneNumber.digits)"
        }

        return UserData(
            name: formattedName,
            surname: formattedSurname,
            email: formattedEmail,
            birthDate: formattedDate,
            phoneNumber: formattedPhone
        )
    }
}
