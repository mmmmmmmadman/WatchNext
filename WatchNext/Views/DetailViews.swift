import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    let viewModel: SearchViewModel
    @State private var watchURL: URL?
    @State private var isLoadingLink = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let backdropURL = movie.backdropURL {
                    AsyncImage(url: backdropURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Rectangle()
                                .fill(.quaternary)
                        }
                    }
                    .frame(height: 200)
                    .clipped()
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        if let posterURL = movie.posterURL {
                            AsyncImage(url: posterURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                default:
                                    Rectangle()
                                        .fill(.quaternary)
                                }
                            }
                            .frame(width: 120, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(radius: 4)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(movie.title)
                                .font(.title2)
                                .fontWeight(.bold)

                            if movie.originalTitle != movie.title {
                                Text(movie.originalTitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if let year = movie.releaseYear {
                                Text(String(year))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ratings")
                            .font(.headline)

                        HStack(spacing: 20) {
                            RatingCard(
                                title: "TMDB",
                                value: String(format: "%.1f", movie.voteAverage),
                                color: .blue
                            )

                            if let imdb = movie.imdbRating {
                                RatingCard(
                                    title: "IMDb",
                                    value: String(format: "%.1f", imdb),
                                    color: .yellow
                                )
                            }

                            if let rt = movie.rottenTomatoesRating {
                                RatingCard(
                                    title: "RT",
                                    value: "\(rt)",
                                    color: .red
                                )
                            }
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Overview")
                            .font(.headline)

                        Text(movie.overview.isEmpty ? "No overview available." : movie.overview)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    if isLoadingLink {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading...")
                                .foregroundStyle(.secondary)
                        }
                    } else if let watchURL = watchURL {
                        Link(destination: watchURL) {
                            HStack {
                                Image(systemName: "play.tv.fill")
                                Text("Watch on \(APIConfig.selectedPlatform.name)")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(movie.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            isLoadingLink = true
            watchURL = await viewModel.getWatchLink(for: movie)
            isLoadingLink = false
        }
    }
}

struct TVShowDetailView: View {
    let show: TVShow
    let viewModel: SearchViewModel
    @State private var watchURL: URL?
    @State private var isLoadingLink = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let backdropURL = show.backdropURL {
                    AsyncImage(url: backdropURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Rectangle()
                                .fill(.quaternary)
                        }
                    }
                    .frame(height: 200)
                    .clipped()
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        if let posterURL = show.posterURL {
                            AsyncImage(url: posterURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                default:
                                    Rectangle()
                                        .fill(.quaternary)
                                }
                            }
                            .frame(width: 120, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(radius: 4)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(show.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            if show.originalName != show.name {
                                Text(show.originalName)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if let year = show.firstAirYear {
                                Text(String(year))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ratings")
                            .font(.headline)

                        HStack(spacing: 20) {
                            RatingCard(
                                title: "TMDB",
                                value: String(format: "%.1f", show.voteAverage),
                                color: .blue
                            )

                            if let imdb = show.imdbRating {
                                RatingCard(
                                    title: "IMDb",
                                    value: String(format: "%.1f", imdb),
                                    color: .yellow
                                )
                            }

                            if let rt = show.rottenTomatoesRating {
                                RatingCard(
                                    title: "RT",
                                    value: "\(rt)",
                                    color: .red
                                )
                            }
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Overview")
                            .font(.headline)

                        Text(show.overview.isEmpty ? "No overview available." : show.overview)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    if isLoadingLink {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading...")
                                .foregroundStyle(.secondary)
                        }
                    } else if let watchURL = watchURL {
                        Link(destination: watchURL) {
                            HStack {
                                Image(systemName: "play.tv.fill")
                                Text("Watch on \(APIConfig.selectedPlatform.name)")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(show.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            isLoadingLink = true
            watchURL = await viewModel.getWatchLink(for: show)
            isLoadingLink = false
        }
    }
}

struct RatingCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("Movie Detail") {
    NavigationStack {
        MovieDetailView(
            movie: Movie(
                id: 1,
                title: "Test Movie",
                originalTitle: "Test Movie Original",
                overview: "This is a test movie with a long description.",
                releaseDate: "2024-01-01",
                posterPath: nil,
                backdropPath: nil,
                genreIds: [27, 53],
                voteAverage: 7.5,
                voteCount: 1500,
                popularity: 50.0
            ),
            viewModel: SearchViewModel()
        )
    }
}
