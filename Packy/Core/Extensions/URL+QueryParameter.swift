//
//  URL+QueryParameter.swift
//  Packy
//
//  Created by Mason Kim on 2/4/24.
//

import Foundation

extension URL {
    var queryParameters: QueryParameters {
        return QueryParameters(url: self)
    }
}

struct QueryParameters {
    let queryItems: [URLQueryItem]

    init(url: URL?) {
        queryItems = URLComponents(string: url?.absoluteString ?? "")?.queryItems ?? []
        print(queryItems)
    }

    subscript(name: String) -> String? {
        return queryItems.first(where: { $0.name == name })?.value
    }
}
