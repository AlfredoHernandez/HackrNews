//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?

    public static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: nil)
    }

    public static func error(message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}

public protocol ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel)
}

public struct ResourceLoadingViewModel {
    public let isLoading: Bool

    public init(isLoading: Bool) {
        self.isLoading = isLoading
    }
}

public protocol ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    private var resourceView: View
    private var loadingView: ResourceLoadingView?
    private var errorView: ResourceErrorView?
    private var mapper: Mapper

    public init(resourceView: View, loadingView: ResourceLoadingView?, errorView: ResourceErrorView?, mapper: @escaping Mapper) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }

    public static var loadError: String {
        NSLocalizedString(
            "generic_connection_error",
            tableName: "Shared",
            bundle: Bundle(for: Self.self),
            comment: "Error message displayed when we can't load the resource."
        )
    }

    public func didStartLoading() {
        errorView?.display(.noError)
        loadingView?.display(ResourceLoadingViewModel(isLoading: true))
    }

    public func didFinishLoading(with resource: Resource) {
        do {
            resourceView.display(try mapper(resource))
            loadingView?.display(ResourceLoadingViewModel(isLoading: false))
        } catch {
            didFinishLoading(with: error)
        }
    }

    public func didFinishLoading(with _: Error) {
        errorView?.display(.error(message: Self.loadError))
        loadingView?.display(ResourceLoadingViewModel(isLoading: false))
    }
}
