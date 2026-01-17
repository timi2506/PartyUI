// MARK: Details
// PartyUI: a collection of reusable UI elements used by jailbreak.party.
// Licensed under the MIT License.
// https://github.com/jailbreakdotparty/PartyUI
// https://jailbreak.party/

import SwiftUI

// MARK: Functions/Extensions
public func conditionalCornerRadius() -> CGFloat {
    if #available(iOS 26.0, *) {
        return 18
    } else {
        return 12
    }
}

public func platterCornerRadius() -> CGFloat {
    if #available(iOS 26.0, *) {
        return 26
    } else {
        return 18
    }
}

public func platterBackgroundColor() -> Color {
    if #available(iOS 26.0, *) {
        return Color.clear
    } else {
        return Color(.secondarySystemBackground)
    }
}

public func secondaryBackgroundColor() -> Color {
    if #available(iOS 26.0, *) {
        return Color(.secondarySystemBackground)
    } else {
        return Color(.quaternarySystemFill)
    }
}

public func smallPlatterCornerRadius() -> CGFloat {
    if #available(iOS 26.0, *) {
        return 16
    } else {
        return 12
    }
}

@MainActor public func doubleSystemVersion() -> Double {
    let rawSystemVersion = UIDevice.current.systemVersion
    let parsedSystemVersion = rawSystemVersion.split(separator: ".").prefix(2).joined(separator: ".")
    return Double(parsedSystemVersion) ?? 0.0
}

public extension EdgeInsets {
    static let dropdownRowInsets = EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20)
    static let itemRowInsets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    static let zeroInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}

public extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

// MARK: Image Rendering
public struct ImageRenderingView: View {
    var image: Image
    var cornerRadius: CGFloat = 24
    var capsuleImage: Bool = false
    var glassEffect: Bool = true
    var isInteractive: Bool = true
    var width: CGFloat = 40
    var height: CGFloat = 40
    var shouldImageFit: Bool = false
    var useBackground: Bool = false
    
    public init(image: Image, cornerRadius: CGFloat = 24, capsuleImage: Bool = false, glassEffect: Bool = true, isInteractive: Bool = true, width: CGFloat = 40, height: CGFloat = 40, shouldImageFit: Bool = false, useBackground: Bool = false) {
        self.image = image
        self.cornerRadius = cornerRadius
        self.capsuleImage = capsuleImage
        self.glassEffect = glassEffect
        self.isInteractive = isInteractive
        self.width = width
        self.height = height
        self.shouldImageFit = shouldImageFit
        self.useBackground = useBackground
    }
    
    public var body: some View {
        let shape: AnyShape = capsuleImage ? AnyShape(.capsule) : AnyShape(.rect(cornerRadius: cornerRadius))
        
        if #available(iOS 26.0, *) {
            Group {
                if shouldImageFit {
                    image
                        .resizable()
                        .scaledToFit()
                } else {
                    image
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: width, height: height)
            .clipShape(shape)
            .modifier(DynamicGlassEffect(shape: shape, glassEffect: glassEffect, isInteractive: isInteractive, useBackground: useBackground))
        } else {
            Group {
                if shouldImageFit {
                    image
                        .resizable()
                        .scaledToFit()
                } else {
                    image
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: width, height: height)
            .background(useBackground ? Color(.quaternarySystemFill) : Color.clear)
            .clipShape(shape)
        }
    }
}

// MARK: Effects
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

// MARK: Containers
public struct TerminalContainer<Content: View>: View {
    @State private var color: Color = secondaryBackgroundColor()
    @ViewBuilder var content: Content

    public init(color: Color = secondaryBackgroundColor(), content: Content) {
        self.content = content
        self.color = color
    }

    public var body: some View {
        ZStack(alignment: .top) {
            content
                .padding(.horizontal)
            VStack {
                VariableBlurView(maxBlurRadius: 1, direction: .blurredTopClearBottom)
                    .frame(maxHeight: 20)
                Spacer()
                VariableBlurView(maxBlurRadius: 1, direction: .blurredBottomClearTop)
                    .frame(maxHeight: 20)
            }
            .frame(alignment: .top)
        }
        .frame(height: 250)
        .modifier(DynamicGlassEffect(color: color, opacity: 1.0))
    }
}

// MARK: Headers, labels, and other views
public struct HeaderLabel: View {
    var text: String
    var icon: String
    var useHeaderStyling: Bool = false
    
