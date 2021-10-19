//
//  SocialLoginProviderMock.swift
//  Social Sign InTests
//
//  Created by Khusan Yusufkhujaev on 19/10/21.
//

@testable import Social_Sign_In

class SocialLoginProviderMock: SocialLoginProvider {
    private let error: Error?
    private let data: UserData?

    init(sampleError: Error? = nil, sampleData: UserData? = nil) {
        error = sampleError
        data = sampleData
    }

    func login(completionHandler: @escaping (SocialLoginProvider.LoginResult) -> Void) {
        if let error = error {
            completionHandler(.failure(error))
        } else if let data = data {
            completionHandler(.success(data))
        }
    }
}

// MARK: - SampleError

extension SocialLoginProviderMock {
    enum SampleError: Error {
        case error
    }
}
