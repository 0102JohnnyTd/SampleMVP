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
    // 取得したポケモンのデータをSwiftの型として扱う為にデコード
    func decodePokemonData(completion: @escaping (Result<[Pokemon], Error>) -> Void) {
        // データの取得を実行
        fetchPokemonData(completion: { result in
            switch result {
            case .success(let dataArray):
                var pokemons: [Pokemon] = []
                dataArray.forEach {
                    do {
                        let pokemon = try JSONDecoder().decode(Pokemon.self, from: $0)
                        pokemons.append(pokemon)
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(pokemons))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    // データを取得
    private func fetchPokemonData(completion: @escaping (Result<[Data], Error>) -> Void) {
        // D＆P世代までの全ポケモン493体分のデータのURLを取得
        let pokemonIDRange = 1...493
        let stringURLs = getURLs(range: pokemonIDRange)

        // 取得したURLをString型からURL型に変換
        let urls = stringURLs.map { URL(string: $0) }

        // 取得したデータを格納する配列を定義
        var dataArray: [Data] = []


        urls.forEach {
            guard let url = $0 else {
                completion(.failure(APIError.invalidURL))
                return
            }
            // タスクをセット
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                //　エラーが発生した場合はエラーを出力
                if let error = error {
                    print(error)
                    return
                }
                // データをdataArrayに追加
                if let data = data {
                    dataArray.append(data)
                }
                // 全てのデータをdataArrayに格納した場合、引数クロージャにdataArrayを渡して実行
                if urls.count == dataArray.count {
                    completion(.success(dataArray))
                }
            }
            // 通信を実行
            task.resume()
        }
    }

    // D＆P世代までの全ポケモン493体分のデータのURLを取得
    private func getURLs(range: ClosedRange<Int>) -> [String] {
        let urls: [String] = range.map {
            let url = "https://pokeapi.co/api/v2/pokemon/\($0)/"
            return url
        }
        return urls
    }
}
