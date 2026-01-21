import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: FavoritesViewModel
    @State private var selectedMediaType: MediaType = .movie

    var body: some View {
        VStack(spacing: 0) {
            Picker("Content Type", selection: $selectedMediaType) {
                Text("Movies").tag(MediaType.movie)
                Text("TV Shows").tag(MediaType.tv)
            }
            .pickerStyle(.segmented)
            .padding()

            if filteredFavorites.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(filteredFavorites) { item in
                            FavoriteCardView(item: item)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteFavorite(item)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    private var filteredFavorites: [FavoriteItem] {
        switch selectedMediaType {
        case .movie:
            return viewModel.movieFavorites
        case .tv:
            return viewModel.tvShowFavorites
        }
    }

    private var gridColumns: [GridItem] {
        #if os(iOS)
        [GridItem(.adaptive(minimum: 110, maximum: 150), spacing: 12)]
        #else
        [GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 16)]
        #endif
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label(
                selectedMediaType == .movie ? "No Favorite Movies" : "No Favorite TV Shows",
                systemImage: "heart"
            )
        } description: {
            Text("Items you mark as favorites will appear here.")
        }
    }
}

struct FavoriteCardView: View {
    let item: FavoriteItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: item.posterURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(.quaternary)
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(.quaternary)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.tertiary)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            #if os(iOS)
            .frame(height: 165)
            #else
            .frame(height: 225)
            #endif
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                if let year = item.releaseYear {
                    Text(String(year))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
