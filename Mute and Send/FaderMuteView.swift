//
//  ContentView.swift
//  Mute and Send
//
//  Created by Taikhoom Attar on 4/5/23.
//

import SwiftUI



struct FaderMuteView: View {
    @ObservedObject var viewModel = MixerManager.shared.activeMixer
    
    
    var body: some View {
        List(viewModel.enabledChannels.filter(enabledFilter), children: \.buses) {row in
            
            let faderBinding: Binding<Double> = Binding<Double>(get: {
                return row.faderLevel
            }, set: {
                if (row.isChannel){
                    viewModel.updateFader(channel: row.num, bus: -1, value: $0)
                }
                else{
                    viewModel.updateFader(channel: row.parentNum!, bus: row.num, value: $0)
                }
            })
            let muteBinding: Binding<Bool> = Binding<Bool>(get: {
                return row.muted
            }, set: {
                if (row.isChannel){
                    viewModel.updateMute(channel: row.num, bus: -1, value: $0)
                }
                else{
                    viewModel.updateMute(channel: row.parentNum!, bus: row.num, value: $0)
                }
            })
            
            if (row.isChannel){
                ChannelRowView(channelName: viewModel.channelNames[row.num - 1], faderLevel: faderBinding, unmuted: muteBinding, chColor: row.color, chColorInv: row.colorInv)
            }
            else{
                ChannelSendView(sendMuted: muteBinding, busName: viewModel.busNames[row.num - 1], busNumber: row.num)
            }
        }
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

struct FaderMuteView_Previews: PreviewProvider {
    static var previews: some View {
        FaderMuteView()
    }
}
