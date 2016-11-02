//
//  UpcomingMoviesListViewModel.swift
//  Upcoming
//
//  Created by Nico Ameghino on 11/2/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import Foundation
import UIKit

class UpcomingMoviesListViewModel<T: MoviesPagedResponse>: MoviesListViewModel<T> {

    override var title: String { return "Upcoming Movies" }

    override var rightBarButtonItem: UIBarButtonItem? {
        return UIBarButtonItem(barButtonSystemItem: .search, target: viewController, action: #selector(MoviesListViewController.startSearch))
    }

    override func update() {
        super.update()
        moviesService.fetchUpcomingMovies(page: pageToFetch) { [weak self] (result: Result<T>) -> Void in
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

            let movieViewModels = response.movies.map { [weak self] in
                MovieViewModel(movie: $0, moviesService: self!.moviesService, postersService: self!.postersService)
            }
            sself.movies += movieViewModels
        }
    }
}
