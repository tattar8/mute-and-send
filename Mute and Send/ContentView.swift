//
//  ContentView.swift
//  Mute and Send
//
//  Created by Taikhoom Attar on 4/29/23.
//

import SwiftUI

struct ContentView: View {
    @State private var showingSheet = false
    @State private var noMixerDefined = false
    @ObservedObject var mixerManager = MixerManager.shared
    @ObservedObject var activeMixer = MixerManager.shared.activeMixer
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationView {
            
            if (mixerManager.activeMixer.connectionGood){
                TabView{
                    FaderMuteView()
                        .tabItem {
                            Label("Main LR", systemImage: "cable.connector")
                        }
                    BusMasterView()
                        .tabItem {
                            Label("Bus Mutes", systemImage: "speaker.slash")
                        }
                }
                .accentColor(.orange)
                .navigationTitle(mixerManager.activeMixerProfile.name)
                .toolbar {
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "gear.circle")//.foregroundColor(.white)
                    }
                }
            }
            else{
                VStack{
                    Text("Mixer not connected")
                    if let error = mixerManager.activeMixer.connectionError{
                        Text("Error: \(error.localizedDescription)")
                    }
                    Button("Try to Connect"){
                        mixerManager.activeMixer.tryToConnect()
                    }
                }
                .accentColor(.orange)
                .navigationTitle(mixerManager.activeMixerProfile.name)
                .toolbar {
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "gear.circle")//.foregroundColor(.white)
                    }
                }
            }
            
        }.tint(.orange)
        .sheet(isPresented: $showingSheet) {
            MixerSelectionView()
        }
        .sheet(isPresented: $noMixerDefined){
            MixerAddView(initialLaunch: true)
        }
        .onAppear{
            if (mixerManager.activeMixerProfile.name == "Dummy"){
                noMixerDefined = true
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                print("Active")
                for model in mixerManager.allMixerModels.values{
                    model.tryToConnect()
                }
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("Background")
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
