//
//  WatchConnection.swift
//
//  Created by Taikhoom Attar on 2/22/23.
//  Copyright © 2023 Mac-OS-SSD. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchConnection : NSObject, WCSessionDelegate{
    static var shared:WatchConnection = WatchConnection()
    var session: WCSession
    override init() {
        
        session = WCSession.default
        
        super .init()
        
        session.delegate = self
        session.activate()
        
        
        
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activated with state \(activationState) and error \(String(describing: error))")
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
#endif
    
    func sendAppContext(dataDictIn: [String:Any]) {
        
        try? WCSession.default.updateApplicationContext(dataDictIn)
    }
    
     func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Message received: \(message)")
        
        //        try! WCSession.default.updateApplicationContext(["MixerProfilesJson":UserDefaults.standard.object(forKey: "MixerProfilesJson") ?? ""])
        let data = ["MixerProfilesJson":UserDefaults.standard.object(forKey: "MixerProfilesJson") ?? ""]
        replyHandler(data)
    }
        
    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ){
        print("Application context received: \(applicationContext.keys)")
        
        //Assume that anything sent this way is to end up in the recipient's user defaults
        for (key, val) in applicationContext{
            UserDefaults.standard.set(val, forKey: key)
        }
        
        MixerManager.shared.reinit()
    }
        
        
    func sendRequestForContext(){
        WCSession.default.sendMessage(["contextReq":""], replyHandler: { (replyDict) -> Void in
            for (key, val) in replyDict{
                UserDefaults.standard.set(val, forKey: key)
            }
            MixerManager.shared.reinit()
        }, errorHandler: { (error) -> Void in
            print(error)
        })
    }
    
}
