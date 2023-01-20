//
//  User.swift
//  SampleMVP
//
//  Created by Johnny Toda on 2023/01/19.
//

import Foundation

// GitHubユーザーのデータを格納するModel
struct User: Decodable {
    // ユーザー名
    var name: String
    // ユーザーのプロフィール画像
    var imageURL: String

    // プロパティに対する代替keyを指定
    enum CodingKeys: String, CodingKey {
        case name = "login"
        case imageURL = "avatar_url"
    }
}
