import SwiftUI
import BrowserSignin

struct UserInfoView: View {
    let userInfo: UserInfo
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
                
                Text(formattedData)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("User Info")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var formattedData: String {
        var result = ""
     
        result.append("Name: " + (userInfo.name ?? "No Name set"))
        result.append("\n")
        result.append("Username: " + (userInfo.preferredUsername ?? "No Username set"))
        result.append("\n")
        if let updatedAt = userInfo.updatedAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let date = dateFormatter.string(for: updatedAt)
            result.append("Updated at: " + (date ?? ""))
        }

        return result
    }
}

