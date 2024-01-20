//
//  URL+Trimming.swift
//  Packy
//
//  Created by Mason Kim on 1/20/24.
//

import Foundation

extension URL {
    var trimmedUntilPath: String {
        return "\(scheme ?? "")://\(host ?? "")\(path)"
    }
}