    public init(text: String, icon: String, useHeaderStyling: Bool = false) {
        self.text = text
        self.icon = icon
        self.useHeaderStyling = useHeaderStyling
    }
    
    public var body: some View {
        HStack {
            if #available(iOS 26.0, *) {
                HStack(spacing: useHeaderStyling ? 10 : nil) {
                    Image(systemName: icon)
                        .frame(width: 22, alignment: .center)
                    Text(text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: useHeaderStyling ? 8 : nil) {
                    Image(systemName: icon)
                        .frame(width: 20, alignment: .center)
                    Text(text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .modifier(HeaderStyling(useHeaderStyling: useHeaderStyling))
    }
}

public struct HeaderDropdown: View {
    var text: String
    var icon: String
    var useHeaderStyling: Bool = false
    var useCount: Bool = false
    var itemCount: Int = 1
    @Binding var isExpanded: Bool
    @State private var oldItemCount: Int = 0
    @AppStorage var isExpandedStorage: Bool
    
    public init(text: String, icon: String, useHeaderStyling: Bool = false, useCount: Bool = false, itemCount: Int = 1, isExpanded: Binding<Bool>) {
        self.text = text
        self.icon = icon
        self.useHeaderStyling = useHeaderStyling
        self.useCount = useCount
        self.itemCount = itemCount
        self._isExpanded = isExpanded
        self._isExpandedStorage = AppStorage(wrappedValue: true, "sectionExpanded_\(text)")
    }
    
    public var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
                isExpandedStorage = isExpanded
            }
        }) {
            HStack {
                if #available(iOS 26.0, *) {
                    Image(systemName: icon)
                        .frame(width: 24, alignment: .center)
                    Text(text)
                } else {
                    Image(systemName: icon)
                        .frame(width: 20, alignment: .center)
                    Text(text)
                }
                Spacer()
                if useCount {
                    if #available(iOS 26.0, *) {
                        Text("\(itemCount)")
                            .frame(minWidth: 14)
                            .frame(height: 14)
                            .padding(6)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(.capsule)
                            .glassEffect(.regular, in: .capsule(style: .circular))
                    } else {
                        Text("\(itemCount)")
                            .frame(minWidth: 14)
                            .frame(height: 14)
                            .padding(4)
                            .background(Color(.quaternarySystemFill))
                            .clipShape(.capsule)
                    }
                }
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .frame(width: 24, height: 24, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .onAppear {
            isExpanded = isExpandedStorage
            oldItemCount = itemCount
        }
        .onChange(of: itemCount) { newValue in
            if newValue == 0 {
                isExpanded = false
            } else if oldItemCount == 0 && newValue == 1 {
                isExpanded = true
            }
            oldItemCount = newValue
        }
        .onChange(of: isExpanded) { newValue in
            isExpandedStorage = newValue
        }
    }
}

public struct HeaderStyling: ViewModifier {
    var useHeaderStyling: Bool
    var addLeadingPadding: Bool = true
    
    public init(useHeaderStyling: Bool, addLeadingPadding: Bool = true) {
        self.useHeaderStyling = useHeaderStyling
        self.addLeadingPadding = addLeadingPadding
    }
    
    public func body(content: Content) -> some View {
        if useHeaderStyling {
            if addLeadingPadding {
                content
                    .opacity(0.6)
                    .fontWeight(.semibold)
                    .padding(.top, 10)
                    .padding(.leading, 14)
            } else {
                content
                    .opacity(0.6)
                    .fontWeight(.semibold)
                    .padding(.top, 10)
            }
        } else {
            content
        }
    }
}

public struct CustomFooter: View {
    var text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        Text(text)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.footnote)
            .opacity(0.6)
            .padding(.horizontal, 14)
            .padding(.top, 2)
    }
}

public struct ButtonLabel: View {
    var text: String
    var icon: String
    var isRegularImage: Bool = false
    
    public init(text: String, icon: String, isRegularImage: Bool = false) {
        self.text = text
        self.icon = icon
        self.isRegularImage = isRegularImage
    }
    
    public var body: some View {
        HStack {
            if isRegularImage {
                ImageRenderingView(image: Image(icon), cornerRadius: 0, glassEffect: false, isInteractive: false, width: 24, height: 24, shouldImageFit: true)
            } else {
                Image(systemName: icon)
                    .frame(width: 24, alignment: .center)
            }
            Text(text)
        }
    }
}

