//
//  StackViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 6/25/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

class StackViewController: UIViewController {
	
	// MARK: - Properties
	
	let stackView: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .Vertical
		view.alignment = .Fill
		return view
	}()
	
	private var centerYConstraint: NSLayoutConstraint? {
		willSet {
			guard let old = centerYConstraint else { return }
			NSLayoutConstraint.deactivateConstraints([old])
		}
		
		didSet {
			guard let new = centerYConstraint else { return }
			NSLayoutConstraint.activate([new])
		}
	}
	
	private var keyboardFrame: CGRect? {
		didSet {
			keyboardFrameDidChange()
		}
	}
	
	private var visible = false
	
	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = Swatch.white
		view.addSubview(stackView)
		
		let width = stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
		width.priority = UILayoutPriorityDefaultHigh
		
		let top = stackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 64)
		top.priority = UILayoutPriorityDefaultLow
		
		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			top,
			width,
			stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 400)
		])
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
		keyboardFrameDidChange()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		DispatchQueue.main.async { [weak self] in
			self?.visible = true
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		visible = false
	}

	
	// MARK: - Private
	
	@objc private func keyboardWillChangeFrame(notification: NSNotification) {
		guard let dictionary = notification.userInfo as? [String: Any],
			let duration = dictionary[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
			let curve = (dictionary[UIKeyboardAnimationCurveUserInfoKey] as? Int).flatMap(UIViewAnimationCurve.init),
			let rect = (dictionary[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
		else { return }
		
		let frame = view.convertRect(rect, fromView: nil)
		
		let change = { [weak self] in
			self?.keyboardFrame = frame
			self?.view.layoutIfNeeded()
		}
		
		if visible {
			UIView.beginAnimations(nil, context: nil)
			UIView.setAnimationDuration(duration)
			UIView.setAnimationCurve(curve)
			change()
			UIView.commitAnimations()
		} else {
			UIView.performWithoutAnimation(change)
		}
	}
	
	private func keyboardFrameDidChange() {
		guard let keyboardFrame = keyboardFrame else {
			centerYConstraint = stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
			return
		}
		
		var rect = view.bounds
		rect.size.height -= rect.intersect(keyboardFrame).height
		rect.origin.y += UIApplication.sharedApplication().statusBarFrame.size.height
		rect.size.height -= UIApplication.sharedApplication().statusBarFrame.size.height
		
		let contstraint = stackView.centerYAnchor.constraint(equalTo: view.topAnchor, constant: rect.midY)
		contstraint.priority = UILayoutPriorityDefaultHigh
		
		centerYConstraint = contstraint
	}
}
