//
//  X32OSCComms.swift
//  Mute and Send
//
//  Created by Taikhoom Attar on 4/26/23.
//

import Foundation
import Network

class X32OSCComms{
    var rcvdCommandHandler: ((ControlCommand) -> Void) = {_ in }
    var errorCmdHandler: ((Error) -> Void) = {_ in }
    
    var connection: NWConnection?
        
    var host: NWEndpoint.Host// = "172.16.2.13"
    var port: NWEndpoint.Port// = 10023
    var timer: Timer?
    
    let mainFaderRegex = /\/ch\/..\/mix\/fader/
    let busFaderRegex = /\/ch\/..\/mix\/..\/level/
    let busMasterFaderRegex = /\/bus\/..\/mix\/fader/
    let mainMuteRegex = /\/ch\/..\/mix\/on/
    let busMuteRegex = /\/ch\/..\/mix\/..\/on/
    let chScribbleNameRegex = /\/ch\/..\/config\/name/
    let busScribbleNameRegex = /\/bus\/..\/config\/name/
    let busMasterMuteRegex = /\/bus\/..\/mix\/on/
    let chScribbleColorRegex = /\/ch\/..\/config\/color/
    let busScribbleColorRegex = /\/bus\/..\/config\/color/
    let infoRegex = /\/info/
    

    enum ControlType{
        case fader
        case mute
        case name
        case color
        case info
    }
    
    struct ControlCommand{
        var type: ControlType
        var busNum: Int
        var chNum: Int
        var name: String
        var value: Float
    }
    
    init(rcvdCommandHandler: @escaping (ControlCommand) -> Void, host: String, port: String) {
        self.rcvdCommandHandler = rcvdCommandHandler
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(port)!
    }
    
    func send(_ payload: Data) {
        connection!.send(content: payload, completion: .contentProcessed({ [self] sendError in
            if let error = sendError {
                NSLog("Unable to process and send the data: \(error)")
                errorCmdHandler(error)
            } else {
                NSLog("Data has been sent")
            }
            
        }))
    }
    
