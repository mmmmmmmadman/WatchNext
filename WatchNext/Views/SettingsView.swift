import SwiftUI

// MARK: - Localization

fileprivate enum AppLanguage {
    case english
    case japanese
    case chineseTraditional

    static var current: AppLanguage {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        if preferredLanguage.hasPrefix("ja") {
            return .japanese
        } else if preferredLanguage.hasPrefix("zh-Hant") || preferredLanguage.hasPrefix("zh-TW") || preferredLanguage.hasPrefix("zh-HK") {
            return .chineseTraditional
        } else {
            return .english
        }
    }
}

fileprivate enum APIHelpType {
    case tmdb
    case omdb
}

private enum LocalizedStrings {

    static var helpButton: String {
        switch AppLanguage.current {
        case .english: return "How to Apply"
        case .japanese: return "申請方法"
        case .chineseTraditional: return "申請說明"
        }
    }

    static func closeButton(for language: AppLanguage) -> String {
        switch language {
        case .english: return "Close"
        case .japanese: return "閉じる"
        case .chineseTraditional: return "關閉"
        }
    }

    static func helpTitle(for type: APIHelpType, language: AppLanguage) -> String {
        switch (type, language) {
        case (.tmdb, .english): return "How to Get TMDB API Key"
        case (.tmdb, .japanese): return "TMDB API Keyの取得方法"
        case (.tmdb, .chineseTraditional): return "如何取得 TMDB API Key"
        case (.omdb, .english): return "How to Get OMDb API Key"
        case (.omdb, .japanese): return "OMDb API Keyの取得方法"
        case (.omdb, .chineseTraditional): return "如何取得 OMDb API Key"
        }
    }

    static func tmdbHelpContent(for language: AppLanguage) -> String {
        switch language {
        case .english:
            return """
            1. Go to themoviedb.org and create a free account
               - Click "Join TMDB" in the top right corner
               - Fill in username, email, and password
               - Verify your email address

            2. After logging in, go to Settings > API
               - Click your profile icon in the top right
               - Select "Settings" from the dropdown
               - Click "API" in the left sidebar

            3. Click "Create" or "Request an API Key"

            4. Select "Developer" option

            5. Accept the Terms of Use

            6. Fill in the application form (copy these exactly):

               Type of Use: Personal

               Application Name: WatchNext

               Application URL: https://github.com/mmmmmmmadman/WatchNext

               Application Summary:
               I am using WatchNext, an open-source macOS application that helps users search and discover movies and TV shows across multiple streaming platforms including Netflix, Apple TV+, Disney+, and Prime Video. The app uses TMDB API to fetch movie/TV show metadata and watch provider information. This is for personal, non-commercial use.

            7. Click "Submit" and wait for approval (usually instant)

            8. Copy your "API Key (v3 auth)" and paste it in the Settings of WatchNext app
            """
        case .japanese:
            return """
            1. themoviedb.org にアクセスし、無料アカウントを作成
               - 右上の「Join TMDB」をクリック
               - ユーザー名、メールアドレス、パスワードを入力
               - メールアドレスを確認

            2. ログイン後、Settings > API に移動
               - 右上のプロフィールアイコンをクリック
               - ドロップダウンから「Settings」を選択
               - 左サイドバーの「API」をクリック

            3.「Create」または「Request an API Key」をクリック

            4.「Developer」オプションを選択

            5. 利用規約に同意

            6. 申請フォームに記入（以下をコピーしてください）:

               Type of Use: Personal

               Application Name: WatchNext

               Application URL: https://github.com/mmmmmmmadman/WatchNext

               Application Summary:
               I am using WatchNext, an open-source macOS application that helps users search and discover movies and TV shows across multiple streaming platforms including Netflix, Apple TV+, Disney+, and Prime Video. The app uses TMDB API to fetch movie/TV show metadata and watch provider information. This is for personal, non-commercial use.

            7.「Submit」をクリックして承認を待つ（通常は即時）

            8.「API Key (v3 auth)」をコピーして、WatchNextアプリの設定に貼り付け
            """
        case .chineseTraditional:
            return """
            1. 前往 themoviedb.org 並建立免費帳號
               - 點擊右上角的「Join TMDB」
               - 填寫使用者名稱、電子郵件和密碼
               - 驗證你的電子郵件地址

            2. 登入後，前往 Settings > API
               - 點擊右上角的個人頭像
               - 從下拉選單中選擇「Settings」
               - 點擊左側欄的「API」

            3. 點擊「Create」或「Request an API Key」

            4. 選擇「Developer」選項

            5. 同意使用條款

            6. 填寫申請表單（請直接複製以下內容）:

               Type of Use: Personal

               Application Name: WatchNext

               Application URL: https://github.com/mmmmmmmadman/WatchNext

               Application Summary:
               I am using WatchNext, an open-source macOS application that helps users search and discover movies and TV shows across multiple streaming platforms including Netflix, Apple TV+, Disney+, and Prime Video. The app uses TMDB API to fetch movie/TV show metadata and watch provider information. This is for personal, non-commercial use.

            7. 點擊「Submit」並等待核准（通常立即通過）

            8. 複製「API Key (v3 auth)」並貼到 WatchNext app 的設定中
            """
        }
    }

