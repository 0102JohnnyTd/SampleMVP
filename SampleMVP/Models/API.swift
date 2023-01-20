//
//  API.swift
//  SampleMVP
//
//  Created by Johnny Toda on 2023/01/20.
//

import Foundation

//　API通信におけるエラーを管理
enum APIError: Error {
    case invalidURL
}

// API通信で使用するRequestURLを管理
enum TypeOfFetch: String {
    case userData
    case repositoryData
}

final class API {
    // レスポンスデータをUserRepository用にdecode(パース)する処理を実行
    func decodeGitHubUsersRepositoryData(typeOfFetch: TypeOfFetch, userName: String, completion: @escaping (Result<UsersRepository, Error>) -> Void) {
        fetchGitHubData(typeOfFetch: typeOfFetch, userName: userName, completion: { result in
            switch result {
            case .success(let data):
                do {
                    // デコード処理
                    let usersRepository = try JSONDecoder().decode(UsersRepository.self, from: data)
                    completion(.success((usersRepository)))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    // レスポンスデータをUserModel用にdecode(パース)する処理を実行
    func decodeGitHubUserData(typeOfFetch: TypeOfFetch, userName: String, completion: @escaping (Result<User, Error>) -> Void) {
        fetchGitHubData(typeOfFetch: typeOfFetch, userName: userName, completion: { result in
            switch result {
            case .success(let data):
                do {
                    // デコード処理
                    let user = try JSONDecoder().decode(User.self, from: data)
                    completion(.success((user)))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    // API通信を実行
    private func fetchGitHubData(typeOfFetch: TypeOfFetch, userName: String, completion: @escaping (Result<Data, Error>) -> Void) {

        // 指定したcaseに適したString型のURLを取得
        let stringURL = switchURLFromTypeOfFetch(typeOfFetch: typeOfFetch, userName: userName)

        // RequestURLを作成
        guard let requestURL = URL(string: stringURL) else {
            // URLが無効だった場合Errorを渡してクロージャを実行
            completion(.failure(APIError.invalidURL))
            return
        }

        // taskを作成
        let task = URLSession.shared.dataTask(with: requestURL, completionHandler: { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            guard let data = data else { return }
            completion(.success(data))
            }
        )
        // 通信を実行
        task.resume()
    }


    // Fetchする型ごとに通信の際に使用するリクエストURLを切り分ける
    private func switchURLFromTypeOfFetch(typeOfFetch: TypeOfFetch, userName: String) -> String {
        let url: String

        switch typeOfFetch {
        case .userData: url = "https://api.github.com/users/\(userName)"
        case .repositoryData: url = "https://api.github.com/users/\(userName)/repos"
        }

        return url
    }
}
