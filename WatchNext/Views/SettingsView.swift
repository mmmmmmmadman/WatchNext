import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tmdbKey = APIConfig.tmdbApiKey
    @State private var omdbKey = APIConfig.omdbApiKey
    @State private var showTMDBKey = false
    @State private var showOMDbKey = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("TMDB API Key")
                            Spacer()
                            if APIConfig.hasTMDBKey {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
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

                        Link("Get TMDB API Key", destination: URL(string: "https://www.themoviedb.org/settings/api")!)
                            .font(.caption)
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
                            Spacer()
                            if APIConfig.hasOMDbKey {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
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

                        Link("Get OMDb API Key", destination: URL(string: "https://www.omdbapi.com/apikey.aspx")!)
                            .font(.caption)
                    }
                } header: {
                    Text("OMDb Configuration")
                } footer: {
                    Text("Optional. Enables IMDb and Rotten Tomatoes ratings.")
                }

                Section {
                    Button("Save API Keys") {
                        APIConfig.setTMDBApiKey(tmdbKey)
                        APIConfig.setOMDbApiKey(omdbKey)
                        dismiss()
                    }
                    .disabled(tmdbKey.isEmpty)
                }

                Section {
                    VStack(alignment: .center, spacing: 12) {
                        Link(destination: URL(string: "https://www.themoviedb.org")!) {
                            VStack(spacing: 8) {
                                Image(systemName: "film.stack")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.blue)
                                Text("TMDB")
                                    .font(.headline)
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
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
