//
//  CGFloat.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//

import Foundation

extension CGFloat {
    public static let defaultCornerRadius: Self = 8
    public static let spacings = Spacings()
    public static let paddings = Paddings()
}

public struct Spacings {
    public let grid: CGFloat = 16
    public let vStack: CGFloat = 12
}

public struct Paddings {
    public let top: CGFloat = 4
    public let regular: CGFloat = 4
}
