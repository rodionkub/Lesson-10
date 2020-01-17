//
//  PostModel.swift
//  RequestsLesson
//
//  Created by Родион Кубышкин on 16/01/2020.
//

import Foundation

struct Reply: Decodable {
    let response: Response?
}

struct Response: Decodable {
    let count: Int?
    let items: [Post]?
}

struct Post: Decodable {
    let date: Int?
    let text: String?
    let comments: Comment?
    let likes: Like?
    let reposts: Repost?
    let attachments: [Attachment]?
}

struct Attachment: Decodable {
    let type: String?
    let photo: Photo?
}

struct Photo: Decodable {
    let sizes: [Size]?
}

struct Size: Decodable {
    let url: String?
    let height: Int?
    let width: Int?
}

struct Comment: Decodable {
    let count: Int?
}

struct Like: Decodable {
    let count: Int?
}

struct Repost: Decodable {
    let count: Int?
}

