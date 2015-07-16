
//
//  TimeAndDateVC + Carpool.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/28/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

/* DEPRECATED
extension TimeAndDateVC {

    // MARK: NetWork Carpool Creation
    // --------------------------------------------------------------------------------------------
    
    func startCarpoolCreation() {
        LoadingView.showWithMaskType(.Black)
        dataManager.createCarpool(userManager.currentCarpoolModel, comp: handleCreateCarpool)
    }
    
    func handleCreateCarpool(success: Bool, errorStr: String) {
        LoadingView.dismiss()
        if success {
            moveToVolunteerVC()
        } else {
            self.showAlert("Fail to create carpool", messege: errorStr, cancleTitle: "OK")
        }
    }
    
    func moveToVolunteerVC() {
        onMainThread() {
            var vc = vcWithID("LocationVC")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
*/
