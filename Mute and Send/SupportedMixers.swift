//
//  SupportedMixers.swift
//  Mute and Send
//
//  Created by Taikhoom Attar on 5/3/23.
//

import Foundation

class SupportedMixers{
    enum MixerType: Int{
        case X32
        case XR18
        case XR16
        case XR12
    }
    
    struct MixerProperties{
        var nChannels: Int
        var nBuses: Int
        var modelName: String
        var type: MixerType
    }
    
    static var MixerInfo = [
        MixerProperties(nChannels: 32, nBuses: 16, modelName: "X32/M32", type: .X32),
        MixerProperties(nChannels: 18, nBuses: 12, modelName: "X18/XR18/MR18", type: .XR18),
        MixerProperties(nChannels: 16, nBuses: 12, modelName: "XR16/MR16", type: .XR16),
        MixerProperties(nChannels: 12, nBuses: 6, modelName: "XR12/MR12", type: .XR12)
    ]
}
