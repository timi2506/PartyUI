//
//  PartyViews.swift
//  Created by lunginspector for jailbreak.party.
//  Thanks to https://www.cephalopod.studio/blog/swiftui-aurora-background-animation for much of the code required to achieve this.
//
//  PartyUI: a collection of reusable UI elements used by jailbreak.party.
//  Licensed under the MIT License.
//  https://github.com/jailbreakdotparty/PartyUI
//  https://jailbreak.party/
//

import SwiftUI
import Combine

public struct AuroraBackground: View {
    var color1: Color
    var color2: Color
    var color3: Color
    var color4: Color
    var background: Color
    
    public init(color1: Color, color2: Color, color3: Color, color4: Color, background: Color) {
        self.color1 = color1
        self.color2 = color2
        self.color3 = color3
        self.color4 = color4
        self.background = background
    }
    
    public var body: some View {
        GeometryReader { raysFrameMonitor in
            ZStack {
                ZStack {
                    FloatingRayItem(alignment: .topLeading, monitorData: raysFrameMonitor, color: color1, beginningRotation: 0, duration: 60)
                    FloatingRayItem(alignment: .topTrailing, monitorData: raysFrameMonitor, color: color2, beginningRotation: 240, duration: 65)
                    FloatingRayItem(alignment: .bottomLeading, monitorData: raysFrameMonitor, color: color3, beginningRotation: 120, duration: 80)
                    FloatingRayItem(alignment: .bottomTrailing, monitorData: raysFrameMonitor, color: color4, beginningRotation: 180, duration: 70)
                }
                .blur(radius: 60)
            }
            .background(background)
            .ignoresSafeArea()
        }
    }
}

public struct FloatingRayItem: View {
    @StateObject var floatingRayData = FloatingRayDataModel()
    var alignment: Alignment
    var monitorData: GeometryProxy
    var color: Color
    var beginningRotation: Double
    var duration: Double
    
    public init(floatingRayData: FloatingRayDataModel = FloatingRayDataModel(), alignment: Alignment, monitorData: GeometryProxy, color: Color, beginningRotation: Double, duration: Double) {
        self.alignment = alignment
        self.monitorData = monitorData
        self.color = color
        self.beginningRotation = beginningRotation
        self.duration = duration
    }
    
    public var body: some View {
        Circle()
            .fill(color)
            .frame(height: monitorData.size.height / floatingRayData.raySize)
            .offset(floatingRayData.rayOffset)
            .rotationEffect(.init(degrees: beginningRotation))
            .animation(Animation.linear(duration: duration * 0.5).repeatForever(autoreverses: true))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            .opacity(0.8)
    }
}

public class FloatingRayDataModel: ObservableObject {
    var rayOffset: CGSize
    var raySize: CGFloat
    
    public init() {
        raySize = CGFloat.random(in: 1.0 ..< 1.8)
        rayOffset = CGSize(width: CGFloat.random(in: -150 ..< 150),
                           height: CGFloat.random(in: -150 ..< 500))
    }
}

