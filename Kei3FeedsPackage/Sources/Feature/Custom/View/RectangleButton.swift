//
//  RectangleButton.swift
//  Kei3FeedsPackage
//
//  Created by Kei on 2025/02/22.
//

import SwiftUI

public struct RectangleButton: View {
  @Environment(\.colorScheme) var colorScheme
  let isLoading: Bool
  let image: Image
  let size: CGSize
  let action: () -> Void

  public var body: some View {
    Button {
      action()
    } label: {
      image
        .padding(8)
        .foregroundStyle(colorScheme == .dark ? .white : .black)
        .opacity(isLoading ? 0 : 1)
    }
    .frame(width: size.width, height: size.height)
    .background(colorScheme == .dark ? .black : .white)
    .clipShape(.rect(cornerRadius: 8))
    .disabled(isLoading)
    .overlay {
      ProgressView().opacity(isLoading ? 1 : 0)
      RoundedRectangle(cornerRadius: 8)
        .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
    }
  }
}
