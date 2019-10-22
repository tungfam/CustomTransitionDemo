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

    private let cellImageBackupCopy: UIView

    init(type: PresentationType, firstViewController: FirstViewController, secondViewController: SecondViewController, selectedCellImageViewSnapshot: UIView) {
        self.type = type
        self.firstViewController = firstViewController
        self.secondViewController = secondViewController
        self.cellImageBackupCopy = selectedCellImageViewSnapshot
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Animator.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let toView = secondViewController.view
        else {
            transitionContext.completeTransition(true)
            return
        }

        containerView.addSubview(toView)
        toView.alpha = 0

        guard let selectedCell = firstViewController.selectedCell else { return }

        guard let window = firstViewController.view.window ?? secondViewController.view.window else { assertionFailure(); return }

        // Imporatant to take rects before snapshoting to avoid issues that frames got changed
        let cellImageViewRect = selectedCell.locationImageView.convert(selectedCell.locationImageView.bounds, to: window)

        let cellLabelRect = selectedCell.locationLabel.convert(selectedCell.locationLabel.bounds, to: window)

        #warning("seems transitionContext.completeTransition(true) is not working just to fall through if something is nil")

        guard let cellImageViewSnapshot = selectedCell.locationImageView.snapshotView(afterScreenUpdates: true),
            let cellLabelSnapshot = selectedCell.locationLabel.snapshotView(afterScreenUpdates: true),
            let controllerImageViewSnapshot = secondViewController.locationImageView.snapshotView(afterScreenUpdates: true),
            let closeButtonSnapshot = secondViewController.closeButton.snapshotView(afterScreenUpdates: true)
        else {
                transitionContext.completeTransition(true)
                return
        }

//        if type.isPresenting {
//            cellImageBackupCopy = cellImageViewSnapshot
//        }

        let finalCellImageViewSnapshot = cellImageBackupCopy

        let controllerImageViewRect = secondViewController.locationImageView.convert(secondViewController.locationImageView.bounds, to: window)
        let controllerLabelRect = secondViewController.locationLabel.convert(secondViewController.locationLabel.bounds, to: window)
        controllerImageViewSnapshot.frame = type.isPresenting ? cellImageViewRect : controllerImageViewRect

        finalCellImageViewSnapshot.frame = type.isPresenting ? cellImageViewRect : controllerImageViewRect

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

        let closeButtonRect = secondViewController.closeButton.convert(secondViewController.closeButton.bounds, to: window)
        closeButtonSnapshot.frame = closeButtonRect
        closeButtonSnapshot.alpha = type.isPresenting ? 0 : 1

        [backgroundView, finalCellImageViewSnapshot, controllerImageViewSnapshot, cellLabelSnapshot, closeButtonSnapshot].forEach { containerView.addSubview($0) }

        controllerImageViewSnapshot.alpha = type.isPresenting ? 0 : 1
        finalCellImageViewSnapshot.alpha = type.isPresenting ? 1 : 0

        controllerImageViewSnapshot.alpha = type.isPresenting ? 0 : 1

        UIView.animateKeyframes(withDuration: Self.duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                if self.type.isPresenting {
                    finalCellImageViewSnapshot.alpha = 0
                } else {
                    finalCellImageViewSnapshot.alpha = 1
                }
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                if self.type.isPresenting {
                    controllerImageViewSnapshot.alpha = 1
                } else {
                    controllerImageViewSnapshot.alpha = 0
                }
            }

            UIView.addKeyframe(withRelativeStartTime: self.type.isPresenting ? 0.7 : 0, relativeDuration: 0.3) {
                closeButtonSnapshot.alpha = self.type.isPresenting ? 1 : 0
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                finalCellImageViewSnapshot.frame = self.type.isPresenting ? controllerImageViewRect : cellImageViewRect
                controllerImageViewSnapshot.frame = self.type.isPresenting ? controllerImageViewRect : cellImageViewRect
                cellLabelSnapshot.frame = self.type.isPresenting ? controllerLabelRect : cellLabelRect
                whiteView.alpha = self.type.isPresenting ? 1 : 0
            }
        }) { _ in
            finalCellImageViewSnapshot.removeFromSuperview()
            controllerImageViewSnapshot.removeFromSuperview()
            cellLabelSnapshot.removeFromSuperview()
            closeButtonSnapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()

            toView.alpha = 1
            transitionContext.completeTransition(true)
        }
    }
}
