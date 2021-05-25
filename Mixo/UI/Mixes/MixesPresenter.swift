//
//  MixesPresenter.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/11/20.
//  Copyright (c) 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

struct MixesViewHandler {
    let setViewModel: (_ viewModel: MixesViewModel?) -> Void
    let showAddToNewMixButton: () -> Void
    let presentMixDetails: (_ presenter: MixDetailsPresenter) -> Void
    let presentEditMixInfo: (_ presenter: EditMixInfoPresenter) -> Void
    let dismiss: () -> Void
}

final class MixesPresenter: Presenter {
    var baseViewHandler: BaseViewHandler?
    var mixesViewHandler: MixesViewHandler?

    private var mixViewModels: [MixViewModel]?

    private let displayMode: MixesDisplayMode

    private let mixesService: MixesService
    private let eventsService: EventsService
    private let networkService: NetworkService
    
    init(displayMode: MixesDisplayMode,
         mixesService: MixesService = AnonymousMixesService.shared,
         eventsService: EventsService = .default,
         networkService: NetworkService = ProductionNetworkService()) {
        self.displayMode = displayMode
        self.mixesService = mixesService
        self.eventsService = eventsService
        self.networkService = networkService
    }
    
    func didBindController() {
        switch displayMode {
        case .add:  mixesViewHandler?.showAddToNewMixButton()
        default:    break
        }

        mixesViewHandler?.setViewModel(nil)
    }

    func viewWillAppear() {
        fetchMixes()
    }

    private func fetchMixes() {
        mixesService.fetchMixes() { mixes in
            let mixViewModels = mixes.map { mix -> MixViewModel in
                let viewModel = MixViewModel(id: mix.id,
                                             name: mix.name,
                                             numberOfTracks: mix.tracks.count,
                                             imageUrl: mix.imageUrl,
                                             didRemoveItemHandler: { [weak self] mixesCount in self?.removeMix(mix, mixesCount: mixesCount) },
                                             didEditItemHandler: { [weak self] name in self?.editMix(mix.id, with: name) })
                switch self.displayMode {
                case let .add(mixTrack, completionHandler):
                    viewModel.didSelectHandler = { [weak self] in
                        self?.mixesService.addToMix(id: mix.id, track: mixTrack)
                        completionHandler()
                        self?.mixesViewHandler?.dismiss()
                    }

                case .default:
                    viewModel.didSelectHandler = { [weak self] in self?.presentMixDetails(mix) }
                }

                return viewModel
            }

            self.mixViewModels = mixViewModels

            let mixesViewModel = MixesViewModel(mixViewModels: mixViewModels, addToNewMixHandler: { [weak self] in
                switch self?.displayMode {
                case let .add(mixTrack, completionHandler):
                    self?.mixesService.createMix(with: mixTrack)
                    completionHandler()
                    self?.mixesViewHandler?.dismiss()

                default:
                    break
                }
    
            }, editMixNameHandler: { [weak self] id, oldName in
                let presenter = EditMixInfoPresenter(oldName: oldName,
                                                     updateMixNameHandler: { [weak self] name in
                                                        self?.editMix(with: id, and: name)
                                                        self?.mixViewModels?.first(where: { $0.id == id })?.didUpdateMixName?(name)
                                                     })
                self?.mixesViewHandler?.presentEditMixInfo(presenter)
            })

            if mixViewModels.isEmpty {
                self.baseViewHandler?.showStatus(.empty(title: "No mixes", description: "Create new mix and start adding tracks there"), true)
            }
            self.mixesViewHandler?.setViewModel(mixesViewModel)
        }
    }

    func addNewMix() {
        baseViewHandler?.hideStatus(true)
        mixesService.createMix(with: nil)
        fetchMixes()
    }

    func editMix(with id: String, and name: String) {
        mixesService.editMix(id, with: name)
    }
}

// MARK: - Private methods
extension MixesPresenter {
    private func presentMixDetails(_ mix: Mix) {
        let mixDetailsPresenter = MixDetailsPresenter(mix: mix, didUpdateTracks: { [weak self] in
            self?.fetchMixes()
        })
        mixesViewHandler?.presentMixDetails(mixDetailsPresenter)
    }

    private func removeMix(_ mix: Mix, mixesCount: Int) {
        mixesService.removeMix(mix)
        if mixesCount == 1 {
            baseViewHandler?.showStatus(.empty(title: "No mixes", description: "Create new mix and start adding tracks there"), true)
        }
    }

    private func editMix(_ mixId: String, with name: String) {
        mixesService.editMix(mixId, with: name)
    }
}