    static func omdbHelpContent(for language: AppLanguage) -> String {
        switch language {
        case .english:
            return """
            1. Go to omdbapi.com/apikey.aspx

            2. Select Account Type:
               - Choose "FREE! (1,000 daily limit)"

            3. Fill in the form (copy these exactly):

               Email: Your email address

               First Name: Your first name

               Last Name: Your last name

               Use (Describe your use):
               I am using WatchNext, an open-source macOS application for searching movies and TV shows across streaming platforms. The OMDb API is used to display IMDb ratings and Rotten Tomatoes scores. This is for personal, non-commercial use only.

            4. Complete the CAPTCHA verification

            5. Click "Submit"

            6. Check your email inbox (and spam folder)
               - You will receive an email from OMDb API

            7. Click the activation link in the email
               - Important: You must activate within 24 hours

            8. Copy the API key from the email and paste it in the Settings of WatchNext app

            Note: The free tier allows 1,000 requests per day, which is more than enough for personal use.
            """
        case .japanese:
            return """
            1. omdbapi.com/apikey.aspx にアクセス

            2. アカウントタイプを選択:
               -「FREE! (1,000 daily limit)」を選択

            3. フォームに記入（以下をコピーしてください）:

               Email: あなたのメールアドレス

               First Name: 名前

               Last Name: 名字

               Use (Describe your use):
               I am using WatchNext, an open-source macOS application for searching movies and TV shows across streaming platforms. The OMDb API is used to display IMDb ratings and Rotten Tomatoes scores. This is for personal, non-commercial use only.

            4. CAPTCHA認証を完了

            5.「Submit」をクリック

            6. メールの受信箱を確認（迷惑メールフォルダも確認）
               - OMDb APIからメールが届きます

            7. メール内のアクティベーションリンクをクリック
               - 重要：24時間以内にアクティベーションが必要です

            8. メールに記載されたAPIキーをコピーして、WatchNextアプリの設定に貼り付け

            注意: 無料プランは1日1,000リクエストまでですが、個人利用には十分です。
            """
        case .chineseTraditional:
            return """
            1. 前往 omdbapi.com/apikey.aspx

            2. 選擇帳號類型:
               - 選擇「FREE! (1,000 daily limit)」

            3. 填寫表單（請直接複製以下內容）:

               Email: 你的電子郵件地址

               First Name: 你的名字

               Last Name: 你的姓氏

               Use (Describe your use):
               I am using WatchNext, an open-source macOS application for searching movies and TV shows across streaming platforms. The OMDb API is used to display IMDb ratings and Rotten Tomatoes scores. This is for personal, non-commercial use only.

            4. 完成 CAPTCHA 驗證

            5. 點擊「Submit」

            6. 檢查電子郵件（也檢查垃圾郵件資料夾）
               - 你會收到來自 OMDb API 的郵件

            7. 點擊郵件中的啟用連結
               - 重要：必須在 24 小時內啟用

            8. 複製郵件中的 API key 並貼到 WatchNext app 的設定中

            注意：免費方案每天可請求 1,000 次，個人使用綽綽有餘。
            """
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tmdbKey = APIConfig.tmdbApiKey
    @State private var omdbKey = APIConfig.omdbApiKey
    @State private var showTMDBKey = false
    @State private var showOMDbKey = false
    @State private var showTMDBHelp = false
    @State private var showOMDbHelp = false
    @State private var iCloudStatus: String = "Checking..."
    @State private var iCloudAvailable = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("TMDB API Key")
                                .font(.custom("Avenir-Light", size: 16))
                                .tracking(0.5)
                            Spacer()
                            if APIConfig.hasTMDBKey {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.brandPrimary)
                            }
                        }

