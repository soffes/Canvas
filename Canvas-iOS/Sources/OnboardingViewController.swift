//
//  OnboardingViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class OnboardingViewController: UIViewController {

	// MARK: - Properties
	
	let scrollView: UIScrollView = {
		let view = UIScrollView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.showsVerticalScrollIndicator = false
		view.showsHorizontalScrollIndicator = false
		view.isPagingEnabled = true
		return view
	}()
	
	let viewControllers: [UIViewController]
	
	private var stickyLeadingConstraint: NSLayoutConstraint!
	
	private let stickyContainer: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.isUserInteractionEnabled = true
		return view
	}()
	
	private let pageControl: UIPageControl = {
		let control = UIPageControl()
		control.currentPageIndicatorTintColor = Swatch.darkGray
		control.pageIndicatorTintColor = Swatch.lightGray
		control.numberOfPages = 4
		return control
	}()
	
	private var currentViewController: UIViewController? {
		willSet {
			currentViewController?.viewWillDisappear(false)
			newValue?.viewWillAppear(false)
		}
		
		didSet {
			oldValue?.viewDidDisappear(false)
			currentViewController?.viewDidAppear(false)
		}
	}

	
	private let backSwipe: UIScreenEdgePanGestureRecognizer = {
		let recognizer = UIScreenEdgePanGestureRecognizer()
		recognizer.edges = .left
		return recognizer
	}()
	private var startingOffset: CGFloat = 0


	// MARK: - Initializers
	
	init() {
		viewControllers = [
			OnboardingWelcomeViewController(),
			OnboardingGesturesViewController(),
			OnboardingOrigamiViewController(),
			OnboardingSharingViewController(),
		]
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = Swatch.white
		
		viewControllers.forEach { viewController in
			scrollView.addSubview(viewController.view)
		}
		
		scrollView.delegate = self
		view.addSubview(scrollView)

		pageControl.addTarget(self, action: #selector(pageControlDidChange), for: .valueChanged)
		stickyContainer.addArrangedSubview(pageControl)
		
		let footer = PrefaceButton()
		footer.translatesAutoresizingMaskIntoConstraints = false
		footer.setTitle("Start using Canvas", for: .normal) // TODO: Localize
		footer.addTarget(self, action: #selector(signUp), for: .primaryActionTriggered)
		stickyContainer.addArrangedSubview(footer)
		
		let line = LineView()
		line.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(line)
		
		view.addSubview(stickyContainer)
		
		stickyLeadingConstraint = stickyContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor)
		
		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			stickyLeadingConstraint,
			stickyContainer.widthAnchor.constraint(equalTo: view.widthAnchor),
			stickyContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			line.topAnchor.constraint(equalTo: footer.topAnchor),
			
			footer.heightAnchor.constraint(equalToConstant: 48)
		])
		
		backSwipe.addTarget(self, action: #selector(didBackSwipe))
		view.addGestureRecognizer(backSwipe)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let size = view.bounds.size
		
		for (i, viewController) in viewControllers.enumerate() {
			viewController.view.frame = CGRect(x: CGFloat(i) * size.width, y: 0, width: size.width, height: size.height)
		}
		
		scrollView.contentSize = CGSize(width: size.width * CGFloat(viewControllers.count), height: size.height)
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

		let page = currentPageIndex()

		coordinator.animateAlongsideTransition({ [weak self] _ in
			self?.scrollTo(page: page, animated: false, width: size.width)
		}, completion: nil)
	}

	
	// MARK: - Private
	
	private func scrollTo(page: Int, animated: Bool = true, width: CGFloat? = nil, completion: (() -> ())? = nil) {
		let width = width ?? scrollView.frame.width
		let rect = CGRect(x: width * CGFloat(page), y: 0, width: width, height: 1)

		UIView.animate(withDuration: animated ? 0.3 : 0, animations: { [weak self] in
			guard let scrollView = self?.scrollView else { return }
			scrollView.scrollRectToVisible(rect, animated: false)
			self?.stickyContainer.layoutIfNeeded()
		}, completion: { [weak self] _ in
			guard let scrollView = self?.scrollView else { return }
			self?.scrollViewDidScroll(scrollView: scrollView)
			self?.scrollViewDidEndDecelerating(scrollView: scrollView)
			completion?()
		})
	}
	
	@objc private func pageControlDidChange() {
		scrollTo(page: pageControl.currentPage)
	}
	
	@objc private func signUp() {
		// TODO: Implement :)
	}

	@objc private func didBackSwipe(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
		if scrollView.scrollEnabled {
			return
		}
		
		switch gestureRecognizer.state {
		case .began: startingOffset = scrollView.contentOffset.x
		case .changed: scrollView.contentOffset.x = startingOffset - gestureRecognizer.translationInView(view).x
		case .ended: snapToPage()
		default: break
		}
	}
	
	private func currentPageIndex() -> Int {
		let offset = scrollView.contentOffset.x
		let width = scrollView.frame.width
		return Int(floor((offset - width / 2) / width)) + 1
	}
	
	private func snapToPage() {
		scrollTo(page: currentPageIndex())
	}
}


extension OnboardingViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(scrollView: UIScrollView) {
		let offset = scrollView.contentOffset.x
		let width = scrollView.frame.width
		let numberOfPages = CGFloat(pageControl.numberOfPages)
		
		stickyLeadingConstraint.constant = -max(0, offset - (width * (numberOfPages - 1)))
	}
	
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		let page = currentPageIndex()
		
		pageControl.currentPage = min(pageControl.numberOfPages - 1, page)
		currentViewController = viewControllers[page]
		
		scrollView.isScrollEnabled = page < pageControl.numberOfPages
	}
}
