//
//  Animator.swift
//  CustomTransitionDemo
//
//  Created by Tung on 13.10.19.
//  Copyright © 2019 Tung. All rights reserved.
//

import UIKit

enum PresentationType {

    case present
    case dismiss

    var isPresenting: Bool {
        return self == .present
    }
}

final class Animator: NSObject, UIViewControllerAnimatedTransitioning {

    static let duration: TimeInterval = 1.2

    private let type: PresentationType
    private let firstViewController: FirstViewController
    private let secondViewController: SecondViewController
    private let selectedCellImageViewSnapshot: UIView
    private let cellImageViewRect: CGRect
    private let cellLabelRect: CGRect
    private let controllerImageViewRect: CGRect
    private let controllerLabelRect: CGRect
    private let closeButtonRect: CGRect

    init?(type: PresentationType, firstViewController: FirstViewController, secondViewController: SecondViewController, selectedCellImageViewSnapshot: UIView) {
        self.type = type
        self.firstViewController = firstViewController
        self.secondViewController = secondViewController
        self.selectedCellImageViewSnapshot = selectedCellImageViewSnapshot

        guard let window = firstViewController.view.window ?? secondViewController.view.window,
            let selectedCell = firstViewController.selectedCell
            else { return nil }

        self.cellImageViewRect = selectedCell.locationImageView.convert(selectedCell.locationImageView.bounds, to: window)
        self.cellLabelRect = selectedCell.locationLabel.convert(selectedCell.locationLabel.bounds, to: window)

        self.controllerImageViewRect = secondViewController.locationImageView.convert(secondViewController.locationImageView.bounds, to: window)
        self.controllerLabelRect = secondViewController.locationLabel.convert(secondViewController.locationLabel.bounds, to: window)

        self.closeButtonRect = secondViewController.closeButton.convert(secondViewController.closeButton.bounds, to: window)
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Animator.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let toView = secondViewController.view,
            let selectedCell = firstViewController.selectedCell
        else {
            transitionContext.completeTransition(true)
            return
        }

        containerView.addSubview(toView)
        toView.alpha = 0

        #warning("seems transitionContext.completeTransition(true) is not working just to fall through if something is nil")

        guard let cellLabelSnapshot = selectedCell.locationLabel.snapshotView(afterScreenUpdates: true),
            let controllerImageViewSnapshot = secondViewController.locationImageView.snapshotView(afterScreenUpdates: true),
            let closeButtonSnapshot = secondViewController.closeButton.snapshotView(afterScreenUpdates: true)
        else {
                transitionContext.completeTransition(true)
                return
        }

        controllerImageViewSnapshot.frame = type.isPresenting ? cellImageViewRect : controllerImageViewRect

        selectedCellImageViewSnapshot.frame = type.isPresenting ? cellImageViewRect : controllerImageViewRect

        cellLabelSnapshot.frame = type.isPresenting ? cellLabelRect : controllerLabelRect

        let backgroundView: UIView
        let whiteView: UIView

        if type.isPresenting {
            whiteView = UIView(frame: containerView.bounds)
            whiteView.backgroundColor = .white
            backgroundView = UIView(frame: containerView.bounds)
            backgroundView.addSubview(whiteView)
            whiteView.alpha = 0
        } else {
            whiteView = UIView(frame: containerView.bounds)
            whiteView.backgroundColor = .white
            backgroundView = firstViewController.view.snapshotView(afterScreenUpdates: true) ?? whiteView
            backgroundView.addSubview(whiteView)
        }

        closeButtonSnapshot.frame = closeButtonRect
        closeButtonSnapshot.alpha = type.isPresenting ? 0 : 1

        [backgroundView, selectedCellImageViewSnapshot, controllerImageViewSnapshot, cellLabelSnapshot, closeButtonSnapshot].forEach { containerView.addSubview($0) }

        controllerImageViewSnapshot.alpha = type.isPresenting ? 0 : 1
        selectedCellImageViewSnapshot.alpha = type.isPresenting ? 1 : 0
        controllerImageViewSnapshot.alpha = type.isPresenting ? 0 : 1

        UIView.animateKeyframes(withDuration: Self.duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                self.selectedCellImageViewSnapshot.alpha = self.type.isPresenting ? 0 : 1
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                controllerImageViewSnapshot.alpha = self.type.isPresenting ? 1 : 0
            }

            UIView.addKeyframe(withRelativeStartTime: self.type.isPresenting ? 0.7 : 0, relativeDuration: 0.3) {
                closeButtonSnapshot.alpha = self.type.isPresenting ? 1 : 0
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.selectedCellImageViewSnapshot.frame = self.type.isPresenting ? self.controllerImageViewRect : self.cellImageViewRect
                controllerImageViewSnapshot.frame = self.type.isPresenting ? self.controllerImageViewRect : self.cellImageViewRect
                cellLabelSnapshot.frame = self.type.isPresenting ? self.controllerLabelRect : self.cellLabelRect
                whiteView.alpha = self.type.isPresenting ? 1 : 0
            }
        }) { _ in
            self.selectedCellImageViewSnapshot.removeFromSuperview()
            controllerImageViewSnapshot.removeFromSuperview()
            cellLabelSnapshot.removeFromSuperview()
            closeButtonSnapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()

            toView.alpha = 1
            transitionContext.completeTransition(true)
        }
    }
}
