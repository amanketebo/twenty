//
//  PageManagerViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class PageManagerViewController: UIPageViewController {
    var pageControl = UIPageControl()
    lazy var pageVcs: [UIViewController] = {
        let firstVc = UIStoryboard.playerNamesVC
        let secondVc = UIStoryboard.gameLimitsVC
        
        return [firstVc, secondVc]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "New Game"
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        dataSource = self
        delegate = self
        
        if let firstVc = pageVcs.first {
            setViewControllers([firstVc], direction: .forward, animated: true, completion: nil)
        }
        setupPageControl()
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pageVcs.count
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15)
            ])
    }
    
    func segueToGameVc(game: Game) {
        if let navVc = parent as? UINavigationController,
            let gameVc = UIStoryboard.gameVC as? GameViewController {
            gameVc.currentGame = game
            gameVc.playerOne = game.playerOne
            gameVc.playerTwo = game.playerTwo
            navVc.pushViewController(gameVc, animated: true)
        }
    }
}

extension PageManagerViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let indexOfVC = pageVcs.index(of: viewController) else { return nil }
        guard indexOfVC - 1 >= 0 else { return nil }
        
        return pageVcs[indexOfVC - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let indexOfVC = pageVcs.index(of: viewController) else { return nil }
        guard indexOfVC + 1 < pageVcs.count else { return nil }
        
        return pageVcs[indexOfVC + 1]
    }
}

extension PageManagerViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = viewControllers?.first else { return }
        guard let indexOfCurrentVC = pageVcs.index(of: currentVC) else { return }

        pageControl.currentPage = indexOfCurrentVC
    }
}
