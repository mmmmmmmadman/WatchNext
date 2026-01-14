import SwiftUI

struct MovieCardView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: movie.posterURL) { phase in
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
                Text(movie.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                if let year = movie.releaseYear {
                    Text(String(year))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    RatingPill(label: "TMDB", value: String(format: "%.1f", movie.voteAverage), color: .blue)
                    if let imdb = movie.imdbRating {
                        RatingPill(label: "IMDb", value: String(format: "%.1f", imdb), color: .yellow)
                    }
                    if let rt = movie.rottenTomatoesRating {
                        RatingPill(label: "RT", value: "\(rt)", color: .red)
                    }
                }
            }
        }
    }
}

struct TVShowCardView: View {
    let show: TVShow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: show.posterURL) { phase in
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
                Text(show.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                if let year = show.firstAirYear {
                    Text(String(year))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    RatingPill(label: "TMDB", value: String(format: "%.1f", show.voteAverage), color: .blue)
                    if let imdb = show.imdbRating {
                        RatingPill(label: "IMDb", value: String(format: "%.1f", imdb), color: .yellow)
                    }
                    if let rt = show.rottenTomatoesRating {
                        RatingPill(label: "RT", value: "\(rt)", color: .red)
                    }
                }
            }
        }
    }
}

struct RatingPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 10))
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .frame(width: 28)
        .padding(.vertical, 3)
        .background(.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview("Movie Card") {
    MovieCardView(movie: Movie(
        id: 1,
        title: "Test Movie",
        originalTitle: "Test Movie",
        overview: "A test movie",
        releaseDate: "2024-01-01",
        posterPath: nil,
        backdropPath: nil,
        genreIds: [27],
        voteAverage: 7.5,
        voteCount: 100,
        popularity: 50.0
    ))
    .frame(width: 160)
    .padding()
}
