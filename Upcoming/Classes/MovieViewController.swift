//
//  MovieViewController.swift
//  Upcoming
//
//  Created by Nico Ameghino on 11/2/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {

    var viewModel: MovieViewModel!

    private func set(viewModel: MovieViewModel) {
        viewModel.onBackdropUpdated = { [weak self] (model: MovieViewModel) -> Void in
            self?.backdropImageView.image = model.backdrop
        }

        viewModel.onPosterUpdated = { [weak self] (model: MovieViewModel) -> Void in
            self?.posterImageView.image = model.poster
        }

        viewModel.onCastUpdated = { [weak self] (model: MovieViewModel) -> Void in

            guard let sself = self else { return }

            let labels = model.castStrings.enumerated().map { (index: Int, content: String) -> UILabel in
                let label = UILabel()
                label.text = content
                label.textColor = .upcomingYellow
                label.font = {
                    if index == 0 { return UIFont.boldSystemFont(ofSize: 18.0) }
                    else { return UIFont.systemFont(ofSize: 15.0) }
                }()

                return label
            }

            let castStackView = UIStackView(arrangedSubviews: labels)
            castStackView.axis = .vertical

            DispatchQueue.main.async {
                sself.contentStackView.addArrangedSubview(castStackView)
                sself.view.setNeedsDisplay()
            }
        }

        titleLabel.text = viewModel.title
        releaseDateLabel.text = "In theaters on \(viewModel.releaseDate)"
        overviewLabel.text = viewModel.overview
        posterImageView.image = viewModel.poster
        backdropImageView.image = viewModel.backdrop
        genresLabel.attributedText = viewModel.genres
    }

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = .upcomingYellow
            titleLabel.backgroundColor = .clear
        }
    }

    @IBOutlet weak var releaseDateLabel: UILabel! {
        didSet {
            releaseDateLabel.textColor = .upcomingYellow
            releaseDateLabel.backgroundColor = .clear
        }
    }

    @IBOutlet weak var overviewLabel: UILabel! {
        didSet {
            overviewLabel.textColor = .upcomingYellow
            overviewLabel.backgroundColor = .clear
        }
    }

    @IBOutlet weak var genresLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .upcomingSteelGray
        navigationItem.title = "Movie details"
        

        set(viewModel: viewModel)
    }


    override func viewDidLayoutSubviews() {
        contentScrollView.contentInset = UIEdgeInsets(top: backdropImageView.bounds.height, left: 0, bottom: 0, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        if viewModel.hasBackdrop {
            viewModel.fetchBackdrop(width: backdropImageView.bounds.width)
        }

        viewModel.fetchPoster(width: posterImageView.bounds.width, ignoreCache: true)
        viewModel.fetchCast()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
