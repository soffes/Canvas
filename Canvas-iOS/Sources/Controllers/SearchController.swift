import UIKit

/// Object for coordinating searches
final class SearchController: NSObject {

	// MARK: - Properties

	/// Results are delivered to this callback
	var callback: (([Document]) -> Void)?

	private let semaphore = DispatchSemaphore(value: 0)

	private var nextQuery: String? {
		didSet {
			query()
		}
	}

	// MARK: - Initializers

	override init() {
		super.init()
		semaphore.signal()
	}

	// MARK: - Search

	func search(withQuery query: String) {
		nextQuery = query.isEmpty ? nil : query
	}

	// MARK: - Private

	private func query() {
		guard nextQuery != nil else {
			return
		}

		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			guard let semaphore = self?.semaphore else {
				return
			}

			_ = semaphore.wait(timeout: .distantFuture)

			guard let query = self?.nextQuery, let self = self else {
				semaphore.signal()
				return
			}

			self.nextQuery = nil

			let callback = self.callback
			self.search(query: query) { result in
				DispatchQueue.main.async {
					callback?(result)
				}

				semaphore.signal()
			}
		}
	}

	private func search(query: String, completion: ([Document]) -> Void) {
		// TODO: Search
		completion([])
	}
}

extension SearchController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let text = searchController.searchBar.text else {
			return
		}
		search(withQuery: text)
	}
}
