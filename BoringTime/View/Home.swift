//
//  Home.swift
//  BoringTime
//

import SwiftUI
import SwiftData

struct Home: View {
    @State private var background: Color = .black

    @State private var flipColockTime: Time = .init()
    @State private var pickerTime: Time = .init()
    @State private var startTimer: Bool = false

    @State private var totalTimeInSeconds: Int = 0
    @State private var timerCount: Int = 0

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @Query(sort: [SortDescriptor(\Recent.date, order: .reverse)], animation: .snappy)
    private var recents: [Recent]

    @Environment(\.modelContext) private var context

    var body: some View {
        GeometryReader { geo in
            if geo.size.width > geo.size.height {
                // 横屏：仅显示翻页时间
                LandscapeFlipClockView(time: flipColockTime)
                    .edgesIgnoringSafeArea(.all)
            } else {
                // 竖屏：原来的UI
                VStack(alignment: .leading, spacing: 0) {
                    Text("无聊的时间")
                        .font(.largeTitle.bold())
                        .foregroundColor(.gray)
                        .padding(.top, 15)

                    TimerViwer()
                        .padding(.top, 35)
                        .offset(y: -15)

                    TimePicker(
                        style: .init(.gray.opacity(0.15)),
                        hour: $pickerTime.hour,
                        minutes: $pickerTime.minute,
                        seconds: $pickerTime.seconds
                    )
                    .padding(15)
                    .onChange(of: pickerTime) { oldValue, newValue in
                        flipColockTime = newValue
                    }
                    .disableWithOpacity(startTimer)

                    TimeButton()
                    RecentsView()
                        .disableWithOpacity(startTimer)
                }
                .padding(15)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(background.gradient)
            }
        }
        .onReceive(timer) { _ in
            if startTimer {
                if timerCount > 0 {
                    timerCount -= 1
                    updateFlipClock()
                } else {
                    stopTimerCount()
                }
            } else {
                timer.upstream.connect().cancel()
            }
        }
    }

    func updateFlipClock() {
        let hour = (timerCount / 3600) % 24
        let minute = (timerCount / 60) % 60
        let seconds = (timerCount) % 60

        flipColockTime = .init(hour: hour, minute: minute, seconds: seconds)
    }

    @ViewBuilder
    func TimeButton() -> some View {
        Button {
            startTimer.toggle()
            if startTimer {
                startTimerCount()
            } else {
                stopTimerCount()
            }
        } label: {
            Text(!startTimer ? "开始计时" : "重新计时")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(.white, in: .rect(cornerRadius: 10))
                .contentShape(.rect(cornerRadius: 10))
        }
        .disableWithOpacity(flipColockTime.isZero && !startTimer)
    }

    func startTimerCount() {
        totalTimeInSeconds = flipColockTime.totalInSeconds
        timerCount = totalTimeInSeconds - 1

        if !recents.contains(where: { $0.totalInSeconds == totalTimeInSeconds }) {
            let recent = Recent(hour: flipColockTime.hour, minute: flipColockTime.minute, seconds: flipColockTime.seconds)
            context.insert(recent)
        }

        updateFlipClock()

        timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    }

    func stopTimerCount() {
        startTimer = false
        totalTimeInSeconds = 0
        timerCount = 0
        flipColockTime = .init()
        withAnimation(.linear) {
            pickerTime = .init()
        }
        timer.upstream.connect().cancel()
    }

    @ViewBuilder
    func RecentsView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("最近")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.8))
                .opacity(recents.isEmpty ? 0 : 1)

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(recents) { value in
                        let isHour = value.hour > 0
                        let isSeconds = value.minute == 0 && value.hour == 0 && value.seconds != 0
                        HStack(spacing: 0) {
                            Text(isHour ? "\(value.hour)" : isSeconds ? "\(value.seconds)" : "\(value.minute)")
                            Text(isHour ? "h" : isSeconds ? "S" : "m")
                        }
                        .font(.callout)
                        .foregroundStyle(.gray)
                        .frame(width: 50, height: 50)
                        .background(.white, in: .circle)
                        .contentShape(.contextMenuPreview, .circle)
                        .contextMenu {
                            Button("删除", role: .destructive) {
                                context.delete(value)
                            }
                        }
                        .onTapGesture {
                            pickerTime = .init(hour: value.hour, minute: value.minute, seconds: value.seconds)
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.leading, 10)
            }
            .scrollIndicators(.hidden)
            .padding(.leading, -10)
        }
    }

    @ViewBuilder
    func TimerViwer() -> some View {
        let size: CGSize = .init(width: 100, height: 120)
        HStack(spacing: 10) {
            TimerViewHelper("小时", value: $flipColockTime.hour, size: size)
            TimerViewHelper("分钟", value: $flipColockTime.minute, size: size)
            TimerViewHelper("秒", value: $flipColockTime.seconds, size: size, isLast: true)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func TimerViewHelper(_ title: String, value: Binding<Int>, size: CGSize, isLast: Bool = false) -> some View {
        Group {
            VStack(spacing: 10) {
                FlipClockTextEffect(
                    value: value,
                    size: size,
                    fontSize: 60,
                    cornerRadius: 18,
                    foreground: .black,
                    background: .white
                )
                Text(title)
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize()
            }

            if !isLast {
                VStack(spacing: 15) {
                    Circle().fill(.white).frame(width: 10, height: 10)
                    Circle().fill(.white).frame(width: 10, height: 10)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

extension View {
    @ViewBuilder
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.3), value: condition)
    }
}
