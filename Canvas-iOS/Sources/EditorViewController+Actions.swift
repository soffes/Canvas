//
//  EditorViewController+Actions.swift
//  Canvas
//
//  Created by Sam Soffes on 5/5/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

extension EditorViewController {
	func closeNavigationControllerModal() {
		navigationController?.dismissViewControllerAnimated(true, completion: nil)
	}

	@objc func close(_ sender: UIAlertAction? = nil) {
		NotificationCenter.default.postNotificationName(EditorViewController.willCloseNotificationName, object: nil)
		dismissDetailViewController(self)
	}
	
	@objc func dismissKeyboard() {
		textView.resignFirstResponder()
	}

	@objc func more() {
		// If you can't edit the document, all you can do is share.
		if !canvas.isWritable {
			share(sender)
			return
		}

		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

		// Archive/unarchive
		if canvas.archivedAt == nil {
			// TODO: Localize
			actionSheet.addAction(UIAlertAction(title: "Archive or Delete…", style: .Destructive, handler: { [weak self] _ in
				self?.showArchive(sender)
			}))
		} else {
			actionSheet.addAction(UIAlertAction(title: LocalizedString.UnarchiveButton.string, style: .Default, handler: unarchive))
		}

		// Enable/disable public edits
		if canvas.isPublicWritable {
			actionSheet.addAction(UIAlertAction(title: LocalizedString.DisablePublicEditsButton.string, style: .Default, handler: disablePublicEdits))
		} else {
			actionSheet.addAction(UIAlertAction(title: LocalizedString.EnablePublicEditsButton.string, style: .Default, handler: enablePublicEdits))
		}

		// Participants
		// TODO: Localize
		actionSheet.addAction(UIAlertAction(title: "Participants…", style: .Default, handler: showParticipants))

		// Share
		actionSheet.addAction(UIAlertAction(title: LocalizedString.ShareButton.string, style: .Default) { [weak self] _ in
			self?.share(sender)
		})

		// Cancel
		actionSheet.addAction(UIAlertAction(title: LocalizedString.Cancel.string, style: .Cancel, handler: nil))

		present(actionSheet: actionSheet, sender: sender)
	}

	@objc func destroy(sender: Any?) {
		APIClient(account: account).destroyCanvas(id: canvas.id)
		close()
	}

	@objc func share(sender: Any?) {
		dismissKeyboard(sender)
		
		guard let item = CanvasActivitySource(canvas: canvas) else { return }

		let activities = [
			SafariActivity(),
			ChromeActivity(),
			CopyLinkActivity(),
			CopyRepresentationActivity(representation: .markdown),
			CopyRepresentationActivity(representation: .html),
			CopyRepresentationActivity(representation: .json)
		]

		let actionSheet = UIActivityViewController(activityItems: [item], applicationActivities: activities)
		actionSheet.excludedActivityTypes = [
			UIActivityTypePrint,
			UIActivityTypeCopyToPasteboard,
			UIActivityTypeAssignToContact,
			UIActivityTypeSaveToCameraRoll,
			UIActivityTypeAddToReadingList,
			UIActivityTypePostToFlickr,
			UIActivityTypePostToVimeo,
			UIActivityTypeOpenInIBooks
		]

		present(actionSheet: actionSheet, sender: sender)
	}
	
	@objc func check() {
		textController.toggleChecked()
	}
	
	@objc func indent() {
		textController.indent()
	}
	
	@objc func outdent() {
		textController.outdent()
	}
	
	@objc func bold() {
		textController.bold()
	}
	
	@objc func italic() {
		textController.italic()
	}
	
	@objc func inlineCode() {
		textController.inlineCode()
	}
	
	@objc func insertLineAfter() {
		textController.insertLineAfter()
	}
	
	@objc func insertLineBefore() {
		textController.insertLineBefore()
	}
	
	@objc func deleteLine() {
		textController.deleteLine()
	}

	@objc func swapLineUp() {
		textController.swapLineUp()
	}

	@objc func swapLineDown() {
		textController.swapLineDown()
	}
	
	@objc func reload(sender: UIAlertAction? = nil) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		title = LocalizedString.Connecting.string
		textController.connect()
	}
}
