//
//  UpcomingMoviesViewController.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import UIKit

func display(error: Error, in controller: UIViewController) {
    let alertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    controller.present(alertController, animated: true, completion: nil)
}

class MovieCell: UITableViewCell {
    static let ReuseIdentifier = "MovieCell"

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var releaseDateLabel: UILabel?
    @IBOutlet weak var posterImageView: UIImageView?
    @IBOutlet weak var genresLabel: UILabel?


    override func awakeFromNib() {
        backgroundColor = .upcomingSteelGray
        titleLabel?.textColor = .upcomingYellow
        releaseDateLabel?.textColor = .upcomingYellow
    }

    func set(movie: MovieViewModel) {
        titleLabel?.text = movie.title
        titleLabel?.numberOfLines = 0
        releaseDateLabel?.text = movie.releaseDate
        posterImageView?.contentMode = .scaleAspectFit
        genresLabel?.attributedText = movie.genres
        if movie.hasPoster {
            movie.fetchPoster(width: posterImageView!.bounds.width)
        }
        posterImageView?.image = movie.poster
    }
}

class MoviesListViewController: UIViewController {
    lazy private(set) var viewModel: MoviesListViewModel<TMDBUpcomingMoviesResponse> = {
        let tmdbService = TMDBService()
        let viewModel = UpcomingMoviesListViewModel<TMDBUpcomingMoviesResponse>(moviesService: tmdbService, postersService: tmdbService, viewController: self)
        return viewModel
    }()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.estimatedRowHeight = 84.0
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.separatorInset = UIEdgeInsets.zero
            tableView.separatorColor = .upcomingLavender
            tableView.backgroundColor = .upcomingSteelGray
        }
    }

    @objc private func triggerUpdate() {
        viewModel.update()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title
        navigationController?.navigationBar.barTintColor = .upcomingSteelGray
        navigationController?.navigationBar.tintColor = .upcomingYellow
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.upcomingYellow
        ]

        navigationItem.leftBarButtonItem = viewModel.leftBarButtonItem
        navigationItem.rightBarButtonItem = viewModel.rightBarButtonItem

        viewModel.onError = { [weak self] error in
            guard let sself = self else { return }
            display(error: error, in: sself)
        }

        viewModel.onMoviesListUpdated = { [weak self] viewModel in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        triggerUpdate()
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let targetViewController = segue.destination as? MovieViewController,
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
        else { return }

        targetViewController.viewModel = viewModel.movies[indexPath.row]
    }

    func startSearch() {
        let alertController = UIAlertController(title: "Search movies", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Search", style: .default, handler: { [weak self] (action) in
            guard
                let textField = alertController.textFields?.first,
                let text = textField.text
            else { return }

            self?.runSearch(query: text)
        }))

        present(alertController, animated: true, completion: nil)
    }

    func runSearch(query: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard
            let moviesList = storyboard.instantiateViewController(withIdentifier: "MoviesListViewController") as? MoviesListViewController
            else { return }
        moviesList.viewModel = SearchResultsMovieListViewModel(query: query, moviesService: viewModel.moviesService, postersService: viewModel.postersService, viewController: self)

        let navigationVC = UINavigationController(rootViewController: moviesList)
        present(navigationVC, animated: true, completion: nil)
    }

    func dismissSearch() {
        dismiss(animated: true, completion: nil)
    }

}

extension MoviesListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.done ? 1 : 2
//        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Int.upcomingMoviesSection:
            return viewModel.movies.count
        case Int.loadMoreSection:
            return viewModel.movies.count > 0 ? 1 : 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        if indexPath.section == .loadMoreSection {
            identifier = "LoadMoreCell"
            return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        } else {
            identifier = "MovieCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MovieCell else { fatalError("unknown cell type") }
            if indexPath.section == .upcomingMoviesSection {
                let vm = viewModel.movies[indexPath.row]
                vm.indexPath = indexPath
                vm.onPosterUpdated = { [weak self] (viewModel: MovieViewModel) in
                    guard let sself = self else { return }
                    if let visible = sself.tableView.indexPathsForVisibleRows, visible.contains(vm.indexPath) {
                        DispatchQueue.main.async {
                            // sself.tableView.reloadRows(at: [viewModel.indexPath], with: .none)
                            sself.tableView.reloadData()
                        }
                    }
                }

                cell.set(movie: vm)
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == .loadMoreSection {
            viewModel.update()
        }
    }
}

extension MoviesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private extension Int {
    static let upcomingMoviesSection = 0
    static let loadMoreSection = 1
}
