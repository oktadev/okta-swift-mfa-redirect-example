import SwiftUI

struct TokenInfoView: View {
    let tokenInfo: TokenInfo
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .foregroundStyle(.black)
                        .frame(width: 40, height: 40)
                        .padding(.leading, 10)
                }
                
                Text(tokenInfo.toString())
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
         
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Token Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}
