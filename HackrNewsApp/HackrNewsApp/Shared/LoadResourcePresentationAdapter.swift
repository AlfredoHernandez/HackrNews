//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation
import HackrNews
import HackrNewsiOS

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    private let loader: () -> AnyPublisher<Resource, Error>
    var presenter: LoadResourcePresenter<Resource, View>?
    private var isLoading = false
    private var cancellable: Cancellable?

    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }

    func didRequestResource() {
        presenter?.didStartLoading()
        guard !isLoading else { return }
        isLoading = true
        cancellable = loader()
            .dispatchOnMainQueue()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)
                }
                self?.isLoading = false
            } receiveValue: { [weak self] resource in
                self?.presenter?.didFinishLoading(with: resource)
            }
    }

    func didCancelRequest() {
        cancellable?.cancel()
        isLoading = false
    }
}
