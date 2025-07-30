import Foundation
import BrowserSignin

protocol AuthServiceProtocol {
    var isAuthenticated: Bool { get }
    var idToken: String? { get }
    
    func tokenInfo() -> TokenInfo?
    func userInfo() async throws -> UserInfo?
    func signIn() async throws
    func signOut() async throws
    func refreshTokenIfNeeded() async throws
    func fetchMessageFromBackend() async throws -> String
}

final class AuthService: AuthServiceProtocol {
    // Implementation will go here
    
    var isAuthenticated: Bool {
        return Credential.default != nil
    }
    
    var idToken: String? {
        return Credential.default?.token.accessToken
    }
    
    @MainActor
    func signIn() async throws {
        BrowserSignin.shared?.ephemeralSession = true
        let tokens = try await BrowserSignin.shared?.signIn()
        if let tokens {
            _ = try? Credential.store(tokens)
        }
    }
    
    @MainActor
    func signOut() async throws {
        guard let credential = Credential.default else { return }
        try await BrowserSignin.shared?.signOut(token: credential.token)
        try? credential.remove()
    }
    
    func refreshTokenIfNeeded() async throws {
        guard let credential = Credential.default else { return }
        try await credential.refresh()
    }
    
    func tokenInfo() -> TokenInfo? {
        guard let idToken = Credential.default?.token.idToken else {
            return nil
        }
        
        return TokenInfo(idToken: idToken)
    }
    
    func userInfo() async throws -> UserInfo? {
        if let userInfo = Credential.default?.userInfo {
            return userInfo
        } else {
            do {
                guard let userInfo = try await Credential.default?.userInfo() else {
                    return nil
                }
                return userInfo
            } catch {
                return nil
            }
        }
    }
    
    @MainActor
    func fetchMessageFromBackend() async throws -> String {
        guard let credential = Credential.default else {
            return "Not authenticated."
        }

        var request = URLRequest(url: URL(string: "http://localhost:8000/api/messages")!)
        request.httpMethod = "GET"

        await credential.authorize(&request)

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let response = try decoder.decode(MessageResponse.self, from: data)
        if let randomMessage = response.messages.randomElement() {
            return "\(randomMessage.text)"
        } else {
            return "No messages found."
        }
    }
}
