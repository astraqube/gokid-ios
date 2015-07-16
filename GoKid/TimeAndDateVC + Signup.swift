
//
//  TimeAndDateVC + Signup.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/28/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

/* DEPRECATED
extension TimeAndDateVC {
    
    // MARK: Signin Signup
    // --------------------------------------------------------------------------------------------
    
    func animatShowSignupVC() {
        signupVC = vcWithID("SignUpVC") as! SignUpVC
        signupVC.view.alpha = 0.0
    
        // view controller operations
        navigationController?.view.addSubview(signupVC.view)
        signupVC.signinButtonHandler = signupToSignin

        // animation
        signupVC.view.alphaAnimation(1.0, duration: 0.5, completion: nil)
    }
    
    func signupToSignin() {
        signupVC.view.alphaAnimation(0.0, duration: 0.4) { (anim, finished) in
            self.signupVC.view.removeFromSuperview()
            withDelay(0.2) {
                var vc = vcWithID("SignInVC") as! SignInVC
                // vc.signinSuccessHandler = self.signinSuccessHandler
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func signinSuccessHandler() {
        navigationController?.popViewControllerAnimated(true)
    }
}
*/
