//
//  PartyStyles.swift
//  Created by lunginspector for jailbreak.party.
//
//  PartyUI: a collection of reusable UI elements used by jailbreak.party.
//  Licensed under the MIT License.
//  https://github.com/jailbreakdotparty/PartyUI
//  https://jailbreak.party/
//

import SwiftUI

public struct GlassyPlatter: ViewModifier {
    var color: Color = platterBackgroundColor()
    var shape: AnyShape = AnyShape(.rect(cornerRadius: platterCornerRadius()))
    var isInteractive: Bool = true
    
    public init(color: Color = platterBackgroundColor(), shape: AnyShape = AnyShape(.rect(cornerRadius: platterCornerRadius())), isInteractive: Bool = true) {
        self.color = color
        self.shape = shape
        self.isInteractive = isInteractive
    }
    
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            if isInteractive {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(color)
                    .clipShape(shape)
                    .glassEffect(.regular.interactive(), in: shape)
            } else {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(color)
                    .clipShape(shape)
                    .glassEffect(.regular, in: shape)
            }
        } else {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(color)
                .clipShape(shape)
        }
    }
}

public struct GlassyButtonStyle: PrimitiveButtonStyle {
    var isDisabled: Bool = false
    var color: Color = .accentColor
    var useFullWidth: Bool = true
    var cornerRadius: CGFloat = conditionalCornerRadius()
    var capsuleButton: Bool = false
    var isInteractive: Bool = true
    var width: CGFloat? = nil
    var isMaterialButton: Bool = false
    var materialOpacity: CGFloat = 0.4
    
    public init(isDisabled: Bool = false, color: Color = .accentColor, useFullWidth: Bool = true, cornerRadius: CGFloat = conditionalCornerRadius(), capsuleButton: Bool = false, isInteractive: Bool = true, width: CGFloat? = nil, isMaterialButton: Bool = false, materialOpacity: CGFloat = 0.4) {
        self.isDisabled = isDisabled
        self.color = color
        self.useFullWidth = useFullWidth
        self.cornerRadius = cornerRadius
        self.capsuleButton = capsuleButton
        self.isInteractive = isInteractive
        self.width = width
        self.isMaterialButton = isMaterialButton
        self.materialOpacity = materialOpacity
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        GlassyButtonContents(configuration: configuration, isDisabled: isDisabled, color: color, useFullWidth: useFullWidth, cornerRadius: cornerRadius, capsuleButton: capsuleButton, isInteractive: isInteractive, width: width, isMaterialButton: isMaterialButton, materialOpacity: materialOpacity)
    }
    
    private struct GlassyButtonContents: View {
        @State private var isPressed: Bool = false
        let configuration: Configuration
        var isDisabled: Bool = false
        var color: Color = .accentColor
        var useFullWidth: Bool = true
        var cornerRadius: CGFloat = conditionalCornerRadius()
        var capsuleButton: Bool = false
        var isInteractive: Bool = true
        var width: CGFloat? = nil
        var isMaterialButton: Bool = false
        var materialOpacity: CGFloat = 0.4
        
        var body: some View {
            let color: Color = isDisabled ? .gray : color
            
            if #available(iOS 26.0, *) {
                let shape: AnyShape = capsuleButton ? AnyShape(.capsule) : AnyShape(.rect(cornerRadius: cornerRadius))
                let isInteractive: Bool = isDisabled ? false : true
                
                configuration.label
                    .buttonStyle(.plain)
                    .frame(maxWidth: useFullWidth ? .infinity : nil)
                    .foregroundStyle(color)
                    .padding()
                    .frame(width: width)
                    .background(color.opacity(0.2))
                    .clipShape(shape)
                    .glassEffect(isInteractive ? .regular.interactive() : .regular, in: shape)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { _ in
                                if !isDisabled {
                                    configuration.trigger()
                                }
                            }
                    )
            } else {
                let shape: AnyShape = capsuleButton ? AnyShape(.capsule) : AnyShape(.rect(cornerRadius: cornerRadius))
                
                configuration.label
                    .buttonStyle(.plain)
                    .frame(maxWidth: useFullWidth ? .infinity : nil)
                    .foregroundStyle(color)
                    .padding()
                    .frame(width: width)
                    .background(color.opacity(0.2))
                    .background {
                        if isMaterialButton {
                            Color.clear.background(.ultraThinMaterial.opacity(materialOpacity))
                        }
                    }
                    .clipShape(shape)
                    .opacity(isPressed ? 0.8 : 1.0)
                    .scaleEffect(isPressed ? 0.98 : 1.0)
                    .animation(isPressed ? .none : .spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isDisabled && !isPressed {
                                    isPressed = true
                                }
                            }
                            .onEnded { _ in
                                if !isDisabled {
                                    isPressed = false
                                    configuration.trigger()
                                }
                            }
                    )
            }
        }
    }
}

public struct GlassyTextFieldStyle: TextFieldStyle {
    var isDisabled: Bool = false
    var color: Color = secondaryBackgroundColor()
    var cornerRadius: CGFloat = conditionalCornerRadius()
    var capsuleField: Bool = false
    var isInteractive: Bool = true
    
