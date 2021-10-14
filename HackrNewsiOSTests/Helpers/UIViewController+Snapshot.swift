//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

extension UIView {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        let viewController = UIViewController()
        viewController.view.addSubview(self)

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            topAnchor.constraint(equalTo: viewController.view.topAnchor),
            bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
        ])

        return SnapshotWindow(configuration: configuration, root: viewController).snapshot()
    }
}

struct DeviceSize {
    var size: CGSize
    static let iPhone12Mini = DeviceSize(size: CGSize(width: 375, height: 812))
    static let iPhone13Pro = DeviceSize(size: CGSize(width: 390, height: 844))
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection

    static func device(
        _ device: DeviceSize = .iPhone13Pro,
        style: UIUserInterfaceStyle,
        preferredContentSizeCategory: UIContentSizeCategory = .large
    ) -> SnapshotConfiguration {
        SnapshotConfiguration(
            size: device.size,
            safeAreaInsets: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
            layoutMargins: UIEdgeInsets(top: 55, left: 8, bottom: 42, right: 8),
            traitCollection: UITraitCollection(traitsFrom: [
                .init(forceTouchCapability: .unavailable),
                .init(layoutDirection: .leftToRight),
                .init(preferredContentSizeCategory: preferredContentSizeCategory),
                .init(userInterfaceIdiom: .phone),
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
                .init(displayScale: 3),
                .init(accessibilityContrast: .normal),
                .init(displayGamut: .P3),
                .init(userInterfaceStyle: style),
            ])
        )
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .device(style: .light)

    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        layoutMargins = configuration.layoutMargins
        rootViewController = root
        isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }

    override var safeAreaInsets: UIEdgeInsets {
        configuration.safeAreaInsets
    }

    override var traitCollection: UITraitCollection {
        UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
    }

    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}
