import Foundation
import XCTest
@testable import clipboard

final class HistoryStoreTests: XCTestCase {
    private var rootURL: URL!

    override func setUpWithError() throws {
        rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("clipboard-tests-\(UUID().uuidString)", isDirectory: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: rootURL)
    }

    @MainActor
    func testPrunesToConfiguredMaximum() {
        let store = HistoryStore(maxItems: 3, rootDirectoryURL: rootURL)

        store.addText("one")
        store.addText("two")
        store.addText("three")
        store.addText("four")

        XCTAssertEqual(store.items.count, 3)
        XCTAssertEqual(store.items.compactMap(\.textContent), ["four", "three", "two"])
    }

    @MainActor
    func testSkipsImmediateDuplicateTextEntry() {
        let store = HistoryStore(maxItems: 10, rootDirectoryURL: rootURL)

        store.addText("same")
        store.addText("same")

        XCTAssertEqual(store.items.count, 1)
    }

    @MainActor
    func testLoadsPersistedHistoryFromDisk() {
        let store = HistoryStore(maxItems: 10, rootDirectoryURL: rootURL)
        store.addText("alpha")
        store.addText("beta")

        let reloaded = HistoryStore(maxItems: 10, rootDirectoryURL: rootURL)
        XCTAssertEqual(reloaded.items.count, 2)
        XCTAssertEqual(reloaded.items.first?.textContent, "beta")
    }
}
