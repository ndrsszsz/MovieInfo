//
//  Array.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//

import Foundation

extension Array where Element: Identifiable {
    func appendingUnique(_ newElements: [Element]) -> [Element] {
        var existingIds = Set(self.map { $0.id })
        var filteredNew = [Element]()

        for element in newElements {
            if !existingIds.contains(element.id) {
                existingIds.insert(element.id)
                filteredNew.append(element)
            }
        }
        return self + filteredNew
    }
}
