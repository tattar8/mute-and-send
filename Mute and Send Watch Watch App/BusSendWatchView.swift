//
//  BusSendWatchView.swift
//  Mute and Send Watch Watch App
//
//  Created by Taikhoom Attar on 5/11/23.
//

import SwiftUI

struct BusSendWatchView: View {
    @ObservedObject var activeMixer = MixerManager.shared.activeMixer
    @ObservedObject var mixerManager = MixerManager.shared
    @State var channelNo: Int
    var body: some View {
        List{
            ForEach(activeMixer.enabledChannels[channelNo-1].buses!.filter(mixerManager.enabledFilter)) {row in
                
                let muteBinding: Binding<Bool> = Binding<Bool>(get: {
                    return row.muted
                }, set: {
                    activeMixer.updateMute(channel: channelNo, bus: row.num, value: $0)
                })
                ZStack{
                    Spacer().background(.black).opacity(0.01)
                        .onTapGesture {
                            print("green pressed")
                        }
                        
                        
                    BusRowWatchView(busName: activeMixer.busNames[row.num - 1], unmuted: muteBinding, chColor: activeMixer.busMasters[row.num - 1].color, chColorInv: activeMixer.busMasters[row.num - 1].colorInv)
                }
            }
        }
        .navigationTitle("\(mixerManager.activeMixerProfile.name) - \(activeMixer.channelNames[channelNo - 1])")
    }
}

struct BusSendWatchView_Previews: PreviewProvider {
    static var previews: some View {
        BusSendWatchView(channelNo: 1)
    }
}
