//
//  SearchController.swift
//  CanvasCore
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015–2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CanvasKit

/// Object for coordinating searches
public final class SearchController: NSObject {

	// MARK: - Properties

	public let organizationID: String

	/// Results are delivered to this callback
	public var callback: ([Canvas] -> Void)?

	private let semaphore = dispatch_semaphore_create(0)

	private var nextQuery: String? {
		didSet {
			query()
		}
	}

	private let client: APIClient


	// MARK: - Initializers

	public init(client: APIClient, organizationID: String) {
		self.client = client
		self.organizationID = organizationID

		super.init()

		dispatch_semaphore_signal(semaphore)
	}


	// MARK: - Search

	public func search(withQuery query: String) {
		nextQuery = query.isEmpty ? nil : query
	}


	// MARK: - Private

	private func query() {
		guard nextQuery != nil else { return }

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { [weak self] in
			guard let semaphore = self?.semaphore else { return }

			dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

			guard let query = self?.nextQuery,
				client = self?.client,
				organizationID = self?.organizationID
			else {
				dispatch_semaphore_signal(semaphore)
				return
			}

			self?.nextQuery = nil

			let callback = self?.callback

			client.searchCanvases(organizationID: organizationID, query: query) { result in
				dispatch_async(dispatch_get_main_queue()) {
					switch result {
					case .Success(let canvases): callback?(canvases)
					default: break
					}
				}

				dispatch_semaphore_signal(semaphore)
			}
		}
	}
}


#if !os(OSX)
	import UIKit

	extension SearchController: UISearchResultsUpdating {
		public func updateSearchResultsForSearchController(searchController: UISearchController) {
			guard let text = searchController.searchBar.text else { return }
			search(withQuery: text)
		}
	}
#endif
