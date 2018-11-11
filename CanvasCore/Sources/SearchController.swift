import Foundation

/// Object for coordinating searches
public final class SearchController: NSObject {

	// MARK: - Properties

	/// Results are delivered to this callback
	public var callback: (([Canvas]) -> Void)?

	private let semaphore = DispatchSemaphore(value: 0)

	private var nextQuery: String? {
		didSet {
			query()
		}
	}

	// MARK: - Initializers

	public override init() {
		super.init()
		semaphore.signal()
	}

	// MARK: - Search

	public func search(withQuery query: String) {
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

	private func search(query: String, completion: ([Canvas]) -> Void) {
		// TODO: Search
		completion([
			Canvas(id: "-1", title: "Search Result", summary: "This is a dummy canvas to demo search results", createdAt: Date(), updatedAt: nil, archivedAt: nil),
			Canvas(id: "-2", title: "Another One", summary: "Major Key", createdAt: Date(), updatedAt: nil, archivedAt: nil)
		])
	}
}

#if !os(OSX)
import UIKit

extension SearchController: UISearchResultsUpdating {
	public func updateSearchResults(for searchController: UISearchController) {
		guard let text = searchController.searchBar.text else {
			return
		}
		search(withQuery: text)
	}
}
#endif
