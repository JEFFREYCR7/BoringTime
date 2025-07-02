//
//  Time.swift
//  BoringTime
//


import SwiftUI

struct Time: Hashable {
    var hour: Int = 0
    var minute: Int = 0
    var seconds: Int = 0

    
    var isZero: Bool {
        return hour == 0 && minute == 0 && seconds == 0
    }
    
    var totalInSeconds: Int {
        return (hour * 60 * 60) + (minute * 60) + seconds
    }
}
