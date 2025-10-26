import Foundation

enum Constants {
    // MARK: - Google API
    enum Google {
        static let clientID = "1026560217299-rmn54q3seicccfsmkeug21goik2o380l.apps.googleusercontent.com"
        // Client Secretは削除（Cloud Functionsに保存）
        static let calendarScope = "https://www.googleapis.com/auth/calendar.readonly"
        static let redirectURI = "http://localhost:51280/callback"
        static let localPort: UInt16 = 51280 // TimeDonut専用ポート番号
    }

    // MARK: - Cloud Functions
    enum CloudFunctions {
        static let authURL = "https://asia-northeast1-timedonut.cloudfunctions.net/auth"
        static let eventsURL = "https://asia-northeast1-timedonut.cloudfunctions.net/events"
    }

    // MARK: - Timing
    enum Timing {
        static let uiUpdateInterval: TimeInterval = 1.0  // 1秒ごとにUI更新
        static let calendarSyncInterval: TimeInterval = 300.0  // 5分ごとにカレンダー同期
        static let apiTimeout: TimeInterval = 30.0  // APIタイムアウト
    }

    // MARK: - UI
    enum UI {
        static let popoverWidth: CGFloat = 360
        static let popoverMinHeight: CGFloat = 500
        static let popoverMaxHeight: CGFloat = 700
        static let clockRadius: CGFloat = 120
        static let donutInnerRadius: CGFloat = 140
        static let donutOuterRadius: CGFloat = 160
    }

    // MARK: - App
    enum App {
        static let name = "TimeDonut"
        static let version = "1.0.0"
        static let bundleIdentifier = "com.timedonut.app"
    }

    // MARK: - Keychain
    enum Keychain {
        static let serviceName = "com.timedonut.app"
        static let userIDKey = "timedonut.userID"
        static let userEmailKey = "timedonut.userEmail"
    }
}
