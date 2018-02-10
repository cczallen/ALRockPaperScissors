//
//  ViewController.swift
//  ALRockPaperScissors
//
//  Created by ALLENMAC on 2017/8/18.
//  Copyright © 2017年 ALLENMAC. All rights reserved.
//

import UIKit
import GameplayKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: - Definition
    
    @IBOutlet var actionButtons: [UIButton]!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var aiActionLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    var history: [GameResult] = []
    var avPlayer: AVQueuePlayer = AVQueuePlayer()
    
    enum GameAction: Int {
        case rock
        case scissors
        case paper
    }
    
    enum GameResult: Int {
        case win
        case lose
        case deuce
    }
    
    
    
    // MARK: - override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.becomeFirstResponder() // To get shake gesture

        DispatchQueue.main.asyncAfter(deadline: .now() + (0.5), execute: {
            self.welcomeAnimation()
        })
    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let alertControlelr = UIAlertController(title: "Game", message: "Reset?", preferredStyle: UIAlertControllerStyle.alert)
            alertControlelr.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            alertControlelr.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.default, handler: { (_) in
                self.reset()
            }))
            self.present(alertControlelr, animated: true, completion: nil)
        }
    }

    
    
    // MARK: - IBAction
    
    @IBAction func rock(_ sender: Any) {
        // 👊
        run(action: GameAction.rock, sender: sender)
    }

    @IBAction func scissors(_ sender: Any) {
        // ✌
        run(action: GameAction.scissors, sender: sender)
    }
    
    @IBAction func paper(_ sender: Any) {
        // ✋
        run(action: GameAction.paper, sender: sender)
    }
    
    
    
    // MARK: - Action
    
    func welcomeAnimation() {
        for (index, actionButton) in self.actionButtons.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.1 * Double(index)), execute: {
                self.bounce(view: actionButton)
            })
        }
    }
    
    func bounce(view: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            let scale: CGFloat = 2
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
            
        }) { (_) in
            UIView.animate(withDuration: 0.2, animations: {
                view.transform = CGAffineTransform.identity
            })
        }
    }
    
    func reset() {
        self.resultLabel.text = "Result"
        self.history.removeAll()
        self.historyLabel.text = "History"
        self.welcomeAnimation()
    }
    
    func run(action: GameAction, sender: Any) {
        // result
        print("Me: \(action)")
        let aiAction: GameAction = self.createAiAction()
        print("AI: \(aiAction)")
        
        let result: GameResult = self.getResult(myAction: action, aiAction: aiAction)
        
        // animation
        var actionString = ""
        switch aiAction {
        case .rock:
            actionString = "👊"
        case .scissors:
            actionString = "✌"
        case .paper:
            actionString = "✋"
        }
        self.aiActionLabel.text = actionString
        bounce(view: self.aiActionLabel)
        
        let view: UIView = sender as! UIView
        bounce(view: view)
        
        // sound
        self.avPlayer.pause()
        self.avPlayer.removeAllItems()
        let actionPlayerItem = self.playerItem(soundFileName: "\(aiAction)")
        let resultPlayerItem = self.playerItem(soundFileName: "\(result)")
        self.avPlayer.insert(actionPlayerItem, after: nil)
        self.avPlayer.insert(resultPlayerItem, after: actionPlayerItem)
        self.avPlayer.play()
        
        // resultLabel
        print(result)
        self.resultLabel.text = "\(result)"
        
        // historyLabel
        self.history.append(result)
        let winHistory = self.history.filter { (eachResult: GameResult) -> Bool in
            return eachResult == .win
        }
        let loseHistory = self.history.filter { (eachResult: GameResult) -> Bool in
            return eachResult == .lose
        }
        let deuceHistory = self.history.filter { (eachResult: GameResult) -> Bool in
            return eachResult == .deuce
        }
        self.historyLabel.text = "\(self.history.count)戰 \(winHistory.count)勝\(loseHistory.count)輸\(deuceHistory.count)平手"
        
        // !!
        if self.history.count > 30 {
            var img: UIImage?
            
            self.actionButtons.first?.setTitle("", for: UIControlState.normal)
            img = UIImage.init(named: "\(GameAction.rock)")
            self.actionButtons.first?.setBackgroundImage(img, for: UIControlState.normal)
            
            self.actionButtons[1].setTitle("", for: UIControlState.normal)
            img = UIImage.init(named: "\(GameAction.scissors)")
            self.actionButtons[1].setBackgroundImage(img, for: UIControlState.normal)
            
            self.actionButtons[2].setTitle("", for: UIControlState.normal)
            img = UIImage.init(named: "\(GameAction.paper)")
            self.actionButtons[2].setBackgroundImage(img, for: UIControlState.normal)
        }
    }
    
    
    
    // MARK: Utility
    
    func createAiAction() -> GameAction {
        let aiAction: GameAction =  GameAction(rawValue: GKRandomDistribution(lowestValue: 0, highestValue: 2).nextInt())!
        return aiAction
    }
    
    func getResult(myAction: GameAction, aiAction: GameAction) -> GameResult {
        var result: GameResult
        switch myAction {
        case .rock:
            switch aiAction {
            case .rock:
                result = GameResult.deuce
            case .scissors:
                result = GameResult.win
            case .paper:
                result = GameResult.lose
            }
            
        case .scissors:
            switch aiAction {
            case .rock:
                result = GameResult.lose
            case .scissors:
                result = GameResult.deuce
            case .paper:
                result = GameResult.win
            }
            
        case .paper:
            switch aiAction {
            case .rock:
                result = GameResult.win
            case .scissors:
                result = GameResult.lose
            case .paper:
                result = GameResult.deuce
            }
        }
        
        return result
    }
    
    func playerItem(soundFileName: String) -> AVPlayerItem {
        let soundURL: URL = URL(fileURLWithPath: Bundle.main.path(forResource: soundFileName, ofType: "m4a")!)
        let playerItem = AVPlayerItem(url: soundURL)
        return playerItem
    }
}

