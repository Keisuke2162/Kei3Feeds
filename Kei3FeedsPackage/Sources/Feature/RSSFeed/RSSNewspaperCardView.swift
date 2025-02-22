import Core
import Foundation
import SwiftUI
import Kingfisher

public struct RSSNewspaperCardView: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.dismiss) var dismiss
  let newspapers: [RSSNewspaper]

  public init(newspapers: [RSSNewspaper]) {
    self.newspapers = newspapers
  }

  struct RotationAngle {
    var x: CGFloat
    var y: CGFloat
  }
  // 表示する画像のindex
  @State private var index: Int = 0
  // 現在の回転角度
  @State private var rotation: RotationAngle = .init(x: .zero, y: .zero)
  // ドラッグ終了時点の角度を保持（次の回転の基準になる）→ 指を離したら元の位置に戻るようにしたので使わなくなった
  @State private var lastRotation: RotationAngle = .init(x: .zero, y: .zero)
  // Y方向の回転角度の上限値（左右ドラッグ）
  private let maxRotationY: CGFloat = 50
  
  // カードの厚み係数
  private let cardThickness: CGFloat = 10
  
  // maxRotationを超えないように噛ませる関数
  private func limitRotation(_ maxRotationValue: CGFloat, _ value: CGFloat) -> CGFloat {
    return min(maxRotationValue, max(-maxRotationValue, value))
  }

  // イージング関数（より自然な動きを実現するため）→ 角度のつき加減によって光沢の移動を変化させることによって光沢がキラーンとなる
  private func easeOutCubic(_ x: CGFloat) -> CGFloat {
    // xは-1.0~1.0の範囲
    let normalized = (x + 1) / 2
    // イージング関数を適用
    let eased = 1 - pow(1 - normalized, 3)
    // 結果を-1~1の範囲に戻す
    return (eased * 2) - 1
  }

  public var body: some View {
    GeometryReader { proxy in
      VStack() {
        Text("PickUp")
          .font(.title).bold()
          .padding(16)
        Spacer()
        
        ZStack {
          HStack {
            Spacer()
            VStack() {
              Spacer()
              
              VStack {
                KFImage(newspapers[index].thumbnailImageURL)
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .clipShape(.rect(
                    topLeadingRadius: 8,
                    topTrailingRadius: 8
                  ))
                HStack {
                  Text(newspapers[index].title)
                    .font(.subheadline).bold()
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                  Spacer()
                }
                .padding(16)
                HStack {
                  Spacer()
                  Link(destination: newspapers[index].link!) {
                    Text("read more")
                      .font(.caption)
                  }
                }
                .padding(8)
              }
              .overlay {
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color.white, lineWidth: 8)
              }
              Spacer()
            }
            Spacer()
          }
          .frame(width: proxy.size.width * 0.9, height: proxy.size.height * 0.8)
          Spacer()
        }
        .shadow(radius: 10)
        .rotation3DEffect(
          .degrees(rotation.x),
          axis: (x: 1.0, y: 0.0, z: 0.0),
          perspective: 0.3  // 遠近感のパラメータ
        )
        .rotation3DEffect(
          .degrees(rotation.y),
          axis: (x: 0.0, y: 1.0, z: 0.0),
          perspective: 0.3
        )
        .gesture(
          DragGesture()
            .onChanged { value in
              let sensitivity: CGFloat = 0.5
              let deltaX = (value.location.x - value.startLocation.x) * sensitivity
              let newYValue = limitRotation(maxRotationY, lastRotation.y + deltaX)
              rotation = .init(x: .zero, y: newYValue)
            }
            .onEnded { _ in
              lastRotation = rotation
              if rotation.y < -49 {
                index = index == newspapers.count - 1 ? 0 : index + 1
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                  rotation.y = .zero
                  lastRotation.y = .zero
                }
              } else if rotation.y > 49 {
                index = index == 0 ? newspapers.count - 1 : index - 1
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                  rotation.y = .zero
                  lastRotation.y = .zero
                }
              } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                  rotation.y = .zero
                  lastRotation.y = .zero
                }
              }
              
            }
        )
        Spacer()
        
        Text("\(index + 1) / \(newspapers.count)")
          .font(.caption).bold()

        Spacer()
        VStack {
          Spacer()
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .foregroundStyle(.white)
              .padding(8)
          }
          .frame(width: 56, height: 56)
          .background(.indigo)
          .clipShape(.rect(cornerRadius: 28))
        }
      }
      .frame(maxWidth: .infinity)
    }
  }
}
