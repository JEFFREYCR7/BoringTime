//
//  LandscapeFlipClockView.swift
//  BoringTime

import SwiftUI

struct LandscapeFlipClockView: View {
    var time: Time
    
    var body: some View {
        let size = CGSize(width: 120, height: 160)  // 更大翻页尺寸
        HStack(spacing: 20) {
            FlipClockTextEffect(
                value: .constant(time.hour),
                size: size,
                fontSize: 80,
                cornerRadius: 20,
                foreground: .black,
                background: .white
            )
            
            FlipClockTextEffect(
                value: .constant(time.minute),
                size: size,
                fontSize: 80,
                cornerRadius: 20,
                foreground: .black,
                background: .white
            )
            
            FlipClockTextEffect(
                value: .constant(time.seconds),
                size: size,
                fontSize: 80,
                cornerRadius: 20,
                foreground: .black,
                background: .white
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}


//#Preview {
//    LandscapeFlipClockView()
//}
