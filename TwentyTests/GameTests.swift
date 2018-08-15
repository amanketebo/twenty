//
//  TwentyTests.swift
//  TwentyTests
//
//  Created by Amanuel Ketebo on 8/14/18.
//  Copyright © 2018 Amanuel Ketebo. All rights reserved.
//

import XCTest
@testable import Twenty

class GameTests: XCTestCase {
    var game: Game!

    override func setUp() {
        let playerOne = Player()
        let playerTwo = Player()
        self.game = Game(playerOne: playerOne, playerTwo: playerTwo)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShouldGoToOvertime() {
        // Same points and same over game limit status [true]
        game.playerOne.currentGamePoints = 5
        game.playerTwo.currentGamePoints = 5
        game.playerOne.isOverGameLimit = true
        game.playerTwo.isOverGameLimit = true

        XCTAssert(game.shouldGoToOvertime == true)

        // Same points and same over game limit status [false]
        game.playerOne.currentGamePoints = 5
        game.playerTwo.currentGamePoints = 5
        game.playerOne.isOverGameLimit = false
        game.playerTwo.isOverGameLimit = false

        XCTAssert(game.shouldGoToOvertime == true)

        // Same points and different over game limit status
        game.playerOne.currentGamePoints = 5
        game.playerTwo.currentGamePoints = 5
        game.playerOne.isOverGameLimit = false
        game.playerTwo.isOverGameLimit = true

        XCTAssert(game.shouldGoToOvertime == false)

        // Different points and same over game limit status [true]
        game.playerOne.currentGamePoints = 1
        game.playerTwo.currentGamePoints = 5
        game.playerOne.isOverGameLimit = true
        game.playerTwo.isOverGameLimit = true

        XCTAssert(game.shouldGoToOvertime == false)

        // Different points and same over game limit status [false]
        game.playerOne.currentGamePoints = 1
        game.playerTwo.currentGamePoints = 5
        game.playerOne.isOverGameLimit = false
        game.playerTwo.isOverGameLimit = false

        XCTAssert(game.shouldGoToOvertime == false)

        // Different points and different over game limit status
        game.playerOne.currentGamePoints = 1
        game.playerTwo.currentGamePoints = 5
        game.playerOne.isOverGameLimit = true
        game.playerTwo.isOverGameLimit = false

        XCTAssert(game.shouldGoToOvertime == false)
    }

    func testShouldEndSeries() {
        game.winsNeeded = 2

        game.playerOne.seriesGamesWon = 1
        game.playerTwo.seriesGamesWon = 1
        XCTAssert(game.shouldEndSeries == false)

        game.playerOne.seriesGamesWon = 1
        game.playerTwo.seriesGamesWon = 2
        XCTAssert(game.shouldEndSeries == true)

        game.playerOne.seriesGamesWon = 2
        game.playerTwo.seriesGamesWon = 2
        XCTAssert(game.shouldEndSeries == true)
    }

    func testWinnersName() {
        let playerOneName = "Robert Horry"
        let playerTwoName = "Dereck Fisher"

        game.playerOne.name = playerOneName
        game.playerTwo.name = playerTwoName
        game.winsNeeded = 2

        game.playerOne.seriesGamesWon = 2
        game.playerTwo.seriesGamesWon = 1
        XCTAssert(game.winnersName == playerOneName)

        game.playerOne.seriesGamesWon = 1
        game.playerTwo.seriesGamesWon = 2
        XCTAssert(game.winnersName == playerTwoName)

        // TODO: Fix this test after making winnersName return an optional string
        game.playerOne.seriesGamesWon = 0
        game.playerTwo.seriesGamesWon = 0
        XCTAssert(game.winnersName == "")
    }
}
