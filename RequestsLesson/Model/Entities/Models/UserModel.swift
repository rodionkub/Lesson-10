//
//  UserModel.swift
//  RequestsLesson
//
//  Created by Родион Кубышкин on 16/01/2020.
//

import Foundation

struct NameReply: Decodable {
    let response: [User]?
}

struct User: Decodable {
    let first_name: String?
    let last_name: String?
    let photo_50: String?
}
