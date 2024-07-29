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

    enum Action: ViewAction {
        case view(View)

        // MARK: Child Action
        case photoArchive(PhotoArchiveFeature.Action)
        case letterArchive(LetterArchiveFeature.Action)
        case musicArchive(MusicArchiveFeature.Action)
        case giftArchive(GiftArchiveFeature.Action)

        enum View: BindableAction {
            case onTask
            case binding(BindingAction<State>)
        }
    }


    var body: some Reducer<State, Action> {
        BindingReducer(action: \.view)

        Scope(state: \.photoArchive, action: \.photoArchive) { PhotoArchiveFeature() }
        Scope(state: \.letterArchive, action: \.letterArchive) { LetterArchiveFeature() }
        Scope(state: \.musicArchive, action: \.musicArchive) { MusicArchiveFeature() }
        Scope(state: \.giftArchive, action: \.giftArchive) { GiftArchiveFeature() }
    }
}