    func receiveMessage(connection:NWConnection, repeated:Bool){
        connection.receiveMessage { (data, context, isComplete, error) in
            if let myData = data {
                var command = self.parseInputData(dataIn: data!)
                if let validCommand = command{
                    self.rcvdCommandHandler(validCommand)
                }
            }
            if (repeated) {self.receiveMessage(connection: connection, repeated: true)}
        }
    }
    
    
    func connect(){
        connection = NWConnection(host: host, port: port, using: .udp)
        
        connection!.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .preparing:
                NSLog("Host \(self.host) Entered state: preparing")
            case .ready:
                NSLog("Host \(self.host) Entered state: ready")
            case .setup:
                NSLog("Host \(self.host) Entered state: setup")
            case .cancelled:
                NSLog("Host \(self.host) Entered state: cancelled")
            case .waiting:
                NSLog("Host \(self.host) Entered state: waiting")
            case .failed:
                NSLog("Host \(self.host) Entered state: failed")
            default:
                NSLog("Host \(self.host) Entered an unknown state")
            }
        }
        
        connection!.viabilityUpdateHandler = { (isViable) in
            if (isViable) {
                NSLog("Host \(self.host) Connection is viable")
                let _ = self.register()
                let _ = self.receiveMessage(connection: self.connection!, repeated: true)
            } else {
                NSLog("Host \(self.host) Connection is not viable")
            }
        }
        
        connection!.betterPathUpdateHandler = { (betterPathAvailable) in
            if (betterPathAvailable) {
                NSLog("Host \(self.host) A better path is availble")
            } else {
                NSLog("Host \(self.host) No better path is available")
            }
        }
        
        connection!.start(queue: .global())
    }
    
    func getInfo()->String{
        send(Data("/info".utf8))
        return ""
    }
    func register(){
        send(Data("/xremote".utf8))
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
                print("Timer fired!")
                self.send(Data("/xremote".utf8))
                self.getInfo()
            }
        }
    }
    
    func parseInputData(dataIn: Data) -> ControlCommand?{
        let path = String(decoding: dataIn, as: UTF8.self).components(separatedBy: ",")[0]
        
        if (path.contains(infoRegex)){
            print("Info")
            return ControlCommand(type: .info, busNum: -1, chNum: -1, name: "", value: 0.0)
        }
        if (path.contains(mainFaderRegex)){
            let faderNum: Int = Int(path.components(separatedBy: "/")[2]) ?? -1
            let faderVal: Float = dataIn.suffix(4).floatValue()
            print("Channel \(faderNum) Fader -> \(faderVal)")
            return ControlCommand(type: .fader, busNum: -1, chNum: faderNum, name: "", value: faderVal)
        }
        else if (path.contains(busFaderRegex)){
            let chFaderNum: Int = Int(path.components(separatedBy: "/")[2]) ?? -1
            let busFaderNum: Int = Int(path.components(separatedBy: "/")[4]) ?? -1
            let faderVal: Float = dataIn.suffix(4).floatValue()
            print("Bus \(busFaderNum) Channel \(chFaderNum) Fader -> \(faderVal)")
            return ControlCommand(type: .fader, busNum: busFaderNum, chNum: chFaderNum, name: "", value: faderVal)
        }
        if (path.contains(busMasterFaderRegex)){
            let faderNum: Int = Int(path.components(separatedBy: "/")[2]) ?? -1
            let faderVal: Float = dataIn.suffix(4).floatValue()
            print("Bus \(faderNum) Fader -> \(faderVal)")
            return ControlCommand(type: .fader, busNum: faderNum, chNum: -1, name: "", value: faderVal)
        }
        else if (path.contains(busMuteRegex)){
            let chNum: Int = Int(path.components(separatedBy: "/")[2]) ?? -1
            let busNum: Int = Int(path.components(separatedBy: "/")[4]) ?? -1
            let muteVal: Bool = (UInt32(bigEndian: dataIn.suffix(4).withUnsafeBytes { $0.load(as: UInt32.self) }) == 0)
            print("Bus \(busNum) Channel \(chNum) Mute \(muteVal)")
            return ControlCommand(type: .mute, busNum: busNum, chNum: chNum, name: "", value: muteVal ? 1.0 : 0.0)
        }
        else if (path.contains(mainMuteRegex)){
            let chNum: Int = Int(path.components(separatedBy: "/")[2]) ?? -1
            let muteVal: Bool = (UInt32(bigEndian: dataIn.suffix(4).withUnsafeBytes { $0.load(as: UInt32.self) }) == 0)
            print("Channel \(chNum) Mute \(muteVal)")
            return ControlCommand(type: .mute, busNum: -1, chNum: chNum, name: "", value: muteVal ? 1.0 : 0.0)
        }
        else if (path.contains(busMasterMuteRegex)){
            let busNum: Int = Int(path.components(separatedBy: "/")[2]) ?? -1
            let muteVal: Bool = (UInt32(bigEndian: dataIn.suffix(4).withUnsafeBytes { $0.load(as: UInt32.self) }) == 0)
            print("Bus \(busNum) Mute \(muteVal)")
            return ControlCommand(type: .mute, busNum: busNum, chNum: -1, name: "", value: muteVal ? 1.0 : 0.0)
        }
        else if (path.contains(chScribbleNameRegex)){
            let chNum: Int = Int(path.components(separatedBy: "/")[2]) ?? -1
            let chName = String(decoding:dataIn.split(separator: Data([44, 115, 0, 0]))[1], as: UTF8.self)
            print ("Channel \(chNum) Name \(chName)")
            return ControlCommand(type: .name, busNum: -1, chNum: chNum, name: chName, value: 0)
        }
        else if (path.contains(busScribbleNameRegex)){
            let busNum: Int = Int(path.components(separatedBy: "/")[2]) ?? -1
            let busName = String(decoding:dataIn.split(separator: Data([44, 115, 0, 0]))[1], as: UTF8.self)
            print ("Bus \(busNum) Name \(busName)")
            return ControlCommand(type: .name, busNum: busNum, chNum: -1, name: busName, value: 0)
        }
        else if (path.contains(chScribbleColorRegex)){
            let chNum: Int = Int(path.components(separatedBy: "/")[2]) ?? -1
            let chColor: Int = Int(UInt32(bigEndian: dataIn.suffix(4).withUnsafeBytes { $0.load(as: UInt32.self) }))
            print ("Channel \(chNum) color \(chColor)")
            return ControlCommand(type: .color, busNum: -1, chNum: chNum, name: "", value: Float(chColor))
        }
        else if (path.contains(busScribbleColorRegex)){
            let busNum: Int = Int(path.components(separatedBy: "/")[2]) ?? -1
            let busColor: Int = Int(UInt32(bigEndian: dataIn.suffix(4).withUnsafeBytes { $0.load(as: UInt32.self) }))
            print ("Bus \(busNum) color \(busColor)")
            return ControlCommand(type: .color, busNum: busNum, chNum: -1, name: "", value: Float(busColor))
        }
        else{
            print("Unknown " + path)
            return nil
        }
        
    }
    
    func prepRequestData(cmdIn: ControlCommand) -> Data{
        var cmdBytes:[UInt8] = []
        switch(cmdIn.type){
        case .fader:
            if (cmdIn.busNum == -1){
                cmdBytes = "/ch/\(String(format: "%02d", cmdIn.chNum))/mix/fader".bytes
            }
            else{
                if (cmdIn.chNum == -1){
                    cmdBytes = "/bus/\(String(format: "%02d", cmdIn.busNum))/mix/fader".bytes
                }
                else{
                    //todo
                }
            }
        case .mute:
            if (cmdIn.busNum == -1){
                cmdBytes = "/ch/\(String(format: "%02d", cmdIn.chNum))/mix/on".bytes
            }
            else{
                if (cmdIn.chNum == -1){
                    cmdBytes = "/bus/\(String(format: "%02d", cmdIn.busNum))/mix/on".bytes
                }
                else{
                    cmdBytes = "/ch/\(String(format: "%02d", cmdIn.chNum))/mix/\(String(format: "%02d", cmdIn.busNum))/on".bytes
                }
            }
        case .name:
            if (cmdIn.busNum == -1){
                cmdBytes = "/ch/\(String(format: "%02d", cmdIn.chNum))/config/name".bytes
            }
            else{
                cmdBytes = "/bus/\(String(format: "%02d", cmdIn.busNum))/config/name".bytes
            }
        case .color:
            if (cmdIn.busNum == -1){
                cmdBytes = "/ch/\(String(format: "%02d", cmdIn.chNum))/config/color".bytes
            }
            else{
                cmdBytes = "/bus/\(String(format: "%02d", cmdIn.busNum))/config/color".bytes
            }
        case .info:
            cmdBytes = "/info".bytes
        }
        
        cmdBytes = cmdBytes + [UInt8](repeating: 0, count: cmdBytes.count % 4)
        let cmdData: Data = Data(cmdBytes)
        return cmdData
    }
    
    func prepOutputData(cmdIn: ControlCommand) -> Data?{
        switch(cmdIn.type){
        case .fader:
            do{
                if (cmdIn.busNum == -1){
                    //main fader
                    //construct command
                    var cmdBytes = "/ch/\(String(format: "%02d", cmdIn.chNum))/mix/fader".bytes
                    cmdBytes = cmdBytes + [0,0,0,0,44,102,0,0]
                    var u32be = cmdIn.value.bitPattern.bigEndian
                    let data = Data(buffer: UnsafeBufferPointer(start: &u32be, count: 1))
                    var cmdData: Data = Data(cmdBytes)
                    cmdData.append(data)
                    return cmdData
                }
                else{
                    if (cmdIn.chNum == -1){
                        //bus master
                        //construct command
                        var cmdBytes = "/bus/\(String(format: "%02d", cmdIn.busNum))/mix/fader".bytes
                        cmdBytes = cmdBytes + [0,0,0,44,102,0,0]
                        var u32be = cmdIn.value.bitPattern.bigEndian
                        let data = Data(buffer: UnsafeBufferPointer(start: &u32be, count: 1))
                        var cmdData: Data = Data(cmdBytes)
                        cmdData.append(data)
                        return cmdData
                    }
                    else{
                        //bus send
                        //todo
                    }
                }
            }
        case .mute:
            do{
                if (cmdIn.busNum == -1){
                    var cmdBytes = "/ch/\(String(format: "%02d", cmdIn.chNum))/mix/on".bytes
                    cmdBytes = cmdBytes + [0,0,0,44,105,0,0]
                    var u32be = Int32(cmdIn.value).bigEndian
                    let data = Data(buffer: UnsafeBufferPointer(start: &u32be, count: 1))
                    var cmdData: Data = Data(cmdBytes)
                    cmdData.append(data)
                    return cmdData
                }
                else{
                    if (cmdIn.chNum == -1){
                        //bus master
                        //construct command
                        var cmdBytes = "/bus/\(String(format: "%02d", cmdIn.busNum))/mix/on".bytes
                        cmdBytes = cmdBytes + [0,0,44,105,0,0]
                        var u32be = Int32(cmdIn.value).bigEndian
                        let data = Data(buffer: UnsafeBufferPointer(start: &u32be, count: 1))
                        var cmdData: Data = Data(cmdBytes)
                        cmdData.append(data)
                        return cmdData
                    }
                    else{
                        var cmdBytes = "/ch/\(String(format: "%02d", cmdIn.chNum))/mix/\(String(format: "%02d", cmdIn.busNum))/on".bytes
                        cmdBytes = cmdBytes + [0,0,0,0,44,105,0,0]
                        var u32be = Int32(cmdIn.value).bigEndian
                        let data = Data(buffer: UnsafeBufferPointer(start: &u32be, count: 1))
                        var cmdData: Data = Data(cmdBytes)
                        cmdData.append(data)
                        return cmdData
                    }
                }
            }
        case .name: break
            //todo
        case .color: break
            //todo
        case .info: break
            //n/a
        }
        
        return nil
        
    }
    
    func stopConnection(){
        self.connection?.cancel()
    }
    
    func startConnection(){
        self.connection?.start(queue: .global())
    }
}

extension Data{
    func floatValue() -> Float {
        return Float(bitPattern: UInt32(bigEndian: self.withUnsafeBytes { $0.load(as: UInt32.self) }))
    }
    
    func split(separator: Data) -> [Data] {
        var chunks: [Data] = []
        var pos = startIndex
        // Find next occurrence of separator after current position:
        while let r = self[pos...].range(of: separator) {
            // Append if non-empty:
            if r.lowerBound > pos {
                chunks.append(self[pos..<r.lowerBound])
            }
            // Update current position:
            pos = r.upperBound
        }
        // Append final chunk, if non-empty:
        if pos < endIndex {
            chunks.append(self[pos..<endIndex])
        }
        return chunks
    }
}

extension StringProtocol {
    var data: Data { .init(utf8) }
    var bytes: [UInt8] { .init(utf8) }
}
