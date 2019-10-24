//
//  Animator.swift
//  CustomTransitionDemo
//
//  Created by Tung on 13.10.19.
//  Copyright © 2019 Tung. All rights reserved.
//

import UIKit

final class Animator: NSObject, UIViewControllerAnimatedTransitioning {

    static let duration: TimeInterval = 1.2

    private let type: PresentationType
    private let firstViewController: FirstViewController
    private let secondViewController: SecondViewController
    private let selectedCellImageViewSnapshot: UIView
    private let cellImageViewRect: CGRect
    private let cellLabelRect: CGRect

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
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Animator.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let toView = secondViewController.view
            else {
                transitionContext.completeTransition(false)
                return
        }

        containerView.addSubview(toView)

        guard let selectedCell = firstViewController.selectedCell,
            let cellLabelSnapshot = selectedCell.locationLabel.snapshotView(afterScreenUpdates: true),
            let controllerImageViewSnapshot = secondViewController.locationImageView.snapshotView(afterScreenUpdates: true),
            let closeButtonSnapshot = secondViewController.closeButton.snapshotView(afterScreenUpdates: true),
            let window = firstViewController.view.window ?? secondViewController.view.window
            else {
                transitionContext.completeTransition(true)
                return
        }

        toView.alpha = 0

        let isPresenting = type.isPresenting

        let backgroundView: UIView
        let whiteView = UIView(frame: containerView.bounds)
        whiteView.backgroundColor = .white

        if isPresenting {
            backgroundView = UIView(frame: containerView.bounds)
            backgroundView.addSubview(whiteView)
            whiteView.alpha = 0
        } else {
            backgroundView = firstViewController.view.snapshotView(afterScreenUpdates: true) ?? whiteView
            backgroundView.addSubview(whiteView)
        }

        [backgroundView, selectedCellImageViewSnapshot, controllerImageViewSnapshot, cellLabelSnapshot, closeButtonSnapshot].forEach { containerView.addSubview($0) }

        let controllerImageViewRect = secondViewController.locationImageView.convert(secondViewController.locationImageView.bounds, to: window)
        let controllerLabelRect = secondViewController.locationLabel.convert(secondViewController.locationLabel.bounds, to: window)
        let closeButtonRect = secondViewController.closeButton.convert(secondViewController.closeButton.bounds, to: window)

        [controllerImageViewSnapshot, selectedCellImageViewSnapshot].forEach {
            $0.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
            $0.layer.cornerRadius = isPresenting ? 12 : 0
            $0.layer.masksToBounds = true
        }

        controllerImageViewSnapshot.alpha = isPresenting ? 0 : 1
        selectedCellImageViewSnapshot.alpha = isPresenting ? 1 : 0

        cellLabelSnapshot.frame = isPresenting ? cellLabelRect : controllerLabelRect

        closeButtonSnapshot.frame = closeButtonRect
        closeButtonSnapshot.alpha = isPresenting ? 0 : 1

        UIView.animateKeyframes(withDuration: Self.duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                self.selectedCellImageViewSnapshot.alpha = isPresenting ? 0 : 1
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                controllerImageViewSnapshot.alpha = isPresenting ? 1 : 0
            }

            UIView.addKeyframe(withRelativeStartTime: isPresenting ? 0.7 : 0, relativeDuration: 0.3) {
                closeButtonSnapshot.alpha = isPresenting ? 1 : 0
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.selectedCellImageViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                controllerImageViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                cellLabelSnapshot.frame = isPresenting ? controllerLabelRect : self.cellLabelRect
                whiteView.alpha = isPresenting ? 1 : 0

                [controllerImageViewSnapshot, self.selectedCellImageViewSnapshot].forEach {
                    $0.layer.cornerRadius = isPresenting ? 0 : 12
                }
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

enum PresentationType {

    case present
    case dismiss

    var isPresenting: Bool {
        return self == .present
    }
}
