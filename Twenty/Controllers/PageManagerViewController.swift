//
//  PageManagerViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class PageManagerViewController: UIPageViewController {
    
    // MARK: - Properties
    
    var pageControl = UIPageControl()
    lazy var pageVcs: [UIViewController] = {
        // Get VCs from storyboard
        let story = UIStoryboard(name: "Main", bundle: nil)
        let firstVc = story.instantiateViewController(withIdentifier: "Player Names")
        let secondVc = story.instantiateViewController(withIdentifier: "Game Limits")
        
        return [firstVc, secondVc]
    }()
    
    // MARK: - Life cycle functions
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup functions
    
    private func setupPageControl() {
        pageControl.numberOfPages = pageVcs.count
        pageControl.currentPage = 0
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
    }
    
    // MARK: - Segue functions
    
    func segueToGameVc(game: Game) {
        if let navVc = parent as? UINavigationController {
            if let gameVc = (storyboard?.instantiateViewController(withIdentifier: "Game")) as? GameViewController {
                gameVc.currentGame = game
                navVc.pushViewController(gameVc, animated: true)
            }
        }
    }
}

// MARK: - Datasource and delegate functions

extension PageManagerViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let indexOfVc = pageVcs.index(of: viewController) {
            let previousIndex = indexOfVc - 1
            guard previousIndex >= 0 else { return nil }
            return pageVcs[previousIndex]
        }
        else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let indexOfVc = pageVcs.index(of: viewController) {
            let nextIndex = indexOfVc + 1
            guard nextIndex < pageVcs.count else { return nil }
            return pageVcs[nextIndex]
        }
        else {
            return nil
        }
    }
    
}

extension PageManagerViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // Change page control to show current page dot
        if let currentVc = viewControllers?.first {
            if let indexOfCurrentVc = pageVcs.index(of: currentVc) {
                pageControl.currentPage = indexOfCurrentVc
            }
        }
    }
    
}



