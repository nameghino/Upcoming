//
//  MovieViewModel.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import Foundation
import UIKit

private extension UIImage {
    static let noPosterImage = #imageLiteral(resourceName: "no-poster")
    static let noBackdropImage = #imageLiteral(resourceName: "no-backdrop")
}

class MovieViewModel: NSObject {
    private let movie: Movie
    private let postersService: PostersService
    private let moviesService: MoviesService

    private var posterStorage: UIImage? = nil
    private var backdropStorage: UIImage? = nil

    var hasPoster: Bool { return movie.posterPath != nil }
    var hasBackdrop: Bool { return movie.backdropPath != nil }

    var onPosterUpdated: ((MovieViewModel) -> Void)? = nil
    var onBackdropUpdated: ((MovieViewModel) -> Void)? = nil
    var onCastUpdated: ((MovieViewModel) -> Void)? = nil

    var indexPath: IndexPath!

    private static let MovieDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("ddMMyy")
        return formatter
    }()

    init(movie: Movie, moviesService: MoviesService, postersService: PostersService) {
        self.movie = movie
        self.postersService = postersService
        self.moviesService = moviesService
    }

    var title: String {
        return movie.title
    }

    var releaseDate: String {
        return MovieViewModel.MovieDateFormatter.string(from: movie.releaseDate)
    }

    var overview: String {
        return movie.overview
    }

    var poster: UIImage {
        return posterStorage ?? UIImage.noPosterImage
    }

    var backdrop: UIImage {
        return backdropStorage ?? UIImage.noBackdropImage
    }

    private var cast: [MovieCharacter]? = nil

    var castStrings: [String] {
        guard let cast = cast?.prefix(5), cast.count > 0 else { return ["No cast information"] }
        return ["Featuring:"] + cast.map { $0.playedBy + " as " + $0.name }
    }

    var genres: NSAttributedString {

        let textAttributes = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 12.0)!,
            NSForegroundColorAttributeName: UIColor.upcomingLightBlue,
            NSBackgroundColorAttributeName: UIColor.upcomingDarkGray,
        ]

        let spaceAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 12.0),
            NSBackgroundColorAttributeName: UIColor.clear
        ]


        let genres = movie.genres.prefix(3)

        let strings = genres.map {
            (
                NSAttributedString(string: " " + $0.name.lowercased() + " ", attributes: textAttributes),
                NSAttributedString(string: "  ", attributes: spaceAttributes)
            ) }
        
        return strings.reduce(NSMutableAttributedString()) { mutable, gs -> NSMutableAttributedString in
            mutable.append(gs.0)
            mutable.append(gs.1)
            return mutable
        }
    }

    func fetchPoster(width: CGFloat, ignoreCache: Bool = false) {
        guard ignoreCache == true || hasPoster && posterStorage == nil else { return }
        postersService.fetchPosterFor(movie: movie, width: width) { [weak self] result in
            guard let sself = self else { return }
            if case .success(let image) = result {
                sself.posterStorage = image
            }
            sself.onPosterUpdated?(sself)
        }
    }

    func fetchBackdrop(width: CGFloat, ignoreCache: Bool = false) {
        guard ignoreCache == true ||  hasBackdrop && backdropStorage == nil else { return }
        postersService.fetchBackdropFor(movie: movie, width: width) { [weak self] result in
            guard let sself = self else { return }
            if case .success(let image) = result {
                sself.backdropStorage = image
            }
            sself.onBackdropUpdated?(sself)
        }
    }

    func fetchCast() {
        moviesService.fetchCast(movie: movie) { [weak self] (result: Result<[MovieCharacter]>) -> Void in
            guard let sself = self else { return }
            if case .success(let cast) = result {
                sself.cast = cast
            }
            sself.onCastUpdated?(sself)
        }
    }
}
