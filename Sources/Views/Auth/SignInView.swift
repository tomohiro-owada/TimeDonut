//
//  SignInView.swift
//  TimeDonut
//
//  Created on 2025-10-26.
//

import SwiftUI

/// Sign-in view that presents Google authentication interface
/// This view is displayed when the user needs to authenticate with their Google account
struct SignInView: View {
    // MARK: - Properties

    /// Reference to the app state that manages authentication
    @ObservedObject var appState: AppStateViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            // App branding section
            VStack(spacing: 12) {
                // App icon/emoji
                Text("🍩")
                    .font(.system(size: 64))

                // App name
                Text("TimeDonut")
                    .font(.system(size: 28, weight: .bold))

                // Description
                Text("Google カレンダーと連携して\n時間を可視化します")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, 32)

            Spacer()

            // Error message section
            if let errorMessage = appState.errorMessage {
                HStack {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal)

                    Button(action: {
                        appState.errorMessage = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .imageScale(.small)
                    }
                    .buttonStyle(.plain)
                    .help("エラーを閉じる")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.1))
                )
                .padding(.horizontal, 32)
            }

            // Sign-in button section
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        await appState.signIn()
                    }
                }) {
                    HStack {
                        if appState.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "person.circle.fill")
                        }

                        Text("Googleでサインイン")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(appState.isLoading)
                .padding(.horizontal, 32)

                // Loading indicator below button
                if appState.isLoading {
                    Text("サインイン中...")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .frame(width: 400, height: 300)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Preview

#Preview {
    SignInView(appState: AppStateViewModel())
}
