//
//  Check.swift
//  wordle
//
//  Created by 方仕賢 on 2022/4/1.
//

import Foundation
import UIKit


class Check {
    //問題的字串
    var question: String?
    //玩家的答案
    var answer = ""
    
    //暫時儲存顏色最多五個，換行後會更新
    var colorBlocks = [UIColor](repeating: UIColor.darkGray, count: 5)
    //記錄用過的顏色，會在結果頁面用到
    var usedColors = [UIColor]()
    
    //所有字母
    private let letters = ["A", "B","C","D","E","F","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","W","X","Y","Z"]
    
    func checkExistence()->Bool {
        let questions = Question()
        if !questions.words.contains(answer.lowercased()) {
            return false
        }
        return true
    }
    
    func checkAnswer(){
        var chars = [String]()
        var index = 0
        
        //換行時顏色更新
        for i in 0...colorBlocks.count-1 {
            colorBlocks[i] = .darkGray
        }
        
        //檢查文題是否存在
        if let word = question {
            //分解問題的字變成字母
            for char in word {
                chars.append(String(char))
            }
            
            //顏色在這裡設定
            for char in answer.lowercased() {
                if String(char) == chars[index] {
                    colorBlocks[index] = .systemGreen
                } else {
                    if word.contains(char) {
                        colorBlocks[index] = .systemYellow
                    } 
                }
                usedColors.append(colorBlocks[index])
                index += 1
            }
        }
    }
    
}

//檢查答案
    //取得題目答案
    //取得玩家答案
        //比對兩個答案
            //顯示翻格子動畫
            //變換格字顏色
            //變換鍵盤顏色
                //對的位置跟對的字為綠色
                //對的字位置錯誤為黃色
                //位置跟字都錯為紅色
//跳到下一行



