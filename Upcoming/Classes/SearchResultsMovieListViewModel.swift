//
//  SearchResultsMovieListViewModel.swift
//  Upcoming
//
//  Created by Nico Ameghino on 11/2/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import Foundation
import UIKit

class SearchResultsMovieListViewModel<T: MoviesPagedResponse>: MoviesListViewModel<T> {

    let query: String


    override var title: String { return "Search" }

    override var leftBarButtonItem: UIBarButtonItem? {
        return UIBarButtonItem(title: "Cancel", style: .done, target: searchStarter, action: #selector(Searcher.dismissSearch))
    }

    init(query: String, moviesService: PagedMoviesService, postersService: PostersService, searchStarter: Searcher) {
        self.query = query
        super.init(moviesService: moviesService, postersService: postersService, searchStarter: searchStarter)
    }

    override func update() {
        super.update()

        moviesService.search(query: query, page: pageToFetch) { [weak self] (result: Result<T>) -> Void in
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
