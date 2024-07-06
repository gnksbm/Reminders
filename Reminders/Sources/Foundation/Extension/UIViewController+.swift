//
//  UIViewController+.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import UIKit

import Neat

extension UIViewController {
    func showActionSheet(
        title: String? = nil,
        view: UIView,
        action: UIAlertAction,
        hasCancelAction: Bool = true
    ) {
        let alertVC = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .actionSheet
        )
        alertVC.addAction(action)
        if hasCancelAction {
            alertVC.addAction(
                UIAlertAction(title: "취소", style: .cancel)
            )
        }
        let contentViewController = UIViewController()
        contentViewController.view = view
        alertVC.setValue(contentViewController, forKey: "contentViewController")
        present(alertVC, animated: true)
    }
}

// MARK: OverlayView
extension UIViewController {
    private enum OverlayHelper {
        static var isToastShowing = false
        static var activityView: UIActivityIndicatorView?
        static var progressView: UIProgressView?
    }
    
    func showToast(message: String, duration: Double = 2) {
        guard !OverlayHelper.isToastShowing else { return }
        OverlayHelper.isToastShowing = true
        
        let toastView = ToastView().nt.configure { 
            $0.perform { $0.updateMessage(message) }
        }
        
        view.addSubview(toastView)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        
        let toastTopConstraint =
        toastView.bottomAnchor.constraint(equalTo: safeArea.topAnchor)
        
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            toastTopConstraint
        ])
        view.layoutIfNeeded()
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                toastTopConstraint.constant = toastView.bounds.height + 10
                toastView.alpha = 1
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.3,
                    delay: duration,
                    options: [.curveEaseIn],
                    animations: {
                        toastTopConstraint.constant = 0
                        toastView.alpha = 0
                        self.view.layoutIfNeeded()
                    },
                    completion: { _ in
                        toastView.removeFromSuperview()
                        OverlayHelper.isToastShowing = false
                    }
                )
            }
        )
    }
    
    func showActivityIndicator() {
        guard OverlayHelper.activityView == nil else { return }
        let activityView = UIActivityIndicatorView().nt.configure {
            $0.color(.tintColor)
                .translatesAutoresizingMaskIntoConstraints(false)
                .startAnimating()
        }
        OverlayHelper.activityView = activityView
        view.addSubview(activityView)
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            activityView.centerXAnchor.constraint(
                equalTo: safeArea.centerXAnchor
            ),
            activityView.centerYAnchor.constraint(
                equalTo: safeArea.centerYAnchor
            ),
        ])
        view.layoutIfNeeded()
    }
    
    func hideActivityIndicator() {
        OverlayHelper.activityView?.removeFromSuperview()
    }
    
    func showProgressView() {
        guard OverlayHelper.progressView == nil else { return }
        let progressView = UIProgressView().nt.configure { 
            $0.trackTintColor(.separator)
                .progressTintColor(.red)
        }
        
        OverlayHelper.progressView = progressView
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            progressView.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor
            ),
            progressView.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor
            ),
            progressView.heightAnchor.constraint(
                equalToConstant: 5
            ),
        ])
        
        view.layoutIfNeeded()
    }
    
    func updateProgress(progress: Double) {
        OverlayHelper.progressView?.progress = Float(progress)
        view.layoutIfNeeded()
    }
    
    func appendProgress(progress: Double) {
        OverlayHelper.progressView?.progress =
        (OverlayHelper.progressView?.progress ?? 0) + Float(progress)
        view.layoutIfNeeded()
    }
    
    func hideProgressView() {
        UIView.animate(
            withDuration: 1,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                OverlayHelper.progressView?.progress = 1
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                OverlayHelper.progressView?.removeFromSuperview()
                OverlayHelper.progressView = nil
            }
        )
    }
}
