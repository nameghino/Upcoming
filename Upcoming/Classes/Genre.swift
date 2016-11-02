//
//  Genre.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/31/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import Foundation

struct Genre: JSONDecodable {
    let id: Int
    let name: String

    private static var genreMap: [Int : Genre] = [:]

    init(container: JSONDictionary) throws {
        id = try "id" <- container
        name = try "name" <- container
        Genre.genreMap[id] = self
    }

    static func genre(with id: Int) -> Genre? {
        return genreMap[id]
    }

}
