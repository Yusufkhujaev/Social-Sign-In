//
//  SocialLoginManagerTests.swift
//  Social Sign InTests
//
//  Created by Khusan Yusufkhujaev on 06/10/21.
//

import XCTest
@testable import Social_Sign_In

fileprivate typealias SampleError = SocialLoginProviderMock.SampleError

final class SocialLoginManagerTests: XCTestCase {
    func testThatProviderGeneratedCorrectly() {
        // Assert
        let mainViewController = MainViewController()
        _ = mainViewController.view

        var sut = SocialLoginManagerMock(sampleLoginProvider: GoogleLoginProvider())
        sut.viewController = mainViewController

        // Act
        sut.socialType = .google
        sut.login(completionHandler: { _ in })

        // Assert
        XCTAssertNotNil(sut.generatedProvider as? GoogleLoginProvider)

        // Arrange
        sut = SocialLoginManagerMock(sampleLoginProvider: FacebookLoginProvider())
        sut.viewController = mainViewController

        // Act
        sut.socialType = .facebook
        sut.login(completionHandler: { _ in })

        // Assert
        XCTAssertNotNil(sut.generatedProvider as? FacebookLoginProvider)
    }

    func testThatLoggedinWithError() {
        // Arrange
        let sut = makeSUT(sampleError: .error)
        let expectation = self.expectation(description: "Login")
        var receivedError: SampleError?
        var receivedData: UserData?

        // Act
        sut.login { result in
            switch result {
            case .failure(let error): receivedError = error as? SampleError
            case .success(let data): receivedData = data
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)

        // Assert
        XCTAssertEqual(receivedError, .error)
        XCTAssertNil(receivedData)
    }

    func testThatLoggedinWithSampleData() {
        // Arrange
        let sampleData: UserData = .init(
            name: "Name",
            surname: "Surname",
            email: "example@gmail.com",
            birthDate: "01.01.2005",
            phoneNumber: "+998901234567"
        )
        let sut = makeSUT(sampleData: sampleData)
        let expectation = self.expectation(description: "Login")
        var receivedError: Error?
        var receivedData: UserData?

        // Act
        sut.login { result in
            switch result {
            case .failure(let error): receivedError = error
            case .success(let data): receivedData = data
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)

        // Assert
        XCTAssertNil(receivedError)
        XCTAssertEqual(sampleData, receivedData)
    }

    func testThatLoggedinWithInvalidData() {
        // Arrange
        let sampleData: UserData = .init(
            name: "Name123$%!@#",
            surname: "Фамилия",
            email: "example@gmail",
            birthDate: "01.01.1995",
            phoneNumber: "+9989 012 345 67 sa"
        )
        let sut = makeSUT(sampleData: sampleData)
        let expectation = self.expectation(description: "Login")
        var receivedError: Error?
        var receivedData: UserData?

        // Act
        sut.login { result in
            switch result {
            case .failure(let error): receivedError = error
            case .success(let data): receivedData = data
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)

        // Assert
        XCTAssertNil(receivedError)
        XCTAssertEqual(
            .init(
                name: "Invalid name format",
                surname: "Invalid surname format",
                email: "Email is invalid",
                birthDate: "Birthdate is sooner than 2003",
                phoneNumber: "+998901234567"
            ),
            receivedData
        )
    }

    func testThatLoggedinWithEmptyData() {
        // Arrange
        let sampleData: UserData = .init(name: nil, surname: "", email: "", birthDate: nil, phoneNumber: "")
        let sut = makeSUT(sampleData: sampleData)
        let expectation = self.expectation(description: "Login")
        var receivedError: Error?
        var receivedData: UserData?

        // Act
        sut.login { result in
            // Assert
            switch result {
            case .failure(let error): receivedError = error
            case .success(let data): receivedData = data
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)

        // Assert
        XCTAssertNil(receivedError)
        XCTAssertEqual(.init(), receivedData)
    }
}

// MARK: - Helpers

extension SocialLoginManagerTests {
    private func makeSUT(sampleError: SampleError? = nil, sampleData: UserData? = nil) -> SocialLoginManager {
        let sampleProvider = SocialLoginProviderMock(sampleError: sampleError, sampleData: sampleData)
        let sut = SocialLoginManagerMock(sampleLoginProvider: sampleProvider)
        sut.socialType = .google

        return sut
    }
}

fileprivate class SocialLoginManagerMock: SocialLoginManager {
    var generatedProvider: SocialLoginProvider?

    private var sampleLoginProvider: SocialLoginProvider

    init(sampleLoginProvider: SocialLoginProvider) {
        self.sampleLoginProvider = sampleLoginProvider

        super.init()
    }

    override func getProvider(from socialType: SocialLoginManager.SocialType) -> SocialLoginProvider? {
        if sampleLoginProvider as? GoogleLoginProvider != nil || sampleLoginProvider as? FacebookLoginProvider != nil {
            let provider = super.getProvider(from: socialType)
            generatedProvider = provider

            return provider
        } else {
            return sampleLoginProvider
        }
    }
}
