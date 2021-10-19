//
//  ViewController.swift
//  Social Sign In
//
//  Created by Khusan Yusufkhujaev on 05/10/21.
//

import UIKit

final class MainViewController: UIViewController {
    typealias CustomField = (stackView: UIStackView, textField: UITextField)

    private(set) lazy var customFields: [CustomField] = FieldType.allCases.map { createCustomField(with: $0) }
    private(set) lazy var signInButtons: [UIButton] = SignInButtonType.allCases.map { createSignInButton(with: $0) }

    private lazy var containerStackView: UIStackView = {
        let arrangedSubviews: [UIView] = customFields.map { $0.stackView } + signInButtons
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10.0

        return stackView
    }()

    private var socialLoginManager: SocialLoginManager

    // MARK: - Init

    init(socialLoginManager: SocialLoginManager = .init()) {
        self.socialLoginManager = socialLoginManager

        super.init(nibName: nil, bundle: nil)

        self.socialLoginManager.viewController = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - FieldType

extension MainViewController {
    enum FieldType: String, CaseIterable {
        case name
        case surname
        case email
        case birthDate
        case phoneNumber

        var title: String {
            switch self {
            case .name: return "Name"
            case .surname: return "Surname"
            case .email: return "Email"
            case .birthDate: return "Birth Date"
            case .phoneNumber: return "Phone Number"
            }
        }
    }
}

// MARK: - SignInButtonType

extension MainViewController {
    enum SignInButtonType: String, CaseIterable {
        case google
        case facebook

        var title: String {
            switch self {
            case .google: return "Sign In with Google"
            case .facebook: return "Sign In with Facebook"
            }
        }
    }
}

// MARK: - Lifecycle

extension MainViewController {
    override func loadView() {
        super.loadView()

        setupSubviews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
}

// MARK: - Layout

extension MainViewController {
    private func setupSubviews() {
        view.addSubview(containerStackView)

        NSLayoutConstraint.activate([
            containerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.0),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.0)
        ])
    }
}

// MARK: - Actions

extension MainViewController {
    @objc private func touchUpInside(signInButton: UIButton) {
        guard let buttonIdentifier = signInButton.accessibilityIdentifier,
              let signInButtonType = SignInButtonType(rawValue: buttonIdentifier) else { return }

        switch signInButtonType {
        case .google:
            socialLoginManager.socialType = .google
        case .facebook:
            socialLoginManager.socialType = .facebook
        }

        setData(nil)
        socialLoginManager.login() { [weak self] result in
            switch result {
            case .failure(let error):
                self?.presentAlertController(with: "Error", message: error.localizedDescription)
            case .success(let data):
                self?.setData(data)
            }
        }
    }
}

// MARK: - Helpers

extension MainViewController {
    private func createCustomField(with type: FieldType) -> CustomField {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = type.title
        titleLabel.textColor = .black

        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = false
        textField.accessibilityIdentifier = type.rawValue
        textField.borderStyle = .roundedRect

        let stackView = UIStackView(arrangedSubviews: [titleLabel, textField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 5.0

        return (stackView, textField)
    }

    private func createSignInButton(with type: SignInButtonType) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = type.rawValue
        button.setTitle(type.title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(touchUpInside(signInButton:)), for: .touchUpInside)

        return button
    }

    private func getField(by type: FieldType) -> CustomField? {
        customFields.first(where: { $0.textField.accessibilityIdentifier == type.rawValue })
    }

    private func setData(_ data: UserData?) {
        getField(by: .name)?.textField.text = data?.name
        getField(by: .surname)?.textField.text = data?.surname
        getField(by: .email)?.textField.text = data?.email
        getField(by: .birthDate)?.textField.text = data?.birthDate
        getField(by: .phoneNumber)?.textField.text = data?.phoneNumber
    }

    private func presentAlertController(with title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
