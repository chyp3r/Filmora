//
//  MovieSearchViewswift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 18.08.2025.
//

import Foundation

enum MovieSearchViewConstants {
    static let searchContainerTopMargin: CGFloat = 16
    static let searchContainerLeadingTrailingMargin: CGFloat = 16
    static let searchContainerHeight: CGFloat = 44
    static let searchTextFieldHorizontalPadding: CGFloat = 12

    static let tableViewTopMargin: CGFloat = 12

    static let emptyStateMessageLeadingTrailingPadding: CGFloat = 32
    static let emptyMessageBottomMargin: CGFloat = 24
    static let emptyActionButtonWidth: CGFloat = 180
    static let emptyActionButtonHeight: CGFloat = 44

    static let emptyActionButtonCornerRadius: CGFloat = 20
    static let emptyActionButtonBorderWidth: CGFloat = 2

    static let debounceInterval: TimeInterval = 0.3
    static let infiniteScrollTriggerOffset: CGFloat = 120
    static let cornerRadius: CGFloat = 12.0

    enum RecentCell {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let spacing: CGFloat = 8
        static let deleteButtonSize: CGFloat = 20
    }
}
