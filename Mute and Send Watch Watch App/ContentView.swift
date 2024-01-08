//
//  ContentView.swift
//  Mute and Send Watch Watch App
//
//  Created by Taikhoom Attar on 5/10/23.
//

import SwiftUI

struct ContentView: View {
    var comms:WatchConnection = WatchConnection()
    @ObservedObject var activeMixer = MixerManager.shared.activeMixer
    @ObservedObject var mixerManager = MixerManager.shared
    var body: some View {
        if (mixerManager.activeMixerProfile.name == "Dummy"){
            VStack{
                Text("No mixers added").font(.title)
                Text("Add mixer on iPhone")
                    .onAppear{
                        WatchConnection.shared.sendRequestForContext()
                    }
            }
        }
        else if (!mixerManager.activeMixer.connectionGood){
            VStack{
                NavigationStack{
                    Text("Mixer not connected")
                    if let error = mixerManager.activeMixer.connectionError{
                        Text("Error: \(error.localizedDescription)")
                    }
                    Button("Try to Connect"){
                        mixerManager.activeMixer.tryToConnect()
                    }
                
                    NavigationLink("Select Mixer", destination: MixerSelectionView())
                    .navigationTitle(mixerManager.activeMixerProfile.name)
                }
            }
        }
        else{
            NavigationStack{
                List{
                    Section{
                        NavigationLink("Channels", destination: ChannelListWatch())
                        NavigationLink("Bus Masters", destination: BusMasterWatchView())
                    }
                    Section{
                        NavigationLink("Select Mixer", destination: MixerSelectionView())
                    }
                }
                .navigationTitle(mixerManager.activeMixerProfile.name)
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
