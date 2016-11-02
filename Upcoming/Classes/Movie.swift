//
//  Moviel.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import Foundation

struct Movie: JSONDecodable {
    let id: Int
    let title: String
    let releaseDate: Date
    let posterPath: String?
    let overview: String
    let backdropPath: String?
    let genres: [Genre]

    private static let ReleaseDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    init(container: JSONDictionary) throws {
        id = try "id" <- container
        title = try "title" <- container
        overview = try "overview" <- container

        let releaseDateString: String = try "release_date" <- container
        guard let date = Movie.ReleaseDateFormatter.date(from: releaseDateString) else {
            throw JSONDecodableError.unexpectedValueType("Date", key: "release_date")
        }

        releaseDate = date

        posterPath = try "poster_path" <~ container
        backdropPath = try "backdrop_path" <~ container

        let identifiers: [Int] = try "genre_ids" <- container
        genres = identifiers.flatMap { Genre.genre(with: $0) }
    }
}
