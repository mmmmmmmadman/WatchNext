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
                        selectedRegion: $selectedRegion,
                        showSettings: $showSettings
                    )
                }
            }
            .modifier(CustomNavigationTitleModifier(showSettings: $showSettings))
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
                    await viewModel.discover()
                }
            }
            .onChange(of: selectedRegion) {
                APIConfig.setRegion(selectedRegion)
                Task {
                    await viewModel.discover()
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
                .font(.custom("Avenir-Light", size: 20))
                .tracking(1)

            Text("Configure your TMDB API key to start.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button {
                showSettings = true
            } label: {
                Text("Open Settings")
                    .font(.custom("Avenir-Light", size: 15))
                    .tracking(0.5)
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
    @Binding var showSettings: Bool

    private var gridColumns: [GridItem] {
        #if os(iOS)
        [GridItem(.adaptive(minimum: 110, maximum: 180), spacing: 12)]
        #else
        [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)]
        #endif
    }

    var body: some View {
        VStack(spacing: 0) {
            #if os(iOS)
            // iOS: Two-row compact filter layout
            VStack(spacing: 8) {
                // Row 1: Platform, Region, Content Type
                HStack(spacing: 12) {
                    // Platform
                    Menu {
                        ForEach(Constants.TMDB.StreamingPlatform.allPlatforms) { platform in
                            Button(platform.name) {
                                selectedPlatform = platform.id
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(Constants.TMDB.StreamingPlatform.find(by: selectedPlatform)?.name ?? "Platform")
                                .font(.subheadline)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.primary)
                    }

                    // Region
                    Menu {
                        ForEach(Constants.TMDB.Region.availableRegions, id: \.code) { region in
                            Button(region.name) {
                                selectedRegion = region.code
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedRegion)
                                .font(.subheadline)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.primary)
                    }

                    Spacer()

                    // Content type (segmented)
                    Picker("", selection: $viewModel.selectedContentType) {
                        ForEach(ContentType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(width: 140)
                    .onChange(of: viewModel.selectedContentType) {
                        Task {
                            await viewModel.discover()
                        }
                    }
                }

                // Row 2: Genre, Sort, Reset
                HStack(spacing: 12) {
                    // Genre
                    Menu {
                        Button("All Genres") {
                            viewModel.selectedGenre = nil
                        }
                        ForEach(viewModel.currentGenres) { genre in
                            Button(genre.name) {
                                viewModel.selectedGenre = genre
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedGenre?.name ?? "All Genres")
                                .font(.subheadline)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.primary)
                    }
                    .onChange(of: viewModel.selectedGenre) {
                        Task {
                            await viewModel.discover()
                        }
                    }

                    // Sort
                    Menu {
                        ForEach(SortOption.allCases) { option in
                            Button(option.displayName) {
                                viewModel.selectedSortOption = option
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedSortOption.displayName)
                                .font(.subheadline)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.primary)
                    }
                    .onChange(of: viewModel.selectedSortOption) {
                        if viewModel.selectedSortOption.isLocalSort {
                            viewModel.sortLocally()
                        } else {
                            Task {
                                await viewModel.discover()
                            }
                        }
                    }

                    Spacer()

                    // Reset button
                    Button {
                        viewModel.resetFilters()
                        Task {
                            await viewModel.discover()
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.bar)
            #else
            // macOS: Single row compact filter layout
            HStack(spacing: 8) {
                // Platform
                Picker("", selection: $selectedPlatform) {
                    ForEach(Constants.TMDB.StreamingPlatform.allPlatforms) { platform in
                        Text(platform.name).tag(platform.id)
                    }
                }
                .labelsHidden()
                .frame(width: 100)

                // Region
                Picker("", selection: $selectedRegion) {
                    ForEach(Constants.TMDB.Region.availableRegions, id: \.code) { region in
                        Text(region.name).tag(region.code)
                    }
                }
                .labelsHidden()
                .frame(width: 90)

                Divider()
                    .frame(height: 20)

                // Content type (segmented, no label)
                Picker("", selection: $viewModel.selectedContentType) {
                    ForEach(ContentType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 160)
                .onChange(of: viewModel.selectedContentType) {
                    Task {
                        await viewModel.discover()
                    }
                }

                Divider()
                    .frame(height: 20)

                // Genre
                Picker("", selection: $viewModel.selectedGenre) {
                    Text("All Genres").tag(nil as Genre?)
                    ForEach(viewModel.currentGenres) { genre in
                        Text(genre.name).tag(genre as Genre?)
                    }
                }
                .labelsHidden()
                .frame(width: 120)
                .onChange(of: viewModel.selectedGenre) {
                    Task {
                        await viewModel.discover()
                    }
                }

                // Sort
                Picker("", selection: $viewModel.selectedSortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .labelsHidden()
                .frame(width: 130)
                .onChange(of: viewModel.selectedSortOption) {
                    if viewModel.selectedSortOption.isLocalSort {
                        viewModel.sortLocally()
                    } else {
                        Task {
                            await viewModel.discover()
                        }
                    }
                }

                Spacer()

                // Reset button (icon only)
                Button {
                    viewModel.resetFilters()
                    Task {
                        await viewModel.discover()
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Reset Filters")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.bar)
            #endif

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
                        await viewModel.discover()
                    }
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 16) {
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
                await viewModel.discover()
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

// MARK: - Custom Navigation Title Modifier

struct CustomNavigationTitleModifier: ViewModifier {
    @Binding var showSettings: Bool

    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .navigationTitle("WatchNext")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        #else
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("WatchNext")
                        .font(.custom("Avenir-Light", size: 18))
                        .tracking(1.5)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        #endif
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CachedMovie.self, CachedTVShow.self], inMemory: true)
}
