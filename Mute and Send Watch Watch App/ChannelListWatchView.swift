//
//  ChannelListWatch.swift
//  Mute and Send Watch Watch App
//
//  Created by Taikhoom Attar on 5/10/23.
//

import SwiftUI

struct ChannelListWatch: View {
    @ObservedObject var activeMixer = MixerManager.shared.activeMixer
    @ObservedObject var mixerManager = MixerManager.shared
    var body: some View {
        List{
            ForEach(activeMixer.enabledChannels.filter(enabledFilter)){ row in
                let faderBinding: Binding<Double> = Binding<Double>(get: {
                    return row.faderLevel
                }, set: {
                    if (row.isChannel){
                        activeMixer.updateFader(channel: row.num, bus: -1, value: $0)
                    }
                    else{
                        activeMixer.updateFader(channel: row.parentNum!, bus: row.num, value: $0)
                    }
                })
                let muteBinding: Binding<Bool> = Binding<Bool>(get: {
                    return row.muted
                }, set: {
                    if (row.isChannel){
                        activeMixer.updateMute(channel: row.num, bus: -1, value: $0)
                    }
                    else{
                        activeMixer.updateMute(channel: row.parentNum!, bus: row.num, value: $0)
                    }
                })
                NavigationLink(destination: BusSendWatchView(channelNo: row.num)){
                    if (row.isChannel){
                        ChannelRowWatchView(channelName: activeMixer.channelNames[row.num - 1], faderLevel: faderBinding, unmuted: muteBinding, chColor: row.color, chColorInv: row.colorInv)
                    }
                    else{
                        ChannelSendView(sendMuted: muteBinding, busName: activeMixer.busNames[row.num - 1], busNumber: row.num)
                    }
                }
            }
        }
        .listStyle(.carousel)
        .navigationTitle(mixerManager.activeMixerProfile.name)
    }
    
    func enabledFilter(_ channel: Control) -> Bool{
        if (channel.isChannel){
            return MixerManager.shared.activeMixerProfile.channelsEnabled[channel.num - 1]
        }
        else{
            return MixerManager.shared.activeMixerProfile.busesEnabled[channel.num - 1]
        }
    }
}

struct ChannelListWatch_Previews: PreviewProvider {
    static var previews: some View {
        ChannelListWatch()
    }
}
