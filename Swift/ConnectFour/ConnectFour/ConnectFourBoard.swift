//
//  ConnectFourBoard.swift
//  ConnectFour
//
//  Created by Tyler Gee on 9/18/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

class ConnectFourBoard: CustomStringConvertible {
    let numberOfColumns = 7
    let numberOfRows = 6
    
    var board: [[Chip]] = [[Chip]]()
    var winner: Player?
    
    var description: String {
        var boardString: String = ""
        
        for row in (0..<numberOfRows).reversed() {
            for column in (0..<numberOfColumns) {
                boardString.append(board[column][row].string)
                boardString.append(" ")
            }
            boardString.append("\n")
        }
        
        return boardString
    }
    
    func addChip(_ chip: Chip, toColumn column: Int) -> Position {
        guard chip == .red || chip == .black, column >= 0, column < 7 else { return Position(row: 0, column: 0) }
        
        let columnArray = board[column]
        var chipRow: Int = 0
        
        var rowIsFull = true
        
        for (index, row) in columnArray.enumerated() {
            if row == .none {
                board[column][index] = chip // Issue here - not setting at correction location
                chipRow = index
                rowIsFull = false
                break
            }
        }
        
        if rowIsFull {
            print("Row is full; can't add chip")
        }
        
        if chipDidConnectFour(chip, chipPosition: Position(row: chipRow, column: column)) {
            winner = Player(chip: chip)
        }
        
        return Position(row: chipRow, column: column)
    }
    
    func chipDidConnectFour(_ chip: Chip, chipPosition: Position) -> Bool { // chipPosition is (row, column)
        for rowOffset in -1...1 {
            for columnOffset in -1...1 {
                if didConnectFourInDirection(rowOffset: rowOffset, columnOffset: columnOffset, fromPosition: chipPosition, chip: chip) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func didConnectFourInDirection(rowOffset rowOff: Int, columnOffset columnOff: Int, fromPosition position: Position, chip: Chip) -> Bool { // Position is (row, column)
        var numberInARow: Int = 1
        
        var rowOffset = rowOff
        var columnOffset = columnOff
        
        guard rowOffset != 0 || columnOffset != 0 else { return false }
        
        while numberInARow < 4 {
            let row = position.row + rowOffset * numberInARow
            let column = position.column + columnOffset * numberInARow
            
            if positionIsOnBoard(Position(row: row, column: column)) && board[column][row] == chip {
                numberInARow += 1
                
                if numberInARow >= 4 {
                    return true
                }
            } else {
                if rowOffset == rowOff && columnOffset == columnOff {
                    rowOffset = -1 * rowOff
                    columnOffset = -1 * columnOff
                } else {
                    return false
                }
            }
        }
        
        return false
    }
    
    func positionIsOnBoard(_ position: Position) -> Bool {
        if position.row < numberOfRows && position.row >= 0 && position.column < numberOfColumns && position.column >= 0 {
            return true
        } else {
            return false
        }
    }
    
    func clearBoard() {
        board = [[Chip]](repeating: [Chip](repeating: .none, count: numberOfRows), count: numberOfColumns)
        winner = nil
    }
    
    init() {
        clearBoard()
    }
}

enum Chip {
    case black
    case red
    case none
    
    var string: String {
        switch self {
        case .black:
            return "B"
        case .red:
            return "R"
        case .none:
            return "0"
        }
    }
}

enum Player {
    case black
    case red
    
    var chip: Chip {
        switch self {
        case .red:
            return Chip.red
        case .black:
            return Chip.black
        }
    }
    
    var name: String {
        switch self {
        case .red:
            return "Red Player"
        case .black:
            return "Black Player"
        }
    }
    
    init?(chip: Chip) {
        if chip == .red {
            self = .red
        } else if chip == .black {
            self = .black
        } else {
            print("Can't initialize a player with a chip of type .none")
            return nil
        }
    }
}

struct Position {
    var row: Int
    var column: Int
}


