//
//  BusMasterWatchView.swift
//  Mute and Send Watch Watch App
//
//  Created by Taikhoom Attar on 5/10/23.
//

import SwiftUI

struct BusMasterWatchView: View {
    @ObservedObject var activeMixer = MixerManager.shared.activeMixer
    @ObservedObject var mixerManager = MixerManager.shared
    var body: some View {
        List{
            ForEach(activeMixer.busMasters.filter(mixerManager.enabledFilter)) {row in
                let faderBinding: Binding<Double> = Binding<Double>(get: {
                    return row.faderLevel
                }, set: {
                    activeMixer.updateFader(channel: -1, bus: row.num, value: $0)
                })
                let muteBinding: Binding<Bool> = Binding<Bool>(get: {
                    return row.muted
                }, set: {
                    activeMixer.updateMute(channel: -1, bus: row.num, value: $0)
                })
                ZStack{
                    Spacer().background(.black).opacity(0.01)
                        .onTapGesture {
                            print("green pressed")
                        }
                        
                        
                    ChannelRowWatchView(channelName: activeMixer.busNames[row.num - 1], faderLevel: faderBinding, unmuted: muteBinding, chColor: row.color, chColorInv: row.colorInv)
                }
            }
        }
        .listStyle(.carousel)
        .navigationTitle(mixerManager.activeMixerProfile.name)
        
    }
}

struct BusMasterWatchView_Previews: PreviewProvider {
    static var previews: some View {
        BusMasterWatchView()
    }
}
