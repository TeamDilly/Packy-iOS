//
//  YoutubeThumbnailGenerator.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import Foundation

enum YoutubeThumbnailGenerator {
    /// 유튜브 링크로부터 썸네일 URL 구성
    static func thumbnailUrl(fromYoutubeUrl youtubeUrl: String) -> String? {
        guard let id = extractId(youtubeUrl: youtubeUrl) else { return nil }
        return thumbnailUrl(fromVideoId: id)
    }

    /// id값으로부터 썸네일 URL을 구성
    static func thumbnailUrl(fromVideoId videoId: String) -> String {
        return "https://img.youtube.com/vi/\(videoId)/mqdefault.jpg"
    }

    /// 유튜브 링크에서 영상 id 값 추출
    static func extractId(youtubeUrl: String) -> String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]+)"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: youtubeUrl.count)

        guard let result = regex?.firstMatch(in: youtubeUrl, options: [], range: range) else {
            return nil
        }

        return (youtubeUrl as NSString).substring(with: result.range)
    }
}
