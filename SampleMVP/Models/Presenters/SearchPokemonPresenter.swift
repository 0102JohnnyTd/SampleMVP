//
//  SearchPokemonPresenter.swift
//  SampleMVP
//
//  Created by Johnny Toda on 2023/01/21.

import Foundation

// ViewからPresenterに処理を依頼する際の処理
protocol SearchPokemonPresenterInput {
    var numberOfPokemons: Int { get }
    func fetchPokemonData()
    func pokemon(forRow row: Int) ->Pokemon?
    func didTapSearchButton(text: String?)
    func textDidChenge(text: String?)
}

// PresenterからViewに描画を実行するよう指示する際の処理
protocol SearchPokemonPresenterOutPut: AnyObject {
    func startIndicator()
    func updatePokemons(_ pokemons: [Pokemon])
    func showErrorAlert(_ error: Error)
    func closeKeyboard()
}

// クラスファイルをInput(= ViewからPresenterに依頼された際に実行する処理のプロトコル)に準拠
final class SearchPokemonPresenter: SearchPokemonPresenterInput {
    // API通信で取得したデータをパースした値を格納する配列を定義。これを避難用の配列とする？
    var pokemons: [Pokemon] = []
    // pokemonsから要素を受け取る
    var filteredPokemons: [Pokemon] = []

    // View側でこちらのprotocolに準拠させることでこちらでdelegagteメソッド実行時、view側に処理を依頼できる。
    private weak var view: SearchPokemonPresenterOutPut!

    private var api: APIInput

    init(view: SearchPokemonPresenterOutPut, api: APIInput) {
        self.view = view
        self.api = api
    }

    var numberOfPokemons: Int {
        filteredPokemons.count
    }

    func pokemon(forRow row: Int) -> Pokemon? {
        guard row < filteredPokemons.count else { return nil }
        return filteredPokemons[row]
    }

    func fetchPokemonData() {
        view.startIndicator()
        api.decodePokemonData(completion: { [weak self] result in
            switch result {
            case .success(let pokemons):
                self?.pokemons = pokemons
                self?.filteredPokemons = pokemons
                self?.filteredPokemons.sort { $0.id < $1.id }

                DispatchQueue.main.async {
                    self?.view.updatePokemons(pokemons)
                }
            case .failure(let error):
                self?.view.showErrorAlert(error)
            }
        })
    }

    // Viewで検索ボタンタップ時に呼び出される
    func didTapSearchButton(text: String?) {
        // ViewにKeyboardを閉じる描画指示を出す
        view.closeKeyboard()

        guard let query = text else {
            return
        }
        // 要素の重複を避ける為、一度配列の中身を空にする
        filteredPokemons = []

        // 空文字だった場合、全ポケモンを再追加
        guard !query.isEmpty else {
            filteredPokemons = pokemons
            filteredPokemons.sort { $0.id < $1.id }
            view.updatePokemons(filteredPokemons)
            return
        }

        pokemons.forEach {
            // 検索クエリと名前が部分一致したポケモンだけ要素として追加する
               // 大文字検索にも対応させる為、クエリを小文字変換する処理を実装
            if $0.name.contains(query.lowercased()) {
                filteredPokemons.append($0)
            }
        }
        // ViewにTableを更新する描画を指示
        view.updatePokemons(filteredPokemons)
    }

    func textDidChenge(text: String?) {
        guard let query = text else {
            return
        }
        if query.isEmpty {
            filteredPokemons = pokemons
            filteredPokemons.sort { $0.id < $1.id }
            view.updatePokemons(filteredPokemons)
        }
    }
}
