//: Playground - noun: a place where people can play

import UIKit

class ConnectFourBoard: CustomStringConvertible {
    let numberOfColumns = 7
    let numberOfRows = 6
    
    var board: [[Chip]] = [[Chip]]()
    var winner: Player?
    
    var description: String {
        var boardString: String = ""
        for row in board {
            for column in row {
                boardString += column.string
                boardString += " "
            }
            boardString += "\n"
        }
        
        return boardString
    }
    
    func addChip(_ chip: Chip, toColumn column: Int) {
        guard chip == .red || chip == .none, column >= 0, column < 7 else { return }
        
        var columnArray = board[column]
        var chipRow: Int = 0
        
        var rowIsFull = true
        
        for (index, row) in columnArray.enumerated() {
            if row == .none {
                columnArray[index] = chip
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
    
    func didConnectFourInDirection(rowOffset: Int, columnOffset: Int, fromPosition position: Position, chip: Chip) -> Bool { // Position is (row, column)
        var numberInARow: Int = 1
        
        while numberInARow < 4 {
            let row = position.row + rowOffset
            let column = position.column + columnOffset
            
            if positionIsOnBoard(position) && board[column][row] == chip {
                numberInARow += 1
                
                if numberInARow >= 4 {
                    return true
                }
            } else {
                return false
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
        board = [[Chip]](repeating: [Chip](repeating: .none, count: numberOfColumns), count: numberOfRows)
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



let board = ConnectFourBoard()
print(board)
board.addChip(.red, toColumn: 3)
print(board)

