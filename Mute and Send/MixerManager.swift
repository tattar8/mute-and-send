//
//  MixerManager.swift
//  Mute and Send
//
//  Created by Taikhoom Attar on 5/2/23.
//

import Foundation

class MixerManager: ObservableObject{
    struct MixerProfile: Identifiable, Codable{
        var channelsEnabled: [Bool]
        var busesEnabled: [Bool]
        var ipAddress: String
        var port: String
        var name: String
        var type: Int
        var id = UUID()
    }
    
    @Published var mixerProfiles: [MixerProfile]
    @Published var activeMixer: ControlViewModel
    @Published var activeMixerProfile: MixerProfile
    
    var allMixerModels: Dictionary<UUID, ControlViewModel>
    
    static let shared = MixerManager()
    
    
    init(){
        var mixerProfiles = UserDefaults.standard.object(forKey: "MixerProfiles") as? [MixerManager.MixerProfile] ?? []
        
        if
            let data = UserDefaults.standard.value(forKey: "MixerProfilesJson") as? Data,
            let profiles = try? JSONDecoder().decode([MixerProfile].self, from: data) {
            print(profiles)
            mixerProfiles = profiles
        }
        else{
            mixerProfiles = []
        }
        allMixerModels = [:]
        
        if (mixerProfiles.isEmpty){
            let dummy: MixerProfile = MixerProfile(channelsEnabled: [Bool](repeating: true, count: 6), busesEnabled: [Bool](repeating: true, count: 12), ipAddress: "0.0.0.0", port: "1", name: "Dummy", type: SupportedMixers.MixerType.X32.rawValue)
            mixerProfiles.append(dummy)
            allMixerModels.updateValue(ControlViewModel(addressIn: "0.0.0.0", portIn: "1", mixerType: .X32), forKey: dummy.id)
        }
        
        else{
            for profile in mixerProfiles{
                allMixerModels.updateValue(ControlViewModel(addressIn: profile.ipAddress, portIn: profile.port, mixerType: SupportedMixers.MixerType(rawValue: profile.type) ?? .X32), forKey: profile.id)
            }
        }
        activeMixer = allMixerModels[mixerProfiles[0].id]!
        activeMixerProfile = mixerProfiles[0]
        self.mixerProfiles = mixerProfiles
    }
    
    func addNewMixer(address: String, port: String, type: SupportedMixers.MixerType, name: String, channelEnables: [Bool] = [], busEnables: [Bool] = []){
        var newProfile:MixerProfile = MixerProfile(channelsEnabled: [], busesEnabled: [], ipAddress: address, port: port, name: name, type: type.rawValue)
        
        //default enables
        newProfile.busesEnabled = busEnables == [] ? [Bool](repeating: true, count: SupportedMixers.MixerInfo[type.rawValue].nBuses) : busEnables
        newProfile.channelsEnabled = channelEnables == [] ? [Bool](repeating: true, count: SupportedMixers.MixerInfo[type.rawValue].nChannels) : channelEnables
        
        //delete the dummy if it's there
        if (mixerProfiles.count == 1 && mixerProfiles[0].name == "Dummy"){
            allMixerModels.removeValue(forKey: mixerProfiles[0].id)
            mixerProfiles.remove(at: 0)
        }
        
        mixerProfiles.append(newProfile)
        allMixerModels.updateValue(ControlViewModel(addressIn: address, portIn: port, mixerType: type), forKey: newProfile.id)
        
        if let data = try? JSONEncoder().encode(mixerProfiles) {
            UserDefaults.standard.set(data, forKey: "MixerProfilesJson")
        }

        
        //if the new one is now the only mixer, make it the active one
        
        if (mixerProfiles.count == 1){
            activeMixer = allMixerModels[newProfile.id]!
            activeMixerProfile = newProfile
        }
        
        //UserDefaults.standard.set(mixerProfiles, forKey: "MixerProfiles")
        
    }
    
    func setActiveMixer(activeMixerProfile:MixerProfile){
        activeMixer = allMixerModels[activeMixerProfile.id]!
        self.activeMixerProfile = activeMixerProfile
    }
    
    func setActiveMixer(activeMixerID:UUID){
        if ((allMixerModels[activeMixerID]) != nil){
            activeMixer = allMixerModels[activeMixerID]!
            self.activeMixerProfile = mixerProfiles.first(where: {$0.id == activeMixerID})!
        }
    }
    
    func deleteMixer(mixerUUID: UUID){
        allMixerModels.removeValue(forKey: mixerUUID)
        mixerProfiles.remove(at: mixerProfiles.firstIndex(where: {$0.id == mixerUUID})!)
        
        if (activeMixerProfile.id == mixerUUID){
            //deleting the active mixer
            activeMixerProfile = mixerProfiles[0]
            activeMixer = allMixerModels[activeMixerProfile.id]!
        }
    }
}