                        HStack {
                            if showTMDBKey {
                                TextField("Enter TMDB API Key", text: $tmdbKey)
                                    .textContentType(.password)
                                    #if os(iOS)
                                    .autocapitalization(.none)
                                    #endif
                            } else {
                                SecureField("Enter TMDB API Key", text: $tmdbKey)
                            }

                            Button {
                                showTMDBKey.toggle()
                            } label: {
                                Image(systemName: showTMDBKey ? "eye.slash" : "eye")
                            }
                            .buttonStyle(.borderless)
                        }

                        HStack {
                            Link("Get TMDB API Key", destination: URL(string: "https://www.themoviedb.org/settings/api")!)
                                .font(.caption)

                            Spacer()

                            Button {
                                showTMDBHelp = true
                            } label: {
                                Label(LocalizedStrings.helpButton, systemImage: "questionmark.circle")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                } header: {
                    Text("TMDB Configuration")
                } footer: {
                    Text("Required for searching movies and TV shows.")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("OMDb API Key")
                                .font(.custom("Avenir-Light", size: 16))
                                .tracking(0.5)
                            Spacer()
                            if APIConfig.hasOMDbKey {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.brandPrimary)
                            }
                        }

                        HStack {
                            if showOMDbKey {
                                TextField("Enter OMDb API Key", text: $omdbKey)
                                    .textContentType(.password)
                                    #if os(iOS)
                                    .autocapitalization(.none)
                                    #endif
                            } else {
                                SecureField("Enter OMDb API Key", text: $omdbKey)
                            }

                            Button {
                                showOMDbKey.toggle()
                            } label: {
                                Image(systemName: showOMDbKey ? "eye.slash" : "eye")
                            }
                            .buttonStyle(.borderless)
                        }

