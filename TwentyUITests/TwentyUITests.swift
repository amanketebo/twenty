//
//  TwentyUITests.swift
//  TwentyUITests
//
//  Created by Amanuel Ketebo on 6/6/18.
//  Copyright © 2018 Amanuel Ketebo. All rights reserved.
//

import XCTest

class TwentyUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let app = XCUIApplication()
        snapshot("opening")
        app.staticTexts["NEW GAME"].tap()

        let playerOneTextField = app.textFields["Player 1"]
        let playerTwoTextField = app.textFields["Player 2"]


        playerOneTextField.tap()
        playerOneTextField.typeText("Amanuel")
        playerTwoTextField.tap()
        playerTwoTextField.typeText("Kidous")
        snapshot("players")

        var element = app.otherElements.containing(.navigationBar, identifier: "New Game").children(matching: .other).element

        for _ in 0..<6 {
            element = element.children(matching: .other).element
        }

        element.swipeLeft()
        app.buttons["2"].tap()
        app.buttons["START"].tap()
        snapshot("game")
        app.navigationBars["Game 1"].buttons["Exit"].tap()

        let yesImSureButton = app.alerts["Oh no, the stats!"].buttons["Exit"]
        yesImSureButton.tap()

        app.staticTexts["STATISTICS"].tap()
        snapshot("stats")
    }
}
