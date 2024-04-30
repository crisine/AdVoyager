//
//  PostQuery.swift
//  AdVoyager
//
//  Created by Minho on 4/21/24.
//

struct PostQuery: Encodable {
    let next: String
    let limit: String
    let product_id: String
}

struct UploadPostQuery: Encodable {
    let title: String?
    let content: String?
    let content1: String?
    let content2: String?
    let content3: String?
    let content4: String?
    let content5: String?
    let product_id: String
    let files: [String]
    
    init(title: String? = nil, content: String? = nil, content1: String? = nil, content2: String? = nil, content3: String? = nil, content4: String? = nil, content5: String? = nil, product_id: String = "advoyager", files: [String]) {
        self.title = title
        self.content = content
        self.content1 = content1
        self.content2 = content2
        self.content3 = content3
        self.content4 = content4
        self.content5 = content5
        self.product_id = product_id
        self.files = files
    }
}
