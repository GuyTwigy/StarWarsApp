//
//  PeopleModelData.swift
//  StarWarsApp
//
//  Created by Guy Twig on 14/05/2023.
//

import Foundation

struct PeopleModelData: Decodable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [SinglePeople]
}

struct SinglePeople: Decodable, Equatable {
    let name: String?
    let height: String?
    var isFavorite: Bool?
}
