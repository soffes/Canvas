//
//  RemoteCursorsController.swift
//  CanvasCore
//
//  Created by Sam Soffes on 8/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import X

public protocol RemoteCursorsControllerDelegate: class {
	func remoteCursorsController(controller: RemoteCursorsController, rectsForCursor cursor: Cursor) -> [CGRect]?
}


/// Controller for background and foreground views for drawing remote cursors.
public final class RemoteCursorsController {

	// MARK: - Types

	private struct RemoteCursor {
		let username: String
		let color: Color
		var cursor: Cursor
		var lineLayers = [CALayer]()

		let usernameLabel: UILabel = {
			let label = UILabel()
			label.font = .boldSystemFontOfSize(8)
			label.textColor = Swatch.black
			label.textAlignment = .Center
			return label
		}()

		var labelLayer: CALayer {
			return usernameLabel.layer
		}

		var layers: [CALayer] {
			return lineLayers + [labelLayer]
		}

		init(username: String, color: UIColor, cursor: Cursor) {
			self.username = username
			self.color = color
			self.cursor = cursor

			usernameLabel.backgroundColor = color
			usernameLabel.text = username

			// Disable implict position animations
			usernameLabel.layer.actions = [
				"bounds": NSNull(),
				"position": NSNull()
			]
		}
	}


	// MARK: - Initializers

	public init() {}
	

	// MARK: - Properties

	public weak var delegate: RemoteCursorsControllerDelegate?

	public var contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
		didSet {
			updateLayout()
		}
	}

	public let backgroundView: UIView = {
		let view = UIView()
		view.userInteractionEnabled = false
		view.backgroundColor = .whiteColor() // TODO: Get from theme
		return view
	}()

	public let foregroundView: UIView = {
		let view = UIView()
		view.userInteractionEnabled = false
		view.backgroundColor = .clearColor()
		return view
	}()

	// TODO: Get colors from theme
	private let colors = [
		Color(red: 250 / 255, green: 227 / 255, blue: 224 / 255, alpha: 1),
		Color(red: 250 / 255, green: 242 / 255, blue: 178 / 255, alpha: 1),
		Color(red: 236 / 255, green: 183 / 255, blue: 235 / 255, alpha: 1),
		Color(red: 1, green: 226 / 255, blue: 184 / 255, alpha: 1),
		Color(red: 196 / 255, green: 220 / 255, blue: 225 / 255, alpha: 1),
		Color(red: 1, green: 211 / 255, blue: 200 / 255, alpha: 1)
	]

	// Set of all lowercased usernames that we've seen. We use this to increment the color when a new user joins.
	private var usernames = Set<String>()

	// Mapping of lowercased usernames to a remote cursor model.
	private var remoteCursors = [String: RemoteCursor]()


	// MARK: - Updating

	public func change(username username: String, cursor: Cursor) {
		let key = username.lowercaseString

		// Track this username
		usernames.insert(key)

		var remoteCursor: RemoteCursor

		if var current = remoteCursors[key] {
			if current.cursor == cursor {
				remoteCursors[key] = layoutLayers(remoteCursor: current)
				return
			}
			current.cursor = cursor
			remoteCursor = current
		} else {
			remoteCursor = RemoteCursor(username: username, color: colors[usernames.count % colors.count], cursor: cursor)
		}

		// Layout updated cursor
		remoteCursor = layoutLayers(remoteCursor: remoteCursor)
		remoteCursors[key] = remoteCursor

		// Animate label
		let animation = CABasicAnimation(keyPath: "opacity")
		animation.fillMode = kCAFillModeForwards
		animation.removedOnCompletion = false
		animation.duration = 0.2
		animation.beginTime = CACurrentMediaTime() + 1
		animation.toValue = 0
		remoteCursor.labelLayer.removeAnimationForKey("opacity")
		remoteCursor.labelLayer.addAnimation(animation, forKey: "opacity")
	}

	public func leave(username username: String) {
		guard let remoteCursor = remoteCursors.removeValueForKey(username.lowercaseString) else { return }
		removeLayers(remoteCursor: remoteCursor)
	}

	public func updateLayout() {
		for (key, remoteCursor) in remoteCursors {
			remoteCursors[key] = layoutLayers(remoteCursor: remoteCursor)
		}
	}


	// MARK: - Private

	private func removeLayers(remoteCursor remoteCursor: RemoteCursor) {
		remoteCursor.layers.forEach({ $0.removeFromSuperlayer() })
	}

	private func layoutLayers(remoteCursor remoteCursor: RemoteCursor) -> RemoteCursor {
		var remoteCursor = remoteCursor
		remoteCursor.lineLayers.forEach { $0.removeFromSuperlayer() }
		remoteCursor.lineLayers = []

		guard let rects = delegate?.remoteCursorsController(self, rectsForCursor: remoteCursor.cursor) else {
			remoteCursor.labelLayer.removeFromSuperlayer()
			return remoteCursor
		}

		// Setup line layers
		remoteCursor.lineLayers = rects.map {
			let layer = CALayer()
			layer.backgroundColor = remoteCursor.color.CGColor

			var rect = $0
			rect.origin.x += contentInset.left
			rect.origin.y += contentInset.top
			rect.size.width = max(2, rect.size.width)
			layer.frame = rect

			return layer
		}

		// Add the line layers to the view
		remoteCursor.lineLayers.forEach(backgroundView.layer.addSublayer)

		// Add the label layer if needed
		if remoteCursor.labelLayer.superlayer == nil {
			foregroundView.layer.addSublayer(remoteCursor.labelLayer)
		}

		// Layout the label layer
		let firstLine = remoteCursor.lineLayers[0]

		remoteCursor.usernameLabel.sizeToFit()

		var size = remoteCursor.usernameLabel.frame.size
		size.width += 4
		size.height += 4

		remoteCursor.labelLayer.frame = CGRect(
			x: firstLine.frame.minX,
			y: firstLine.frame.minY - size.height,
			width: size.width,
			height: size.height
		)
		
		return remoteCursor
	}
}
