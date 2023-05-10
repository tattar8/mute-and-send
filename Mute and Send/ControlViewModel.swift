//
//  ControlViewModel.swift
//  Mute and Send
//
//  Created by Taikhoom Attar on 4/28/23.
//

import Foundation
import SwiftUI

struct Control: Identifiable{
    let id = UUID()
    var isChannel: Bool
    var num: Int
    var faderLevel: Double
    var muted: Bool
    var buses: [Control]?
    var parentNum: Int?
    var color: Color
    var colorInv: Bool = false
}

class ControlViewModel: ObservableObject{
    @Published var enabledChannels: [Control]
    @Published var channelNames: [String]
    @Published var busNames: [String]
    @Published var busMasters: [Control]
    @Published var mixerName: String = "Mixer"
    @Published var connectionGood: Bool = false
    @Published var connectionError: Error? = nil
    var mixerType: SupportedMixers.MixerType
    private var timerFlag: Bool = false
    
    var comms: X32OSCComms
    
    private let ScribbleColors: [Color] = [
        .black,
        .red,
        .green,
        .yellow,
        .blue,
        .pink,
        .cyan,
        .white
    ]
    
    init(addressIn: String, portIn: String, mixerType:SupportedMixers.MixerType) {
        self.mixerType = mixerType
        
        self.enabledChannels = [
            Control(isChannel: true, num: 1, faderLevel: 50,muted:false, buses: (1...6).map { Control(isChannel: false, num: $0, faderLevel: 0, muted: false, parentNum: 1, color: .black) }, color: .black ),
            Control(isChannel: true, num: 2, faderLevel: 50,muted:false, buses: (1...6).map { Control(isChannel: false, num: $0, faderLevel: 0, muted: false, parentNum: 2, color: .black) }, color: .black ),
            Control(isChannel: true, num: 3, faderLevel: 50,muted:false, buses: (1...6).map { Control(isChannel: false, num: $0, faderLevel: 0, muted: false, parentNum: 3, color: .black) }, color: .black ),
            Control(isChannel: true, num: 4, faderLevel: 50,muted:false, buses: (1...6).map { Control(isChannel: false, num: $0, faderLevel: 0, muted: false, parentNum: 4, color: .black) }, color: .black ),
            Control(isChannel: true, num: 5, faderLevel: 50,muted:false, buses: (1...6).map { Control(isChannel: false, num: $0, faderLevel: 0, muted: false, parentNum: 5, color: .black) }, color: .black )
        ]
        
        self.channelNames = [
            "Channel 1",
            "Channel 2",
            "Channel 3",
            "Channel 4",
            "Channel 5"
        ]
        
        self.busMasters = [
            Control(isChannel: false, num: 1, faderLevel: 50, muted: false, color: .black),
            Control(isChannel: false, num: 2, faderLevel: 50, muted: false, color: .black),
            Control(isChannel: false, num: 3, faderLevel: 50, muted: false, color: .black),
            Control(isChannel: false, num: 4, faderLevel: 50, muted: false, color: .black),
            Control(isChannel: false, num: 5, faderLevel: 50, muted: false, color: .black),
            Control(isChannel: false, num: 6, faderLevel: 50, muted: false, color: .black)
        ]
        
        self.busNames = [
            "Bus 1",
            "Bus 2",
            "Bus 3",
            "Bus 4",
            "Bus 5",
            "Bus 6"
        ]
        self.mixerName = "Mixer"
        
        self.comms = X32OSCComms(rcvdCommandHandler: {_ in }, host: addressIn, port: portIn)
        self.comms.rcvdCommandHandler = handleUpdate
        self.comms.errorCmdHandler = handleError
        comms.connect()
        getInitialData()
        comms.getInfo()
        
        Timer.scheduledTimer(withTimeInterval: 11.0, repeats: true) { timer in
            print("CVM Timer fired")
            
            if (self.timerFlag == false){
                //has not been set by handleUpdate
                self.connectionGood = false
            }
            self.timerFlag = false
        }
        
        
        //self.enabledChannels[0].faderLevel = 1
        print(self.enabledChannels[0].faderLevel)
    }
    
