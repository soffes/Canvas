//
//  LoadCanvasViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 5/31/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class LoadCanvasViewController: UIViewController {

	// MARK: - Properties

	let canvasID: String

	private var fetching = false
	private let activityIndicator: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.startAnimating()
		return view
	}()


	// MARK: - Initializers

	init(canvasID: String) {
		self.canvasID = canvasID

		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Swatch.white
		view.addSubview(activityIndicator)

		navigationItem.hidesBackButton = true

		NSLayoutConstraint.activate([
			activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
		])
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		fetch()
	}


	// MARK: - Private

	private func fetch() {
		if fetching {
			return
		}

		fetching = true

		// TODO: Load it some how?
	}

	private func showEditor(with canvas: Canvas) {
		guard let navigationController = navigationController else { return }

		let viewController = EditorViewController(canvas: canvas)
		viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: LocalizedString.CloseCommand.string, style: .Plain, target: viewController, action: #selector(EditorViewController.closeNavigationControllerModal))

		var viewControllers = navigationController.viewControllers
		viewControllers[viewControllers.count - 1] = viewController
		navigationController.setViewControllers(viewControllers, animated: false)
	}

	private func showError() {
		activityIndicator.stopAnimating()
		
		let billboard = BillboardView()
		billboard.translatesAutoresizingMaskIntoConstraints = false
		billboard.illustrationView.image = UIImage(named: "Not Found")
		billboard.titleLabel.text = LocalizedString.notFoundHeading.string
		billboard.subtitleLabel.text = LocalizedString.notFoundMessage.string
		view.addSubview(billboard)
		
		NSLayoutConstraint.activate([
			billboard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			billboard.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
			billboard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
		])
		
		title = LocalizedString.notFoundTitle.string
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: LocalizedString.closeCommand.string, style: .plain, target: self, action: #selector(close))
	}
	
	@objc private func close() {
		dismissViewController(animated: true, completion: nil)
	}
}
