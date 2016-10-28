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

class UpcomingMoviesViewController: UIViewController {
    private(set) var viewModel = MoviesListViewModel(service: TMDBService())

    @objc private func triggerUpdate() {
        viewModel.update()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(triggerUpdate))

        viewModel.onError = { [weak self] error in
            guard let sself = self else { return }
            display(error: error, in: sself)
        }

        viewModel.onMoviesListUpdated = { viewModel in
            dump(viewModel.movies)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
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
