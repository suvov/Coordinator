//
//  Router.swift
//  Coordinator
//
//  Created by Vladimir Shutyuk on 16/05/2020.
//  Copyright © 2020 Vladimir Shutyuk. All rights reserved.
//

import UIKit

final class Router: NSObject {

    private let rootController: UINavigationController
    private var onPopBlocks: [UIViewController : () -> Void]

    init(rootController: UINavigationController) {
        self.rootController = rootController
        self.onPopBlocks = [:]
        super.init()
        self.rootController.delegate = self
    }

    func present(_ controller: UIViewController, animated: Bool = true) {
        rootController.present(controller, animated: animated, completion: nil)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        rootController.dismiss(animated: animated, completion: completion)
    }

    func push(_ controller: UIViewController, animated: Bool = true,
              hideBottomBar: Bool = false, onPopBlock: (() -> Void)? = nil) {
        if let onPopBlock = onPopBlock {
            onPopBlocks[controller] = onPopBlock
        }
        controller.hidesBottomBarWhenPushed = hideBottomBar
        rootController.pushViewController(controller, animated: animated)
    }

    func pop(animated: Bool = true) {
        if let controller = rootController.popViewController(animated: animated) {
            runOnPopBlock(for: controller)
        }
    }

    func setRootViewController(_ controller: UIViewController, hideBar: Bool = false) {
        rootController.setViewControllers([controller], animated: false)
        rootController.isNavigationBarHidden = hideBar
    }

    func popToRootViewController(animated: Bool = true) {
        if let controllers = rootController.popToRootViewController(animated: animated) {
            controllers.forEach { controller in
                runOnPopBlock(for: controller)
            }
        }
    }

    // MARK: -

    private func runOnPopBlock(for controller: UIViewController) {
        guard let onPopBlock = onPopBlocks[controller] else { return }
        onPopBlock()
        onPopBlocks[controller] = nil
    }
}

extension Router: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        guard let popped = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
        guard !navigationController.viewControllers.contains(popped) else { return }
        runOnPopBlock(for: popped)
    }
}

