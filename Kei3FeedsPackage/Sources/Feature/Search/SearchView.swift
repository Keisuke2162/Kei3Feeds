import Core
import Domain
import SwiftData
import SwiftUI

public struct SearchView: View {
  @Query private var feeds: [FeedModel]
  @Environment(\.modelContext) private var context
  @StateObject var viewModel: SearchViewModel
  
  @State var text: String = ""
  @Environment(\.dismiss) var dismiss

  public init(viewModel: SearchViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    VStack(spacing: 32) {
      Spacer()
        .frame(height: 48)
      
      HStack(spacing: 16) {
        TextField("url", text: $text)
        Button {
          text = ""
        } label: {
          Image(systemName: "xmark")
        }
        .frame(width: 32, height: 32)
        .background(Color.cyan)
        .clipShape(.rect(cornerRadius: 8))
      }
      .padding(.horizontal, 32)

      HStack(spacing: 32) {
        Spacer()
        
        Button {
          if let pasted = UIPasteboard.general.url {
            text = pasted.absoluteString
          }
        } label: {
          Image(systemName: "rectangle.and.pencil.and.ellipsis")
        }
        .frame(width: 32, height: 32)
        .background(Color.cyan)
        .clipShape(.rect(cornerRadius: 8))

        Button {
          viewModel.onTapSearchButton(text: text)
        } label: {
          Image(systemName: "magnifyingglass")
        }
        .frame(width: 32, height: 32)
        .background(Color.cyan)
        .clipShape(.rect(cornerRadius: 8))
      }
      .padding(.horizontal, 32)
      
      VStack {
        if let model = viewModel.searchResultCustomFeed {
          VStack(spacing: 16) {
            Text(model.title)
            Button {
              viewModel.onAddFeed(model, context)
              dismiss()
            } label: {
              Text("Register")
            }
            .disabled(viewModel.feeds.contains { $0.url.absoluteString == model.url })
          }
        } else {
          Text("Empty")
        }
      }
      Spacer()
    }
  }
}
