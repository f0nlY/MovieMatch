//
//  Movie.swift
//  MovieMatch
//
//  Created by Ilya on 24.05.2026.
//

import Foundation

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?
    let originalLanguage: String
    let genreIds: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case originalLanguage = "original_language"
        case genreIds = "genre_ids"
    }
    
    var fullPosterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    var year: String {
        guard let date = releaseDate, date.count >= 4 else { return "" }
        return String(date.prefix(4))
    }
    
    static let genreDictionary: [Int: String] = [
        28: "Боевик", 12: "Приключения", 16: "Мультфильм", 35: "Комедия",
        80: "Криминал", 99: "Документальный", 18: "Драма", 10751: "Семейный",
        14: "Фэнтези", 36: "История", 27: "Ужасы", 10402: "Музыка",
        9648: "Детектив", 10749: "Мелодрама", 878: "Фантастика",
        10770: "ТВ-Фильм", 53: "Триллер", 10752: "Военный", 37: "Вестерн"
    ]
    
    var primaryGenre: String {
        guard let firstId = genreIds?.first else { return "Кино" }
        return Movie.genreDictionary[firstId] ?? "Кино"
    }
}
