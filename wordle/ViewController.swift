//
//  ViewController.swift
//  wordle
//
//  Created by 方仕賢 on 2022/4/1.
//

import UIKit
import AVFoundation
import AVKit

enum Wrong {
    case notExsist
    case lessThan5
}

class ViewController: UIViewController {
    //顯示字母
    @IBOutlet var letterLabels: [UILabel]!
    //鍵盤
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var enterButton: UIButton!
    
    //目前輸入的單字字母
    var currentLetters = [String](repeating: "", count: 5)
    
    //紀錄目前總字母的顯示為第幾個
    var currentLetterIndex = 0
    
    //記錄按過的按鈕
    var currentButtonIndex = [Int]()
    
    //猜的次數（只算五個字母且包含在題目中的）
    var guessedTimes = 0
    
    //生成一個新的問題
    var newQuestion = Question()
    
    //生成一個新的檢查項目
    let checkedWord = Check()
    
    //說明 view
    @IBOutlet weak var instructionView: UIView!
    
    //結果 view 相關元件
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultView: UIView!
    var emojis = [UILabel]()
    
    //音樂播放相關
    let player = AVPlayer()
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        makeNewQuestion()
        
        playMusic()
    }
    
    func playMusic() {
        let fileUrl = Bundle.main.url(forResource: "music", withExtension: "mp3")!
        let playerItem = AVPlayerItem(url: fileUrl)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    
    @IBAction func playMusic(_ sender: Any) {
        player.play()
        pauseButton.isHidden = true
    }
    
    @IBAction func pauseMusic(_ sender: Any) {
        player.pause()
        pauseButton.isHidden = false
    }
    func makeNewQuestion() {
        checkedWord.question = newQuestion.makeNewQuestion()
    }
    
    func startRotation(label: UILabel) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.y")
        animation.fromValue = 0
        animation.toValue = Double.pi*2
        animation.speed = 0.5
        label.layer.add(animation, forKey: nil)
    }
    
    func showAlert(state: Wrong) {
        var controller = UIAlertController()
        switch state {
        case .notExsist:
            controller = UIAlertController(title: "Not in the List", message: nil, preferredStyle: .alert)
        case .lessThan5:
            controller = UIAlertController(title: "Not enough words", message: nil, preferredStyle: .alert)
        }
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(controller,animated: true, completion: nil)
    }
    
    func enableButtons(readyToEnable: Bool) {
        if readyToEnable == true {
            for i in 0...buttons.count-1 {
                buttons[i].isEnabled = true
            }
            backButton.isEnabled = true
            enterButton.isEnabled = true
            
        } else {
            for i in 0...buttons.count-1 {
                buttons[i].isEnabled = false
            }
            backButton.isEnabled = false
            enterButton.isEnabled = false
        }
    }
    
    //按下 enter
    @IBAction func enter(_ sender: Any) {
        var greenCounts = 0
        var time: Double = 0 //For animation
        
        //檢察是否為五個字
        if currentButtonIndex.count == 5 {
            
            checkedWord.answer = ""
            for letter in currentLetters {
                checkedWord.answer += letter
            }
            
            //是否出現在題目清單
            if checkedWord.checkExistence() == false {
                //不符存在條件跳出警告窗
                showAlert(state: .notExsist)
            } else {
                //讓所有按鈕失去作用
                enableButtons(readyToEnable: false)
                
                //檢查答案
                checkedWord.checkAnswer()
               
                
                for i in 0...currentLetters.count-1 {
                    //在這裡會把顏色給 label
                    
                    buttons[currentButtonIndex[i]].configuration?.baseBackgroundColor = checkedWord.colorBlocks[i]
                    
                    //翻轉 Label
                    _ = Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { _ in
                        self.startRotation(label: self.letterLabels[self.currentLetterIndex-5+i])
                    })
                    
                    //顯示 Label 顏色
                    _ = Timer.scheduledTimer(withTimeInterval: time+0.2, repeats: false, block: { _ in
                        self.letterLabels[self.currentLetterIndex-5+i].backgroundColor = self.checkedWord.colorBlocks[i]
                    })
                    
                    //紀錄顏色
                    if checkedWord.colorBlocks[i] == UIColor.systemGreen {
                        greenCounts += 1
                    }
                    
                    time += 0.2
                }
                
                //紀錄猜的次數
                guessedTimes += 1
                
                //判斷是否出現結果 view
                if greenCounts == 5 {
                    _ = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
                        self.showResult(isWin: true)
                    })
                } else if guessedTimes == 6 && greenCounts != 5 {
                    _ = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
                        self.showResult(isWin: false)
                    })
                }
                
                //更新目前的按鈕及單字
                currentButtonIndex = []
                for i in 0...currentLetters.count-1{
                    currentLetters[i] = ""
                }
                
                //讓所有按鈕恢復作用
                _ = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
                    self.enableButtons(readyToEnable: true)
                })
                
            }
           
        } else {
            //不符字數條件跳出警告窗
            showAlert(state: .lessThan5)
        }
    }
    
    func showResult(isWin: Bool){
        //顯示結果 view
        resultView.isHidden = false
        view.bringSubviewToFront(resultView)
        var index = 0
        
        //利用顏色紀錄顯示方塊 emoji
        for line in 0...((currentLetterIndex+1)/5)-1 {
            for row in 0...4 {
                let emoji = UILabel(frame: CGRect(x: 70+55*row, y: 250+line*55, width: 50, height: 50))
                emoji.font = UIFont.systemFont(ofSize: 50)
                emojis.append(emoji)
                
                switch checkedWord.usedColors[index] {
                case .systemGreen:
                    emoji.text = "🟩"
                case .systemYellow:
                    emoji.text = "🟨"
                default:
                    emoji.text = "⬛️"
                }
                
                resultView.addSubview(emoji)
                index += 1
            }
        }
        
        //判斷玩家輸贏決定敘述
        if isWin {
            if guessedTimes == 1 {
                resultLabel.text = "Wow!\nYou guessed only once!"
            } else if guessedTimes < 6 {
                resultLabel.text = "Congradulations!\nYou guessed \(guessedTimes) times."
            } else if guessedTimes == 6 {
                resultLabel.text = "Phew\n You guessed \(guessedTimes) times."
            }
        } else {
            resultLabel.text = "Opps\n The answer is \(checkedWord.question!)."
        }
    }
    
    func resetGame() {
        currentLetterIndex = 0
        guessedTimes = 0
        checkedWord.usedColors = []
        for i in 0...letterLabels.count-1 {
            letterLabels[i].text = ""
            letterLabels[i].backgroundColor = .darkGray
        }
        for i in 0...buttons.count-1 {
            buttons[i].configuration?.baseBackgroundColor = .systemGray
        }
        makeNewQuestion()
    }
    
    @IBAction func inputLetter(_ sender: UIButton) {
        var buttonIndex = 0
        let letterIndex = currentLetterIndex%5
        
        while sender != buttons[buttonIndex] {
            buttonIndex += 1
        }
        
        if currentButtonIndex.count < 5 {
            currentButtonIndex.append(buttonIndex)
            if let title = buttons[buttonIndex].configuration?.title {
                currentLetters[letterIndex] = title
                letterLabels[currentLetterIndex].text = currentLetters[letterIndex]
                
                currentLetterIndex += 1
            }
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        let letterIndex = (currentLetterIndex-1)%5
        
        if currentButtonIndex.count > 0 {
            currentLetters[letterIndex] = ""
            
            currentButtonIndex.removeLast()
            
            currentLetterIndex -= 1
            letterLabels[currentLetterIndex].text = ""
            
            checkedWord.answer = ""
            for letter in currentLetters {
                checkedWord.answer += letter
            }
            print(checkedWord.answer)
        }
        
    }
    
    //how to play
    @IBAction func showInstruction(_ sender: UIButton) {
        if instructionView.isHidden {
            instructionView.isHidden = false
        } else {
            instructionView.isHidden = true
        }
    }
    
    
    @IBAction func playAgain(_ sender: Any) {
        for i in 0...emojis.count-1 {
            emojis[i].removeFromSuperview()
        }
        emojis.removeAll()
        resultView.isHidden = true
        resetGame()
    }
    
}

