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
        presenter.viewdidLoad()
        setUpTableView()
    }

    // 登録処理
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PokemonCell.nib, forCellReuseIdentifier: PokemonCell.identifier)
    }
}

extension SearchPokemonViewController: UISearchBarDelegate {
    // SearchBarの検索ボタンタップ時に実行
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.didTapSearchButton(text: searchBar.text)
    }

    // 検索バーの値が変更された時に実行
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.textDidChenge(text: searchText)
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
    
    func updatePokemons() {
        indicator.stopAnimating()
        indicator.isHidden = true
        view.alpha = 1.0

        tableView.reloadData()
    }

    func showErrorAlert(_ message: String) {
        // falseならAlertの生成及び表示処理を実行しないようにする。
        if presenter.isContinueState {
            // 設計上これでは良くないが、presentが呼ばれるよりも先にisContinueStateをfalseにする方法が現状これしか見出せなかっ為この実装にしている
            presenter.isContinueState = false

            let alertController = UIAlertController(title: "通信エラー", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: { [weak self] _ in
                self?.presenter.didTapAlertCancelButton()
            }))
            alertController.addAction(UIAlertAction(title: "再度試す", style: .default, handler: { [weak self] _ in
                self?.presenter.fetchPokemonData() }))

            present(alertController, animated: true)
            print("presentが呼ばれたわず。")
        }
    }

    func closeKeyboard() {
        view.endEditing(true)
    }
}
