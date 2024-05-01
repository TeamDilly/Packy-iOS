//
//  SelectStickerFeature.swift
//  Packy
//
//  Created by Mason Kim on 2/12/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SelectStickerFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var isStickerBottomSheetPresented: Bool = false

        var selectingStickerType: StickerType = .first
        var stickerDesigns: [StickerDesignResponse] = []
        var selectedStickers: [StickerType: StickerDesign] = [:]
    }

    enum Action {
        case firstStickerInputButtonTapped
        case secondStickerInputButtonTapped
        case stickerConfirmButtonTapped
        case stickerTapped(StickerDesign)

        case fetchMoreStickers
        case _fetchStickerDesigns
        case _setStickerDesigns(StickerDesignResponse)
    }

    enum StickerType: Int {
        case first
        case second
    }

    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.adminClient) var adminClient

    // MARK: - Reducer

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .firstStickerInputButtonTapped:
                state.selectingStickerType = .first
                state.isStickerBottomSheetPresented = true
                return .none

            case .secondStickerInputButtonTapped:
                state.selectingStickerType = .second
                state.isStickerBottomSheetPresented = true
                return .none

            case .stickerConfirmButtonTapped:
                state.isStickerBottomSheetPresented = false
                return .none

            case let .stickerTapped(sticker):
                let stickerType = state.selectingStickerType
                guard state.selectedStickers[stickerType] != sticker else {
                    state.selectedStickers.removeValue(forKey: stickerType)
                    return .none
                }

                state.selectedStickers[stickerType] = sticker
                return .none
                
            case let ._setStickerDesigns(response):
                state.stickerDesigns.append(response)
                return .none
                
            case .fetchMoreStickers:
                let lastStickerId = state.stickerDesigns.last?.contents.last?.id ?? 0
                return fetchStickerDesigns(lastStickerId: lastStickerId)
                
            case ._fetchStickerDesigns:
                return fetchStickerDesigns()
            }
        }
    }

}

// MARK: - Inner Functions

private extension SelectStickerFeature {
    func fetchStickerDesigns(lastStickerId: Int? = nil) -> Effect<Action> {
        .run { send in
            do {
                let response = try await adminClient.fetchStickerDesigns(lastStickerId)
                await send(._setStickerDesigns(response))
            } catch {
                print(error)
            }
        }
    }
}
