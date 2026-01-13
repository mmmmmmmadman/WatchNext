import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SearchViewModel()
    @State private var showSettings = false
    @State private var selectedPlatform = APIConfig.selectedPlatformId
    @State private var selectedRegion = APIConfig.selectedRegion

    var body: some View {
        NavigationStack {
            Group {
                if !APIConfig.hasTMDBKey {
                    SettingsPromptView(showSettings: $showSettings)
                } else {
                    SearchResultsView(
                        viewModel: viewModel,
                        selectedPlatform: $selectedPlatform,
                        selectedRegion: $selectedRegion
                    )
                }
            }
            .navigationTitle("WatchNext")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .task {
                viewModel.setCacheService(CacheService(modelContext: modelContext))
                await viewModel.loadGenres()
            }
            .onChange(of: selectedPlatform) {
                APIConfig.setPlatform(selectedPlatform)
                Task {
                    await viewModel.search()
                }
            }
            .onChange(of: selectedRegion) {
                APIConfig.setRegion(selectedRegion)
                Task {
                    await viewModel.search()
                }
            }
        }
    }
}

struct SettingsPromptView: View {
    @Binding var showSettings: Bool

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "key.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("API Key Required")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Configure your TMDB API key to start searching.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button {
                showSettings = true
            } label: {
                Text("Open Settings")
                    .fontWeight(.medium)
                    .frame(maxWidth: 200)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct SearchResultsView: View {
    @Bindable var viewModel: SearchViewModel
    @Binding var selectedPlatform: String
    @Binding var selectedRegion: String

    var body: some View {
        VStack(spacing: 0) {
            // Top filters bar
            VStack(spacing: 12) {
                // Platform and Region row
                HStack(spacing: 16) {
                    Picker("Platform", selection: $selectedPlatform) {
                        ForEach(Constants.TMDB.StreamingPlatform.allPlatforms) { platform in
                            Text(platform.name).tag(platform.id)
                        }
                    }
                    .labelsHidden()

                    Picker("Region", selection: $selectedRegion) {
                        ForEach(Constants.TMDB.Region.availableRegions, id: \.code) { region in
                            Text(region.name).tag(region.code)
                        }
                    }
                    .labelsHidden()
                }

                // Content type
                Picker("Content Type", selection: $viewModel.selectedContentType) {
                    ForEach(ContentType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.selectedContentType) {
                    Task {
                        await viewModel.search()
                    }
                }

                // Filters row
                HStack(spacing: 12) {
                    Picker("Genre", selection: $viewModel.selectedGenre) {
                        Text("All Genres").tag(nil as Genre?)
                        ForEach(viewModel.currentGenres) { genre in
                            Text(genre.name).tag(genre as Genre?)
                        }
                    }
                    .labelsHidden()
                    .onChange(of: viewModel.selectedGenre) {
                        Task {
                            await viewModel.search()
                        }
                    }

                    Picker("Sort", selection: $viewModel.selectedSortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .labelsHidden()
                    .onChange(of: viewModel.selectedSortOption) {
                        if viewModel.selectedSortOption.isLocalSort {
                            viewModel.sortLocally()
                        } else {
                            Task {
                                await viewModel.search()
                            }
                        }
                    }
                }
            }
            .padding()
            .background(.bar)

            Divider()

            // Content area
            if viewModel.isLoading && viewModel.movies.isEmpty && viewModel.tvShows.isEmpty {
                Spacer()
                ProgressView("Loading...")
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                ErrorView(message: error) {
                    Task {
                        await viewModel.search()
                    }
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
                    ], spacing: 16) {
                        switch viewModel.selectedContentType {
                        case .movies:
                            ForEach(Array(viewModel.movies.enumerated()), id: \.element.id) { index, movie in
                                NavigationLink {
                                    MovieDetailView(movie: movie, viewModel: viewModel)
                                } label: {
                                    MovieCardView(movie: movie)
                                }
                                .buttonStyle(.plain)
                                .task {
                                    await viewModel.fetchRatingsForMovie(at: index)
                                }
                                .onAppear {
                                    if index >= viewModel.movies.count - 4 {
                                        Task {
                                            await viewModel.loadMore()
                                        }
                                    }
                                }
                            }

                        case .tvShows:
                            ForEach(Array(viewModel.tvShows.enumerated()), id: \.element.id) { index, show in
                                NavigationLink {
                                    TVShowDetailView(show: show, viewModel: viewModel)
                                } label: {
                                    TVShowCardView(show: show)
                                }
                                .buttonStyle(.plain)
                                .task {
                                    await viewModel.fetchRatingsForTVShow(at: index)
                                }
                                .onAppear {
                                    if index >= viewModel.tvShows.count - 4 {
                                        Task {
                                            await viewModel.loadMore()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
            }
        }
        .task {
            if viewModel.movies.isEmpty && viewModel.tvShows.isEmpty {
                await viewModel.search()
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.orange)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Retry", action: retryAction)
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CachedMovie.self, CachedTVShow.self], inMemory: true)
}
