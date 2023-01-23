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
    func didSelectRow(at indexPath: IndexPath)
    func didTapSearchButton(text: String?)
}

// PresenterからViewに描画を実行するよう指示する際の処理
protocol SearchPokemonPresenterOutPut: AnyObject {
    func updatePokemons(_ pokemons: [Pokemon])
    func showErrorAlert(_ error: Error)
    func transitionToRepositoryList(PokemonName: String)
}

// クラスファイルをInput(= ViewからPresenterに依頼された際に実行する処理のプロトコル)に準拠
final class SearchPokemonPresenter: SearchPokemonPresenterInput {
    // API通信で取得したデータをパースした値を格納する配列を定義
    private(set) var pokemons: [Pokemon] = []

    var filteredPokemons: [Pokemon] = []

    // View側でこちらのprotocolに準拠させることでこちらでdelegagteメソッド実行時、view側に処理を依頼できる。
    private weak var view: SearchPokemonPresenterOutPut!

    private var api: APIInput

    init(view: SearchPokemonPresenterOutPut, api: APIInput) {
        self.view = view
        self.api = api
    }

    var numberOfPokemons: Int {
        pokemons.count
    }

    func pokemon(forRow row: Int) -> Pokemon? {
        guard row < pokemons.count else { return nil }
        return pokemons[row]
    }

    func didSelectRow(at indexPath: IndexPath) {
        guard let pokemon = pokemon(forRow: indexPath.row) else { return }
        view.transitionToRepositoryList(PokemonName: pokemon.name)
    }

    func fetchPokemonData() {
        api.decodePokemonData(completion: { [weak self] result in
            switch result {
            case .success(let pokemons):
                self?.pokemons = pokemons

                DispatchQueue.main.async {
                    self?.view.updatePokemons(pokemons)
                }
            case .failure(let error):
                self?.view.showErrorAlert(error)
            }
        })
    }

    func didTapSearchButton(text: String?) {
        guard let query = text else { return }
        guard !query.isEmpty else { return }
    }
}
