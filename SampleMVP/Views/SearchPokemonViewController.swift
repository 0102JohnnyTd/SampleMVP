//
//  SearchPokemonViewController.swift
//  SampleMVP
//
//  Created by Johnny Toda on 2023/01/23.
//

import UIKit

final class SearchPokemonViewController: UIViewController {
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!

    // PresenterはSceneDelegateにて初期化
    var presenter: SearchPokemonPresenterInput!
    func inject(presenter: SearchPokemonPresenterInput) {
        self.presenter = presenter
    }
    // ハードコーディング対策
    static let storyboradName = "SearchPokemon"

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.fetchPokemonData()
        setUpTableView()
    }

    // 登録処理
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PokemonCell.nib, forCellReuseIdentifier: PokemonCell.identifier)
    }
}

// SearchBarの検索ボタンタップ時に実行
extension SearchPokemonViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.didTapSearchButton(text: searchBar.text)
    }
}

extension SearchPokemonViewController: UITableViewDelegate {
    // Cellの高さを150で固定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
}

// TableViewのDataSource周りの処理
extension SearchPokemonViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfPokemons
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PokemonCell.identifier, for: indexPath) as! PokemonCell

        if let pokemon = presenter.pokemon(forRow: indexPath.row) {
            cell.configure(pokemon: pokemon)
        }
        return cell
    }
}

// Presenterから指示を受けた際に実行される処理
extension SearchPokemonViewController: SearchPokemonPresenterOutPut {
    func startIndicator() {
        view.alpha = 0.5
        indicator.startAnimating()
    }
    
    func updatePokemons(_ pokemons: [Pokemon]) {filteredPokemons.sort { $0.id < $1.id }
        indicator.stopAnimating()
        indicator.isHidden = true
        view.alpha = 1.0

        tableView.reloadData()
    }
    func showErrorAlert(_ error: Error) {
        // エラーアラート処理を実装
    }
}
