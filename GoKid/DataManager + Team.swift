//
//  DataManager + Team.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/17/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//


extension DataManager {
    
    func addTeamMember(comp: completion) {
        var url = baseURL + "/api/sessions"
        var map = [
            "" : ""
        ]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("addTeamMember success")
            comp(true, "")
            }) { (op, error) in
                println("addTeamMember failed")
                var errorStr = self.constructErrorStr(op, error: error)
                println(errorStr)
                comp(false, errorStr)
        }
    }
    
    func deleteTeamMember(comp: completion) {
        var url = baseURL + "/api/sessions"
        var map = [
            "" : ""
        ]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("addTeamMember success")
            comp(true, "")
            }) { (op, error) in
                println("addTeamMember failed")
                var errorStr = self.constructErrorStr(op, error: error)
                println(errorStr)
                comp(false, errorStr)
        }
    }
    
    func updateTeamMember(comp: completion) {
        var url = baseURL + "/api/sessions"
        var map = [
            "" : ""
        ]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("addTeamMember success")
            comp(true, "")
            }) { (op, error) in
                println("addTeamMember failed")
                var errorStr = self.constructErrorStr(op, error: error)
                println(errorStr)
                comp(false, errorStr)
        }
    }
}