    func getInitialData(){
        
//        var cmd = X32OSCComms.ControlCommand(type: .info, busNum: -1, chNum: -1, name: "", value: 0.0)
//        var requestData = comms.prepRequestData(cmdIn: cmd)
//        comms.send(requestData)
        
        for channel in 1...SupportedMixers.MixerInfo[mixerType.rawValue].nChannels{
            var cmd = X32OSCComms.ControlCommand(type: .name, busNum: -1, chNum: channel, name: "", value: 0.0)
            var requestData = comms.prepRequestData(cmdIn: cmd)
            comms.send(requestData)
            
            cmd.type = .mute
            requestData = comms.prepRequestData(cmdIn: cmd)
            comms.send(requestData)
            
            cmd.type = .fader
            requestData = comms.prepRequestData(cmdIn: cmd)
            comms.send(requestData)
            
            cmd.type = .color
            requestData = comms.prepRequestData(cmdIn: cmd)
            comms.send(requestData)
            
            for bus in 1...SupportedMixers.MixerInfo[mixerType.rawValue].nBuses{
                cmd.chNum = channel
                cmd.type = .fader
                cmd.busNum = bus
                requestData = comms.prepRequestData(cmdIn: cmd)
                comms.send(requestData)
                
                cmd.type = .mute
                requestData = comms.prepRequestData(cmdIn: cmd)
                comms.send(requestData)
                
                if (channel == 1){
                    //to avoid another loop later
                    cmd.type = .name
                    cmd.chNum = -1
                    requestData = comms.prepRequestData(cmdIn: cmd)
                    comms.send(requestData)
                    
                    cmd.type = .mute
                    requestData = comms.prepRequestData(cmdIn: cmd)
                    comms.send(requestData)
                    
                    cmd.type = .fader
                    requestData = comms.prepRequestData(cmdIn: cmd)
                    comms.send(requestData)
                    
                    cmd.type = .color
                    requestData = comms.prepRequestData(cmdIn: cmd)
                    comms.send(requestData)
                }
            }
        }
    }
    
    func ensureValidity(chNum: Int, busNum: Int){
        if (chNum > self.enabledChannels.count){
            for newChan in self.enabledChannels.count+1...chNum{
                self.enabledChannels.append(
                    Control(isChannel: true, num: newChan, faderLevel: 50,muted:false, buses: (1...6).map { Control(isChannel: false, num: $0, faderLevel: 0, muted: false, parentNum: 1, color: .black) }, color: .black )
                )
            }
        }
        if (chNum > self.channelNames.count){
            for newChan in self.channelNames.count+1...chNum{
                self.channelNames.append("Channel \(newChan)")
            }
        }
        
        //guard busNum != -1 else {return}
        if (busNum > self.busNames.count){
            for newBus in self.busNames.count+1...busNum{
                self.busNames.append("Bus \(newBus)")
            }
        }
        
        if (busNum > self.busMasters.count){
            for newBus in self.busMasters.count+1...busNum{
                self.busMasters.append(Control(isChannel: false, num: newBus, faderLevel: 50, muted: false, color: .black))
            }
        }
        
        guard chNum != -1 else {return}
        if (busNum > self.enabledChannels[chNum - 1].buses!.count){
            for newBus in self.enabledChannels[chNum - 1].buses!.count+1...busNum{
                self.enabledChannels[chNum - 1].buses!.append(Control(isChannel: false, num: newBus, faderLevel: 0, muted: false, parentNum: 1, color: .black))
            }
        }
        
    }
    
