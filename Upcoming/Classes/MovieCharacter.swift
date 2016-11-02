//
//  MovieCharacter.swift
//  Upcoming
//
//  Created by Nico Ameghino on 11/2/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import Foundation

struct MovieCharacter: JSONDecodable {
    let castId: Int
    let name: String
    let playedBy: String

    init(container: JSONDictionary) throws {
        castId = try "cast_id" <- container
        name = try "character" <- container
        playedBy = try "name" <- container
    }
}

extension MovieCharacter: Comparable {
    static func ==(lhs: MovieCharacter, rhs: MovieCharacter) -> Bool {
        return lhs.castId == rhs.castId
    }
    
    static func <(lhs: MovieCharacter, rhs: MovieCharacter) -> Bool {
        return lhs.castId < rhs.castId
    }
}
