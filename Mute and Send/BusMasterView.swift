//
//  BusMasterView.swift
//  Mute and Send
//
//  Created by Taikhoom Attar on 4/29/23.
//

import SwiftUI

struct BusMasterView: View {
    @ObservedObject var viewModel = MixerManager.shared.activeMixer
    
    
    var body: some View {
        List(viewModel.busMasters.filter(enabledFilter)) {row in
            
            let faderBinding: Binding<Double> = Binding<Double>(get: {
                return row.faderLevel
            }, set: {
                viewModel.updateFader(channel: -1, bus: row.num, value: $0)
            })
            let muteBinding: Binding<Bool> = Binding<Bool>(get: {
                return row.muted
            }, set: {
                viewModel.updateMute(channel: -1, bus: row.num, value: $0)
            })
            
            ChannelRowView(channelName: viewModel.busNames[row.num - 1], faderLevel: faderBinding, unmuted: muteBinding, chColor: row.color, chColorInv: row.colorInv)
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

struct BusMasterView_Previews: PreviewProvider {
    static var previews: some View {
        BusMasterView()
    }
}
