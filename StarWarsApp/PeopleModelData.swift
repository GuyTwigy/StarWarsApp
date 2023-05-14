//
//  PeopleModelData.swift
//  StarWarsApp
//
//  Created by Guy Twig on 14/05/2023.
//

import Foundation

struct PeopleModelData: Codable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [SinglePeople]
}

struct SinglePeople: Codable {
    let name: String?
    let height: String?
}
