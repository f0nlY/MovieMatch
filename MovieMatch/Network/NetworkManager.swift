//
//  NetworkManager.swift
//  MovieMatch
//
//  Created by Ilya on 24.05.2026.
//

import Foundation

class NetworkManager: ObservableObject {
    @Published var movies: [Movie] = []
    
    private let apiKey = "1b2a2119d25fa04d95bd021fab81c75b"
    private var currentPage = 1
    private var isLoading = false
    
    func resetAndFetch(genres: [String] = [], isSolo: Bool = false) {
        movies.removeAll()
        currentPage = 1
        isLoading = false
        fetchMovies(genres: genres, isSolo: isSolo)
    }
    
    func fetchMovies(genres: [String] = [], isSolo: Bool = false) {
        guard !isLoading else { return }
        isLoading = true
        
        let baseParams = "api_key=\(apiKey)&language=ru-RU&page=\(currentPage)&sort_by=popularity.desc&primary_release_date.gte=2015-01-01&vote_count.gte=1500&vote_average.gte=6.5"
        
        var urlString = "https://api.themoviedb.org/3/discover/movie?\(baseParams)"
        
        if !genres.isEmpty {
            let genreIDs = genres.compactMap { genreName in
                Movie.genreDictionary.first(where: { $0.value == genreName })?.key
            }
            let idsString = genreIDs.map(String.init).joined(separator: "%7C")
            urlString += "&with_genres=\(idsString)"
        }
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            defer { self.isLoading = false }
            if let error = error {
                print("Ошибка сети: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }
            
            do {
                let decodedData = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    let fetchedMovies = decodedData.results
                    self.movies.append(contentsOf: isSolo ? fetchedMovies.shuffled() : fetchedMovies)
                    self.currentPage += 1
                }
            } catch {
                print("Ошибка парсинга JSON: \(error)")
            }
        }.resume()
    }
    
    func fetchPopularMovies() {
        fetchMovies(genres: [], isSolo: true)
    }
}
