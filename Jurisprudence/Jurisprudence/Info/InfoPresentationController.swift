//
//  InfoPresentationController.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 24.09.24.
//

import UIKit

class InfoPresentationController: UIPresentationController {
    var dimmingView: UIView!

      override var frameOfPresentedViewInContainerView: CGRect {
          guard let containerView = containerView else { return .zero }
          return CGRect(x: 0, y: 0, width: containerView.bounds.width / 2, height: containerView.bounds.height)
      }
      
      override func presentationTransitionWillBegin() {
          guard let containerView = containerView, let presentedView = presentedView else { return }
          
          // Setup a dimming view if needed
          dimmingView = UIView(frame: containerView.bounds)
//          dimmingView.backgroundColor = #colorLiteral(red: 0.5529411765, green: 0.5333333333, blue: 0.5333333333, alpha: 1).withAlphaComponent(0.5)
          dimmingView.alpha = 0.0
          containerView.addSubview(dimmingView)
          
          containerView.addSubview(presentedView)
          presentedView.frame = frameOfPresentedViewInContainerView.offsetBy(dx: -containerView.bounds.width, dy: 0) // Start off-screen to the left
          presentedView.alpha = 1.0
          
          if let coordinator = presentingViewController.transitionCoordinator {
              coordinator.animate(alongsideTransition: { _ in
                  self.dimmingView.alpha = 1.0
                  presentedView.frame = self.frameOfPresentedViewInContainerView // Slide in
              }, completion: nil)
          } else {
              dimmingView.alpha = 1.0
              presentedView.frame = frameOfPresentedViewInContainerView // Slide in
          }
      }
      
      override func dismissalTransitionWillBegin() {
          if let coordinator = presentingViewController.transitionCoordinator {
              coordinator.animate(alongsideTransition: { _ in
                  self.dimmingView.alpha = 0.0
                  self.presentedView?.frame = self.frameOfPresentedViewInContainerView.offsetBy(dx: -self.containerView!.bounds.width, dy: 0) // Slide out
              }, completion: nil)
          } else {
              dimmingView.alpha = 0.0
              presentedView?.frame = frameOfPresentedViewInContainerView.offsetBy(dx: -containerView!.bounds.width, dy: 0) // Slide out
          }
      }
      
      override func dismissalTransitionDidEnd(_ completed: Bool) {
          if completed {
              dimmingView.removeFromSuperview()
          }
      }
      
      override func presentationTransitionDidEnd(_ completed: Bool) {
          if !completed {
              dimmingView.removeFromSuperview()
          }
      }
    
}

class InfoTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return InfoPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

//class InfoAnimator: NSObject, UIViewControllerAnimatedTransitioning {
//    let isPresenting: Bool
//
//    init(isPresenting: Bool) {
//        self.isPresenting = isPresenting
//    }
//
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 0.3
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        guard let fromView = transitionContext.view(forKey: .from),
//              let toView = transitionContext.view(forKey: .to) else {
//            return
//        }
//
//        let containerView = transitionContext.containerView
//        let duration = transitionDuration(using: transitionContext)
//
//        if isPresenting {
//            containerView.addSubview(toView)
//            toView.frame = CGRect(x: -toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
//            UIView.animate(withDuration: duration, animations: {
//                toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
//            }, completion: { finished in
//                transitionContext.completeTransition(finished)
//            })
//        } else {
//            UIView.animate(withDuration: duration, animations: {
//                fromView.frame = CGRect(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
//            }, completion: { finished in
//                fromView.removeFromSuperview()
//                transitionContext.completeTransition(finished)
//            })
//        }
//    }
//}
