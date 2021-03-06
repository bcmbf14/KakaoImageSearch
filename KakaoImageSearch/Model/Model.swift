//
//  Model.swift
//  KakaoImageSearch
//
//  Created by jc.kim on 3/5/21.
//

import Foundation

// MARK: - Welcome
struct SearchImage: Decodable {
    let documents: [Document]
    let meta: Meta
}

// MARK: - Document
struct Document: Decodable {
    let collection: String
    let datetime, displaySitename: String
    let docURL: String
    let height: Int
    let imageURL: String
    let thumbnailURL: String
    let width: Int

    enum CodingKeys: String, CodingKey {
        case collection
        case datetime
        case displaySitename = "display_sitename"
        case docURL = "doc_url"
        case height
        case imageURL = "image_url"
        case thumbnailURL = "thumbnail_url"
        case width
    }
}

// MARK: - Meta
struct Meta: Decodable {
    let isEnd: Bool
    let pageableCount, totalCount: Int

    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
    }
}