                        HStack {
                            Link("Get OMDb API Key", destination: URL(string: "https://www.omdbapi.com/apikey.aspx")!)
                                .font(.caption)

                            Spacer()

                            Button {
                                showOMDbHelp = true
                            } label: {
                                Label(LocalizedStrings.helpButton, systemImage: "questionmark.circle")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                } header: {
                    Text("OMDb Configuration")
                } footer: {
                    Text("Optional. Enables IMDb and Rotten Tomatoes ratings.")
                }

                Section {
                    HStack {
                        Image(systemName: iCloudAvailable ? "icloud.fill" : "icloud.slash")
                            .font(.title2)
                            .foregroundStyle(iCloudAvailable ? .blue : .secondary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("iCloud Sync")
                                .font(.custom("Avenir-Light", size: 16))
                                .tracking(0.5)

                            Text(iCloudStatus)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if iCloudAvailable {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }

                    if iCloudAvailable {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Cloud Data", systemImage: "trash")
                        }
                    }
                } header: {
                    Text("Sync")
                } footer: {
                    Text(iCloudAvailable ? "Your favorites are automatically synced across all your devices." : "Sign in to iCloud in System Settings to sync favorites.")
                }

                Section {
                    VStack(alignment: .center, spacing: 16) {
                        // TMDB Attribution
                        Link(destination: URL(string: "https://www.themoviedb.org")!) {
                            VStack(spacing: 6) {
                                Image(systemName: "film.stack")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.blue)
                                Text("TMDB")
                                    .font(.custom("Avenir-Light", size: 14))
                                    .tracking(0.5)
                                    .foregroundStyle(.primary)
                            }
                        }

                        Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } header: {
                    Text("Data Provider")
                }

                Section {
                    VStack(alignment: .center, spacing: 12) {
                        Text("WatchNext")
                            .font(.custom("Avenir-Light", size: 18))
                            .tracking(1.5)

                        Text("MADZINE")
                            .font(.caption)
                            .foregroundStyle(Color.madzineOrange)

                        Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 20) {
                            Link(destination: URL(string: "https://github.com/mmmmmmmadman/WatchNext")!) {
                                Label("GitHub", systemImage: "link")
                                    .font(.caption)
                            }

                            Link(destination: URL(string: "https://github.com/mmmmmmmadman/WatchNext/blob/main/docs/privacy-policy.md")!) {
                                Label("Privacy", systemImage: "hand.raised")
                                    .font(.caption)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.custom("Avenir-Light", size: 20))
                        .tracking(2)
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.custom("Avenir-Light", size: 15))
                    .tracking(0.8)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        APIConfig.setTMDBApiKey(tmdbKey)
                        APIConfig.setOMDbApiKey(omdbKey)
                        dismiss()
                    }
                    .font(.custom("Avenir-Light", size: 15))
                    .tracking(0.8)
                    .disabled(tmdbKey.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showTMDBHelp) {
            APIHelpSheet(apiType: .tmdb)
        }
        .sheet(isPresented: $showOMDbHelp) {
            APIHelpSheet(apiType: .omdb)
        }
        .alert("Delete Cloud Data", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    try? await SyncService.shared.deleteAllCloudData()
                }
            }
        } message: {
            Text("This will delete all your synced favorites from iCloud. Your local data will be preserved.")
        }
        .task {
            await checkiCloudStatus()
        }
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 650)
        .padding(.horizontal, 20)
        #endif
    }

    private func checkiCloudStatus() async {
        do {
            let status = try await CloudKitService.shared.checkAccountStatus()
            await MainActor.run {
                switch status {
                case .available:
                    iCloudStatus = "Connected"
                    iCloudAvailable = true
                case .noAccount:
                    iCloudStatus = "No iCloud account"
                    iCloudAvailable = false
                case .restricted:
                    iCloudStatus = "Restricted"
                    iCloudAvailable = false
                case .couldNotDetermine:
                    iCloudStatus = "Unknown"
                    iCloudAvailable = false
                case .temporarilyUnavailable:
                    iCloudStatus = "Temporarily unavailable"
                    iCloudAvailable = false
                @unknown default:
                    iCloudStatus = "Unknown"
                    iCloudAvailable = false
                }
            }
        } catch {
            await MainActor.run {
                iCloudStatus = "Error checking status"
                iCloudAvailable = false
            }
        }
    }
}

// MARK: - API Help Sheet

struct APIHelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    fileprivate let apiType: APIHelpType
    @State private var selectedLanguage: AppLanguage = .english

    private var title: String {
        LocalizedStrings.helpTitle(for: apiType, language: selectedLanguage)
    }

    private var content: String {
        switch apiType {
        case .tmdb:
            return LocalizedStrings.tmdbHelpContent(for: selectedLanguage)
        case .omdb:
            return LocalizedStrings.omdbHelpContent(for: selectedLanguage)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Language Picker
                    Picker("Language", selection: $selectedLanguage) {
                        Text("English").tag(AppLanguage.english)
                        Text("繁體中文").tag(AppLanguage.chineseTraditional)
                        Text("日本語").tag(AppLanguage.japanese)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 8)

                    Text(content)
                        .font(.custom("Avenir-Light", size: 14))
                        .lineSpacing(4)
                        .textSelection(.enabled)
                }
                .padding()
            }
            .navigationTitle(title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStrings.closeButton(for: selectedLanguage)) {
                        dismiss()
                    }
                    .font(.custom("Avenir-Light", size: 15))
                    .tracking(0.8)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 450)
        #endif
    }
}

#Preview {
    SettingsView()
}
