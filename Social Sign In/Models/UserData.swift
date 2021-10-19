//
//  UserData.swift
//  Social Sign In
//
//  Created by Khusan Yusufkhujaev on 06/10/21.
//

struct UserData: Equatable {
    let name: String?
    let surname: String?
    let email: String?
    let birthDate: String?
    let phoneNumber: String?

    init (
        name: String? = nil,
        surname: String? = nil,
        email: String? = nil,
        birthDate: String? = nil,
        phoneNumber: String? = nil
    ) {
        self.name = name
        self.surname = surname
        self.email = email
        self.birthDate = birthDate
        self.phoneNumber = phoneNumber
    }

    static func == (lhs: UserData, rhs: UserData) -> Bool {
        lhs.name == rhs.name &&
        lhs.surname == rhs.surname &&
        lhs.email == rhs.email &&
        lhs.birthDate == rhs.birthDate &&
        lhs.phoneNumber == rhs.phoneNumber
    }
}
