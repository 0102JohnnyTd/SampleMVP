//
//  SearchPokemonPresenter.swift
//  SampleMVP
//
//  Created by Johnny Toda on 2023/01/21.

import Foundation

// ViewからPresenterに処理を依頼する際の処理
protocol SearchPokemonPresenterInput {
    var isContinueState: Bool { get set }
    var numberOfPokemons: Int { get }
    func viewdidLoad()
    func fetchPokemonData()
    func pokemon(forRow row: Int) ->Pokemon?
    func didTapSearchButton(text: String?)
    func textDidChenge(text: String?)
    func didTapAlertCancelButton()
}

// PresenterからViewに描画を実行するよう指示する際の処理
protocol SearchPokemonPresenterOutPut: AnyObject {
    func startIndicator()
    func updatePokemons()
    func showErrorAlert(_ message: String)
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

    // 配列要素のいずれかURLで通信処理が失敗した場合、それ以降の通信をキャンセルするか否かを決める為のBool値
    var isContinueState: Bool {
        get {
            isContinue
        }
        set(newValue) {
            isContinue = newValue
        }
    }

    var isContinue = true

    func pokemon(forRow row: Int) -> Pokemon? {
        guard row < filteredPokemons.count else { return nil }
        return filteredPokemons[row]
    }

    // アプリ起動時にViewから依頼される
    func viewdidLoad() {
        view.startIndicator()
        api.decodePokemonData(completion: { [weak self] result in
            switch result {
            case .success(let pokemons):
                self?.pokemons = pokemons
                self?.filteredPokemons = pokemons
                self?.filteredPokemons.sort { $0.id < $1.id }

                DispatchQueue.main.async {
                    self?.view.updatePokemons()
                }
            case .failure(let error as URLError):
                let errorMessage = error.message
                DispatchQueue.main.async {
                    self?.view.showErrorAlert(errorMessage)
                }
            case .failure:
                fatalError("unexpected Errorr")
            }
        })
    }

    // 通信エラーを通知するAlertのボタンタップ時に実行される処理
    func fetchPokemonData() {
        view.startIndicator()
        api.decodePokemonData(completion: { [weak self] result in
            switch result {
            case .success(let pokemons):
                self?.pokemons = pokemons
                self?.filteredPokemons = pokemons
                self?.filteredPokemons.sort { $0.id < $1.id }

                DispatchQueue.main.async {
                    self?.view.updatePokemons()
                }
            case .failure(let error as URLError):
                let errorMessage = error.message
                DispatchQueue.main.async {
                    self?.view.showErrorAlert(errorMessage)
                }
            case .failure:
                fatalError("unexpected Errorr")
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
            view.updatePokemons()
            return
        }
        // 検索クエリと名前が部分一致したポケモンだけ要素として追加する
        let filteredArray = pokemons.filter {
            // 大文字検索にも対応させる為、クエリを小文字変換する処理を実装
            $0.name.contains(query.lowercased())
        }
        filteredPokemons = filteredArray

        // ViewにTableを更新する描画を指示
        view.updatePokemons()
    }

    func textDidChenge(text: String?) {
        guard let query = text else {
            return
        }
        if query.isEmpty {
            filteredPokemons = pokemons
            filteredPokemons.sort { $0.id < $1.id }
            view.updatePokemons()
        }
    }

    func didTapAlertCancelButton() {
        DispatchQueue.main.async { [weak self] in
            // 本来はアーキテクチャの観点でこのタイミングでBool値を切り替えるべきだが、このやり方だとAlertが2回出てしまうので今は一旦コメントアウト
//            self?.isContinue = false
            self?.view.updatePokemons()
        }
    }
}
