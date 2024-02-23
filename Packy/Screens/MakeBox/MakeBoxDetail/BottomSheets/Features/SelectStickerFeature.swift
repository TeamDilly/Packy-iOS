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

        var stickerDesigns: [StickerDesignResponse] = []
        var selectedStickers: [StickerDesign] = []
    }

    enum Action {
        case stickerInputButtonTapped
        case stickerConfirmButtonTapped
        case stickerTapped(StickerDesign)

        case fetchMoreStickers
        case _fetchStickerDesigns
        case _setStickerDesigns(StickerDesignResponse)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.adminClient) var adminClient

    // MARK: - Reducer

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .stickerInputButtonTapped:
                state.isStickerBottomSheetPresented = true
                return .none

            case .stickerConfirmButtonTapped:
                state.isStickerBottomSheetPresented = false
                return .none

            case let .stickerTapped(sticker):
                // 이미 해당 스티커가 존재하면 삭제
                if let index = state.selectedStickers.firstIndex(of: sticker) {
                    state.selectedStickers.remove(at: index)
                    return .none
                }
                
                // 2개 까지만 선택
                guard state.selectedStickers.count < 2 else { return .none }
                state.selectedStickers.append(sticker)
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
