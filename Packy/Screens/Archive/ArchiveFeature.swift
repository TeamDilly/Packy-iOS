//
//  ArchiveFeature.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ArchiveFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var selectedTab: ArchiveTab = .photo

        var photoArchive: PhotoArchiveFeature.State = .init()
        var letterArchive: LetterArchiveFeature.State = .init()
        var musicArchive: MusicArchiveFeature.State = .init()
        var giftArchive: GiftArchiveFeature.State = .init()
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
        case photoArchive(PhotoArchiveFeature.Action)
        case letterArchive(LetterArchiveFeature.Action)
        case musicArchive(MusicArchiveFeature.Action)
        case giftArchive(GiftArchiveFeature.Action)
    }


    var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.photoArchive, action: \.photoArchive) { PhotoArchiveFeature() }
        Scope(state: \.letterArchive, action: \.letterArchive) { LetterArchiveFeature() }
        Scope(state: \.musicArchive, action: \.musicArchive) { MusicArchiveFeature() }
        Scope(state: \.giftArchive, action: \.giftArchive) { GiftArchiveFeature() }
    }
}
