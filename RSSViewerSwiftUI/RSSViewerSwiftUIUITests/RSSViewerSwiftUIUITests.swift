//
//  RSSViewerSwiftUIUITests.swift
//  RSSViewerSwiftUIUITests
//
//  Created by Marina Huber on 14.02.2025..
//

import XCTest
@testable import RSSViewerSwiftUI

final class RSSViewerSwiftUIUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["-UITest"]
        app.launch()
    }

    override func tearDown() {
        app = nil

        super.tearDown()
    }

    @MainActor
    func testAddAndDeleteNewRSSFeed() {
            /// Open add new feed popup
        app.buttons["Add New Feed"].tap()
            /// Clear existing cells, if any
        let cells = app.collectionViews["feedList"].cells
            /// Check if feed was added to the list
        let addedCell = cells.element(boundBy: 0)
        XCTAssertTrue(addedCell.waitForExistence(timeout: 1))

            /// Clear feed list
        clearFeedList(cells: cells)
    }

    private func clearFeedList(cells: XCUIElementQuery) {
        for _ in 0..<cells.allElementsBoundByAccessibilityElement.count {
            cells.element(boundBy: 0).swipeLeft()
            app.otherElements.buttons["Delete"].firstMatch.tap()
        }
        XCTAssertTrue(cells.count == 0, "Feed list not empty")
    }
}
