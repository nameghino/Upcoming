//
//  MoviesListViewModel.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import Foundation

class MoviesListViewModel: NSObject {
    private let service: PagedMoviesService

    private(set) var movies: [MovieViewModel] = [] {
        didSet {
            onMoviesListUpdated?(self)
        }
    }

    private var pageToFetch: Int = 1
    private var done: Bool = false

    var onError: ((Error) -> Void)? = nil
    var onMoviesListUpdated: ((MoviesListViewModel) -> Void)? = nil

    init(service: PagedMoviesService) {
        self.service = service
    }

    func update() {
        guard !done else {
            onMoviesListUpdated?(self)
            return
        }

        service.fetchUpcomingMovies(page: pageToFetch) { [weak self] (result: Result<UpcomingMoviesPagedResponse>) -> Void in
            guard let sself = self else { return }
            if case .error(let error) = result {
                sself.onError?(error)
                return
            }

            guard case .success(let response) = result else { fatalError("should not be here") }

            if sself.pageToFetch < response.pageCount {
                sself.pageToFetch += 1
            } else {
                sself.done = true
            }

            let movieViewModels = response.movies.map { MovieViewModel(movie: $0) }
            sself.movies += movieViewModels
        }
    }
}