public struct LinkCreditCell: View {
    @Environment(\.openURL) private var openURL
    var image: String = ""
    var name: String
    var text: String
    var link: String
    
    public init(image: String = "", name: String, text: String, link: String) {
        self.image = image
        self.name = name
        self.text = text
        self.link = link
    }
    
    public var body: some View {
        Button(action: {
            openURL(URL(string: link)!)
        }) {
            HStack(spacing: 12) {
                if !image.isEmpty {
                    if #available(iOS 26.0, *) {
                        ImageRenderingView(image: Image(image), capsuleImage: true, useBackground: true)
                    } else {
                        ImageRenderingView(image: Image(image), cornerRadius: 8, useBackground: true)
                    }
                }
                VStack(alignment: .leading) {
                    Text(name)
                        .fontWeight(.semibold)
                    Text(text)
                        .font(.subheadline)
                        .opacity(0.8)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .opacity(0.2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(.primary)
    }
}

public struct AppInfoCell: View {
    var imageName: String
    var title: String
    var subtitle: String
    
    public init(imageName: String, title: String, subtitle: String) {
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            ImageRenderingView(image: Image(imageName), cornerRadius: conditionalCornerRadius(), width: 60, height: 60, useBackground: true)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(.title3, weight: .medium))
                Text(subtitle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

public struct ContextualWarning: View {
    var icon: String = ""
    var label: String
    var text: String
    var color: Color = .red
    
    public init(icon: String = "", label: String, text: String, color: Color = .red) {
        self.icon = icon
        self.label = label
        self.text = text
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.title)
                    .frame(width: 38, alignment: .center)
            }
            VStack(alignment: .leading) {
                Text(label)
                    .font(.system(.title3, weight: .semibold))
                Text(text)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .foregroundStyle(color)
        .modifier(DynamicGlassEffect(color: color.opacity(0.2), shape: AnyShape(.rect(cornerRadius: conditionalCornerRadius()))))
    }
}

// MARK: Buttons, Text Fields, Lists
public struct GlassyButtonStyle: ButtonStyle {
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
                .allowsHitTesting(!isDisabled)
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
                .allowsHitTesting(!isDisabled)
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
    
    public init(color: Color = .accentColor, cornerRadius: CGFloat = conditionalCornerRadius()) {
        self.color = color
        self.cornerRadius = cornerRadius
    }
    
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(color)
                .padding()
                .background(color.opacity(0.2))
                .clipShape(.rect(cornerRadius: cornerRadius))
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(color)
                .padding()
                .background(color.opacity(0.2))
                .clipShape(.rect(cornerRadius: cornerRadius))
        }
    }
}

public struct ListToggleItem: View {
    var text: String
    var icon: String = ""
    var useBackground: Bool = true
    var minSupportedVersion: Double = 0.0
    var maxSupportedVersion: Double = 100.0
    @Binding var isOn: Bool
    
    public init(text: String, icon: String = "", useBackground: Bool = true, minSupportedVersion: Double = 0.0, maxSupportedVersion: Double = 100.0, isOn: Binding<Bool>) {
        self.text = text
        self.icon = icon
        self.useBackground = useBackground
        self.minSupportedVersion = minSupportedVersion
        self.maxSupportedVersion = maxSupportedVersion
        self._isOn = isOn
    }
    
    public var body: some View {
        if doubleSystemVersion() <= maxSupportedVersion && doubleSystemVersion() >= minSupportedVersion {
            if useBackground {
                Button(action: {
                    isOn.toggle()
                }) {
                    LabeledContent {
                        Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    } label: {
                        HStack {
                            if !icon.isEmpty {
                                Image(systemName: icon)
                                    .frame(width: 24, alignment: .center)
                            }
                            Text(text)
                                .lineLimit(1)
                        }
                    }
                }
                .modifier(GlassyListRowBackground())
            } else {
                Button(action: {
                    isOn.toggle()
                }) {
                    LabeledContent {
                        Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    } label: {
                        HStack {
                            if !icon.isEmpty {
                                Image(systemName: icon)
                                    .frame(width: 24, alignment: .center)
                            }
                            Text(text)
                                .lineLimit(1)
                        }
                    }
                }
            }
        } else {
            
        }
    }
}

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
