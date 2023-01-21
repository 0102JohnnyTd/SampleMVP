//
//  UsersRepository.swift
//  SampleMVP
//
//  Created by Johnny Toda on 2023/01/19.
//

import Foundation

// GitHubユーザーのリポジトリデータを格納するModel
struct UsersRepository: Decodable {
    // リポジトリ名
    var name: String
    // リポジトリの説明文
    var description: String?
    // 言語
    var language: String
}
