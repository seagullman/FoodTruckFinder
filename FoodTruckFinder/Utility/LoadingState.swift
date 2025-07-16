//
//  LoadingState.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/12/24.
//

import SwiftUI

// MARK: - LoadingState

/// A generic loading state enum that can represent loading, loaded, or failed states
/// for any type that conforms to Equatable
enum LoadingState<T: Equatable>: Equatable {
    case loading
    case loaded(T)
    case failed(AlertItem)
    
    static func == (lhs: LoadingState<T>, rhs: LoadingState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded(let lhsValue), .loaded(let rhsValue)):
            return lhsValue == rhsValue
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.id == rhsError.id
        default:
            return false
        }
    }
}

// MARK: - AuthLoadingState

/// A specialized loading state for authentication operations that don't return meaningful data
/// This is a simplified version of LoadingState that doesn't need a generic type parameter
enum AuthLoadingState: Equatable {
    case loading
    case loaded
    case failed(AlertItem)
    
    static func == (lhs: AuthLoadingState, rhs: AuthLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded, .loaded):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.id == rhsError.id
        default:
            return false
        }
    }
} 