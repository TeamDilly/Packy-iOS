//
//  BoxStartGuideFeature.swift
//  Packy
//
//  Created Mason Kim on 1/13/24.
//

import Foundation
import ComposableArchitecture
import YouTubePlayerKit
import SwiftUI

@Reducer
struct BoxStartGuideFeature: Reducer {

    enum MusicBottomSheetMode {
        case choice
        case userSelect
        case recommend
    }

    struct State: Equatable {
        @BindingState var isMusicBottomSheetPresented: Bool = true
        var musicBottomSheetMode: MusicBottomSheetMode = .userSelect

        @BindingState var musicLinkUrlInput: String = ""
        var musicLinkPlayer: YouTubePlayer? = "https://www.youtube.com/watch?v=hbnnNgtdYSo"

        @BindingState var isLetterBottomSheetPresented: Bool = false
        @BindingState var isPhotoBottomSheetPresented: Bool = false
        @BindingState var isGiftBottomSheetPresented: Bool = false
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case musicBottomSheetBackButtonTapped
        case musicChoiceUserSelectButtonTapped
        case musicChoiceRecommendButtonTapped

        case musicLinkConfirmButtonTapped
        case musicLinkSaveButtonTapped
        case musicLinkDeleteButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
    }


    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return .none

            default:
                return .none
            }
        }
    }
}