    func handleUpdate(commandIn: X32OSCComms.ControlCommand){
        DispatchQueue.main.async { [self] in
            self.timerFlag = true
            self.ensureValidity(chNum: commandIn.chNum, busNum: commandIn.busNum)
            switch (commandIn.type){
            case .name:
                do {
                    guard (commandIn.name.replacingOccurrences(of: "\0", with: "") != "") else {break}
                    if (commandIn.busNum == -1){
                        //channel name
                        self.channelNames[commandIn.chNum - 1] = commandIn.name
                    }
                    else{
                        self.busNames[commandIn.busNum - 1] = commandIn.name
                    }
                }
            case .fader:
                do{
                    if (commandIn.busNum == -1){
                        //channel fader
                        self.enabledChannels[commandIn.chNum - 1].faderLevel = Double(commandIn.value) * 100
                    }
                    else{
                        if (commandIn.chNum == -1){
                            //bus master
                            self.busMasters[commandIn.busNum - 1].faderLevel = Double(commandIn.value) * 100
                        }
                        else{
                            self.enabledChannels[commandIn.chNum - 1].buses![commandIn.busNum - 1].faderLevel = Double(commandIn.value) * 100
                        }
                    }
                }
            case .mute:
                if (commandIn.busNum == -1){
                    //channel mute
                    self.enabledChannels[commandIn.chNum - 1].muted = commandIn.value == 0.0
                }
                else{
                    if (commandIn.chNum == -1){
                        //bus master
                        self.busMasters[commandIn.busNum - 1].muted = commandIn.value == 0.0
                    }
                    else{
                        self.enabledChannels[commandIn.chNum - 1].buses![commandIn.busNum - 1].muted = commandIn.value == 0.0
                    }
                }
            case .color:
                var cmdColorVal = Int(commandIn.value)
                let cmdColorInv = cmdColorVal >= 8
                cmdColorVal %= 8
                if (commandIn.busNum == -1){
                    //channel name
                    self.enabledChannels[commandIn.chNum - 1].color = ScribbleColors[cmdColorVal]
                    self.enabledChannels[commandIn.chNum - 1].colorInv = cmdColorInv
                    
                }
                else{
                    self.busMasters[commandIn.busNum - 1].color = ScribbleColors[cmdColorVal]
                    self.busMasters[commandIn.busNum - 1].colorInv = cmdColorInv
                    print("Set bus to color \(self.busMasters[commandIn.busNum - 1].color)")
                }
            case .info:
                connectionGood = true
                //getInitialData()
            }
        }
    }
    
    func handleError(errorIn: Error){
        connectionGood = false
        connectionError = errorIn
    }
    
    func updateFader(channel: Int, bus: Int, value: Double){
        print(value)
        if (bus == -1){
            self.enabledChannels[channel-1].faderLevel = (value)
        }
        else{
            if (channel == -1){
                self.busMasters[bus-1].faderLevel = value
            }
            else{
                self.enabledChannels[channel-1].buses![bus-1].faderLevel = value
            }
        }
        
        let cmd = X32OSCComms.ControlCommand(type: .fader, busNum: bus, chNum: channel, name: "", value: Float(value/100.0))
        
        let cmdData = comms.prepOutputData(cmdIn: cmd)!
        comms.send(cmdData)
        
    }
    
    func updateMute(channel: Int, bus: Int, value: Bool){
        print(value)
        if (bus == -1){
            self.enabledChannels[channel-1].muted = (value)
        }
        else{
            if (channel == -1){
                self.busMasters[bus-1].muted = (value)
            }
            else{
                self.enabledChannels[channel-1].buses![bus-1].muted = value
            }
        }
        
        let cmd = X32OSCComms.ControlCommand(type: .mute, busNum: bus, chNum: channel, name: "", value: value ? 1.0 : 0.0)
        
        let cmdData = comms.prepOutputData(cmdIn: cmd)!
        comms.send(cmdData)
        
    }
    
    func tryToConnect(){
//        comms.stopConnection()
//        comms.startConnection()
        print("Trying to reconnect")
        getInitialData()
        comms.getInfo()
    }
}
