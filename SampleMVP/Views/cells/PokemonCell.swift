//
//  PokemonCell.swift
//  SampleMVP
//
//  Created by Johnny Toda on 2023/01/24.
//

import UIKit
import Kingfisher

final class PokemonCell: UITableViewCell {
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!

    // 2パターン用意してみた。
    func configure(pokemon: Pokemon) {
        iconView.kf.setImage(with: URL(string: pokemon.sprites.frontImage))
        idLabel.text = String(pokemon.id)
        nameLabel.text = pokemon.name
    }

//    func configure(imageURL: String, id: String, name: String) {
//        iconView.kf.setImage(with: URL(string: imageURL))
//        idLabel.text = id
//        nameLabel.text = name
//    }
}
