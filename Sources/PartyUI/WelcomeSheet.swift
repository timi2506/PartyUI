//
//  WelcomeSheet.swift
//  Created by lunginspector for jailbreak.party.
//
//  PartyUI: a collection of reusable UI elements used by jailbreak.party.
//  Licensed under the MIT License.
//  https://github.com/jailbreakdotparty/PartyUI
//  https://jailbreak.party/
//

import SwiftUI

// MARK: Welcome Sheet
public struct WelcomeSheetTitle: View {
    var title: String
    var color: Color = .accentColor
    
    public init(title: String, color: Color = .accentColor) {
        self.title = title
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .center) {
            Text("Welcome to")
                .font(.title)
            Text(title)
                .font(.system(.largeTitle, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}

public struct WelcomeSheetCell: View {
    var icon: String
    var title: String
    var context: String
    
    public init(icon: String, title: String, context: String) {
        self.icon = icon
        self.title = title
        self.context = context
    }
    
    public var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30, alignment: .center)
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(.title3, weight: .medium))
                Text(context)
                    .multilineTextAlignment(.leading)
                    .opacity(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public struct WelcomeSheet<CellContent: View, ButtonContent: View>: View {
    var title: String
    @ViewBuilder var cellContent: CellContent
    @ViewBuilder var buttonContent: ButtonContent
    
    public init(title: String, cellContent: CellContent, buttonContent: ButtonContent) {
        self.title = title
        self.cellContent = cellContent
        self.buttonContent = buttonContent
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            WelcomeSheetTitle(title: title)
                .padding(.top, 60)
            Spacer()
            VStack(alignment: .leading, spacing: 35) {
                cellContent
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 80)
            Spacer()
            VStack {
                buttonContent
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 20)
    }
}

