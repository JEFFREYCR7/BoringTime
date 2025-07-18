//
//  Recent.swift
//  BoringTime
//


import SwiftUI
import SwiftData

@Model
class Recent {
    var hour: Int
    var minute: Int
    var seconds: Int
    
    var date: Date = Date()
    
    init(hour: Int, minute: Int, seconds: Int) {
        self.hour = hour
        self.minute = minute
        self.seconds = seconds
    }
    
    var totalInSeconds: Int {
        return (hour * 60 * 60) + (minute * 60) + seconds
    }
}
