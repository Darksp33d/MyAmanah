import Foundation
import Supabase
import Combine

// MARK: - Supabase Manager
@MainActor
final class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        client = SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey
        )
        
        Task {
            await setupAuthStateListener()
        }
    }
    
    // MARK: - Auth State
    private func setupAuthStateListener() async {
        for await (event, session) in client.auth.authStateChanges {
            switch event {
            case .initialSession, .signedIn:
                if let session = session {
                    await loadCurrentUser(authId: session.user.id)
                }
            case .signedOut:
                currentUser = nil
                isAuthenticated = false
            case .tokenRefreshed:
                break
            case .userUpdated:
                if let session = session {
                    await loadCurrentUser(authId: session.user.id)
                }
            default:
                break
            }
        }
    }
    
    private func loadCurrentUser(authId: UUID) async {
        do {
            let user: User = try await client
                .from("users")
                .select()
                .eq("auth_id", value: authId.uuidString)
                .single()
                .execute()
                .value
            
            currentUser = user
            isAuthenticated = true
        } catch {
            print("Error loading user: \(error)")
            isAuthenticated = false
        }
    }
    
    // MARK: - Auth Methods
    func signUp(email: String, password: String, displayName: String?) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let authResponse = try await client.auth.signUp(
            email: email,
            password: password
        )
        
        let authUser = authResponse.user
        
        // Create user profile
        let newUser = User(
            authId: authUser.id,
            displayName: displayName,
            timezone: TimeZone.current.identifier
        )
        
        try await client
            .from("users")
            .insert(newUser)
            .execute()
        
        // Create default settings
        let settings = UserSettings.default
        try await client
            .from("user_settings")
            .insert(settings)
            .execute()
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await client.auth.signIn(email: email, password: password)
    }
    
    func signInWithApple(idToken: String, nonce: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        currentUser = nil
        isAuthenticated = false
    }
    
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
    // MARK: - Session
    var session: Session? {
        get async {
            try? await client.auth.session
        }
    }
    
    var accessToken: String? {
        get async {
            try? await client.auth.session.accessToken
        }
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case signUpFailed
    case signInFailed
    case notAuthenticated
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .signUpFailed:
            return "Failed to create account. Please try again."
        case .signInFailed:
            return "Invalid email or password."
        case .notAuthenticated:
            return "Please sign in to continue."
        case .userNotFound:
            return "User not found."
        }
    }
}

// MARK: - Database Extensions
extension SupabaseManager {
    // MARK: - Generic CRUD
    func fetch<T: Decodable>(
        from table: String,
        filter: ((PostgrestFilterBuilder) -> PostgrestFilterBuilder)? = nil
    ) async throws -> [T] {
        var query = client.from(table).select()
        if let filter = filter {
            query = filter(query)
        }
        return try await query.execute().value
    }
    
    func fetchSingle<T: Decodable>(
        from table: String,
        filter: (PostgrestFilterBuilder) -> PostgrestFilterBuilder
    ) async throws -> T {
        try await filter(client.from(table).select())
            .single()
            .execute()
            .value
    }
    
    func insert<T: Encodable>(
        into table: String,
        value: T
    ) async throws {
        try await client
            .from(table)
            .insert(value)
            .execute()
    }
    
    func update<T: Encodable>(
        table: String,
        value: T,
        filter: (PostgrestFilterBuilder) -> PostgrestFilterBuilder
    ) async throws {
        try await filter(client.from(table).update(value))
            .execute()
    }
    
    func delete(
        from table: String,
        filter: (PostgrestFilterBuilder) -> PostgrestFilterBuilder
    ) async throws {
        try await filter(client.from(table).delete())
            .execute()
    }
}