    public init(isDisabled: Bool = false, color: Color = secondaryBackgroundColor(), cornerRadius: CGFloat = conditionalCornerRadius(), capsuleField: Bool = false, isInteractive: Bool = true) {
        self.isDisabled = isDisabled
        self.color = color
        self.cornerRadius = cornerRadius
        self.capsuleField = capsuleField
        self.isInteractive = isInteractive
    }
    
    public func _body(configuration: TextField<Self._Label>) -> some View {
        let color: Color = isDisabled ? .gray.opacity(0.2) : color
        let fontColor: Color = isDisabled ? .gray : .primary
        
        if #available(iOS 26.0, *) {
            let shape: AnyShape = capsuleField ? AnyShape(.capsule) : AnyShape(.rect(cornerRadius: cornerRadius))
            let isInteractive: Bool = isDisabled ? false : true
            
            configuration
                .textFieldStyle(.plain)
                .frame(maxWidth: .infinity)
                .foregroundStyle(fontColor)
                .padding()
                .clipShape(shape)
                .modifier(DynamicGlassEffect(color: color, isInteractive: isInteractive))
                .allowsHitTesting(!isDisabled)
        } else {
            let shape: AnyShape = capsuleField ? AnyShape(.capsule) : AnyShape(.rect(cornerRadius: cornerRadius))
            
            configuration
                .textFieldStyle(.plain)
                .frame(maxWidth: .infinity)
                .foregroundStyle(fontColor)
                .padding()
                .clipShape(shape)
                .modifier(DynamicGlassEffect(color: color))
                .allowsHitTesting(!isDisabled)
        }
    }
}

public struct GlassyListRowBackground: ViewModifier {
    var color: Color = .accentColor
    var cornerRadius: CGFloat = conditionalCornerRadius()
    var isOn: Bool = false
    var isInteractive: Bool = true
    
    public init(color: Color = .accentColor, cornerRadius: CGFloat = conditionalCornerRadius(), isOn: Bool = false, isInteractive: Bool = true) {
        self.color = color
        self.cornerRadius = cornerRadius
        self.isOn = isOn
        self.isInteractive = isInteractive
    }
    
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(color)
                .padding()
                .background(color.opacity(0.2))
                .clipShape(.rect(cornerRadius: cornerRadius))
                .glassEffect(isInteractive ? .regular.interactive() : .regular, in: .rect(cornerRadius: cornerRadius))
                .opacity(isOn ? 1.0 : 0.8)
        } else {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(color)
                .padding()
                .background(color.opacity(0.2))
                .clipShape(.rect(cornerRadius: cornerRadius))
                .opacity(isOn ? 1.0 : 0.8)
        }
    }
}

public struct DynamicGlassEffect: ViewModifier {
    var color: Color = Color(.quaternarySystemFill)
    var shape: AnyShape = AnyShape(.rect(cornerRadius: conditionalCornerRadius()))
    var useFullWidth: Bool = true
    var glassEffect: Bool = true
    var isInteractive: Bool = true
    var useBackground: Bool = true
    var opacity: CGFloat = 1.0

    public init(color: Color = Color(.quaternarySystemFill), shape: AnyShape = AnyShape(.rect(cornerRadius: conditionalCornerRadius())), useFullWidth: Bool = true, glassEffect: Bool = true, isInteractive: Bool = true, useBackground: Bool = true, opacity: CGFloat = 1.0) {
        self.color = color
        self.shape = shape
        self.useFullWidth = useFullWidth
        self.glassEffect = glassEffect
        self.isInteractive = isInteractive
        self.useBackground = useBackground
        self.opacity = opacity
    }

    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            if glassEffect {
                content
                    .background(useBackground ? color.opacity(opacity) : .clear)
                    .clipShape(shape)
                    .glassEffect(isInteractive ? .regular.interactive() : .regular, in: shape)
            } else {
                content
                    .background(useBackground ? color.opacity(opacity) : .clear)
                    .clipShape(shape)
            }
        } else {
            content
                .background(color.opacity(opacity))
                .clipShape(shape)
        }
    }
}

public struct OverlayBackground: ViewModifier {
    @State private var keyboardShown: Bool = false
    var blurRadius: CGFloat = 8
    var useDimming: Bool = true
    
    public init(keyboardShown: Bool = false, blurRadius: CGFloat = 8, useDimming: Bool = true) {
        self.keyboardShown = keyboardShown
        self.blurRadius = blurRadius
        self.useDimming = useDimming
    }
    
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, 25)
            .padding(.top, 30)
            .padding(.bottom, keyboardShown ? 20 : 0)
            .background {
                ZStack {
                    VariableBlurView(maxBlurRadius: blurRadius, direction: .blurredBottomClearTop)
                    if useDimming {
                        Rectangle()
                            .fill(Gradient(colors: [.clear, Color(.systemBackground)]))
                            .opacity(0.8)
                    }
                }
                .ignoresSafeArea()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                keyboardShown = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardShown = false
            }
    }
}
