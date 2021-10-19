//
//  MainViewControllerTests.swift
//  Social Sign InTests
//
//  Created by Khusan Yusufkhujaev on 05/10/21.
//

import XCTest
@testable import Social_Sign_In

fileprivate typealias SampleError = SocialLoginProviderMock.SampleError

final class MainViewControllerTests: XCTestCase {
    private var socialLoginManager: SocialLoginManagerMock?
    private var mainViewController: MainViewController?

    override func setUp() {
        super.setUp()

        socialLoginManager = SocialLoginManagerMock()
        mainViewController = MainViewController(socialLoginManager: socialLoginManager ?? .init())
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() {
        super.tearDown()

        socialLoginManager = nil
        mainViewController = nil
    }

    func testThatAllCustomFieldsCreatedCorrectly() {
        // Arrange
        _ = mainViewController?.view

        let fieldIdentifiers = mainViewController?.customFields.map { $0.textField.accessibilityIdentifier }
        let fieldTypes = MainViewController.FieldType.allCases.map { $0.rawValue }

        // Assert
        XCTAssertEqual(fieldIdentifiers, fieldTypes)
    }

    func testThatAllSignInButtonsCreatedCorrectly() {
        // Arrange
        _ = mainViewController?.view

        let buttonIdentifiers = mainViewController?.signInButtons.map { $0.accessibilityIdentifier }
        let buttonTypes = MainViewController.SignInButtonType.allCases.map { $0.rawValue }

        // Assert
        XCTAssertEqual(buttonIdentifiers, buttonTypes)
    }

    func testThatSignInButtonActionIsCorrectWithSampleData() {
        // Arrange
        socialLoginManager?.sampleData = .init(
            name: "Name",
            surname: "Фамилия№%",
            email: "example",
            birthDate: "01.01.2001",
            phoneNumber: nil
        )

        _ = mainViewController?.view

        // Act
        mainViewController?.signInButtons.first?.sendActions(for: .touchUpInside)

        // Assert
        XCTAssertEqual(mainViewController?.nameTextField?.text, "Name")
        XCTAssertEqual(mainViewController?.surnameTextField?.text, "Invalid surname format")
        XCTAssertEqual(mainViewController?.emailTextField?.text, "Email is invalid")
        XCTAssertEqual(mainViewController?.birthDateTextField?.text, "Birthdate is sooner than 2003")
        XCTAssertEqual(mainViewController?.phoneNumberTextField?.text, "")
    }

    func testThatSignInButtonActionIsCorrectWithError() {
        // Arrange
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        socialLoginManager?.sampleError = SampleError.error
        appDelegate?.window?.rootViewController = mainViewController

        // Act
        mainViewController?.signInButtons.first?.sendActions(for: .touchUpInside)

        let expectaion = XCTestExpectation(description: "Wait")
        let timer = Timer.init(timeInterval: 2.0, repeats: false) { timer in
            expectaion.fulfill()
            timer.invalidate()
        }

        RunLoop.main.add(timer, forMode: .common)
        wait(for: [expectaion], timeout: 2.0 + 10)

        // Arrange
        let alertController = mainViewController?.presentedViewController as! UIAlertController

        // Assert
        XCTAssertEqual(alertController.title, "Error")
        XCTAssertEqual(alertController.message, SampleError.error.localizedDescription)
    }
}

fileprivate extension MainViewController {
    var nameTextField: UITextField? {
        customFields.first(where: { $0.textField.accessibilityIdentifier == FieldType.name.rawValue })?.textField
    }
    var surnameTextField: UITextField? {
        customFields.first(where: { $0.textField.accessibilityIdentifier == FieldType.surname.rawValue })?.textField
    }
    var emailTextField: UITextField? {
        customFields.first(where: { $0.textField.accessibilityIdentifier == FieldType.email.rawValue })?.textField
    }
    var birthDateTextField: UITextField? {
        customFields.first(where: { $0.textField.accessibilityIdentifier == FieldType.birthDate.rawValue })?.textField
    }
    var phoneNumberTextField: UITextField? {
        customFields.first(where: { $0.textField.accessibilityIdentifier == FieldType.phoneNumber.rawValue })?.textField
    }
}

fileprivate class SocialLoginManagerMock: SocialLoginManager {
    var sampleError: Error?
    var sampleData: UserData?

    override func getProvider(from socialType: SocialLoginManager.SocialType) -> SocialLoginProvider? {
        SocialLoginProviderMock(sampleError: sampleError, sampleData: sampleData)
    }
}
