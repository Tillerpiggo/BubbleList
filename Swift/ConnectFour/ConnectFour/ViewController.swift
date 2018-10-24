//
//  ViewController.swift
//  ConnectFour
//
//  Created by Tyler Gee on 9/18/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet var chipArray: [UIImageView]!
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet var dropButtons: [UIButton]!
    @IBOutlet weak var playAgainButton: UIButton!
    
    var board = ConnectFourBoard()
    var redWins: Int = 0
    var blackWins: Int = 0
    
    @IBOutlet weak var redWinsLabel: UILabel!
    @IBOutlet weak var blackWinsLabel: UILabel!
    
    @IBOutlet weak var dropChip: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //test()
        board.clearBoard()
        playAgainButton.isHidden = true
    }
    
    var player: Player = Player.red
    
    func test() {
        let board = ConnectFourBoard()
        print(board)
        renderBoard(board)
        _ = board.addChip(.red, toColumn: 3)
        print(board)
        renderBoard(board)
        _ = board.addChip(.black, toColumn: 3)
        print(board)
        renderBoard(board)
        _ = board.addChip(.red, toColumn: 2)
        print(board)
        renderBoard(board)
    }
    
    func renderBoard(_ connectFourBoard: ConnectFourBoard) {
        for (column, columnArray) in connectFourBoard.board.enumerated() {
            for (row, chip) in columnArray.enumerated() {
                switch chip {
                case .red:
                    chipArray[indexOfChip(fromPosition: Position(row: row, column: column))].image = UIImage(named: "redCircle")
                case .black:
                    chipArray[indexOfChip(fromPosition: Position(row: row, column: column))].image = UIImage(named: "blackCircle")
                case .none:
                    chipArray[indexOfChip(fromPosition: Position(row: row, column: column))].image = nil
                }
            }
        }
    }
    
    func renderChip(_ chip: Chip, position: Position) {
        renderDrop(ofChip: chip, toPosition: position) { (_) in
            switch chip {
            case .red:
                self.chipArray[self.indexOfChip(fromPosition: position)].image = UIImage(named: "redCircle")
            case .black:
                self.chipArray[self.indexOfChip(fromPosition: position)].image = UIImage(named: "blackCircle")
            case .none:
                self.chipArray[self.indexOfChip(fromPosition: position)].image = nil
            }
        }
    }
    
    func renderDrop(ofChip chip: Chip, toPosition position: Position, completion: @escaping (Bool) -> Void) {
        switch chip {
        case .red:
            dropChip.image = UIImage(named: "redCircle")
        case .black:
            dropChip.image = UIImage(named: "blackCircle")
        default:
            dropChip.image = nil
        }
        
        let animationCompletion: (Bool) -> Void = { (bool) in
            completion(bool)
            self.dropChip.image = nil
            self.dropChip.isHidden = true
            self.dropChip.transform = CGAffineTransform(translationX: 0, y: 0)
            
            for dropButton in self.dropButtons {
                dropButton.isHidden = false
            }
        }
        
        let buttonDestinationView = self.dropButtons[position.column]
        let destinationView = self.chipArray[self.indexOfChip(fromPosition: position)]
        
        let moveTransform = CGAffineTransform(translationX: buttonDestinationView.center.x - self.dropChip.center.x + 15.75, y: buttonDestinationView.center.y - self.dropChip.center.y + 200)
        
        let dropX = buttonDestinationView.center.x - self.dropChip.center.x + 15.75
        let dropY = destinationView.center.y - self.dropChip.center.y + 200
        
        print("DropX: \(dropX), DropY: \(dropY)")
        
        let dropTransform = CGAffineTransform(translationX: dropX , y: dropY)
        
        for dropButton in dropButtons {
            dropButton.isHidden = true
        }
        UIView.setAnimationCurve(.easeIn)
        UIView.animate(withDuration: 0.05, animations: {
            self.dropChip.isHidden = true
            self.dropChip.transform = moveTransform
        }, completion: { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                self.dropChip.isHidden = false
                self.dropChip.transform = dropTransform
            }, completion: animationCompletion)
        })
    }
    
    func indexOfChip(fromPosition position: Position) -> Int {
        let indexOfChip = ((position.column + 1) * 6 - position.row) - 1
        
        return indexOfChip
    }
    
    @IBAction func playAgainButtonPressed(_ sender: Any) {
        board.clearBoard()
        renderBoard(board)
        
        winnerLabel.text = ""
        playAgainButton.isHidden = true
        
        for dropButton in dropButtons {
            dropButton.isHidden = false
        }
    }
    
    @IBAction func dropButtonPressed(_ sender: UIButton) {
        let buttonText = sender.titleLabel?.text ?? "1"
        let buttonNumber = Int(buttonText)! - 1
        let position = board.addChip(player.chip, toColumn: buttonNumber)
        renderChip(player.chip, position: position)
        
        if let winner = board.winner {
            let winnerText = "\(winner.name) won!"
            winnerLabel.text = winnerText
            
            switch winner {
            case .red:
                redWins += 1
                redWinsLabel.text = "Red: \(redWins)"
            case .black:
                blackWins += 1
                blackWinsLabel.text = "Black: \(blackWins)"
            }
            
            playAgainButton.isHidden = false
            
            for dropButton in dropButtons {
                dropButton.isHidden = true
            }
        }
        
        if player == .red {
            player = .black
        } else {
            player = .red
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
}

