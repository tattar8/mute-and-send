//
//  MixerAddView.swift
//  Mute and Send
//
//  Created by Taikhoom Attar on 5/5/23.
//

import SwiftUI

struct MixerAddView: View {
    @Environment(\.dismiss) var dismiss
    @State var initialLaunch = false
    @State var address: String = ""
    @State var port: String = ""
    @State var type: SupportedMixers.MixerType = .X32
    @State var name: String = ""
    @State var enabledBuses: [Bool] = [Bool](repeating: true, count: 16)
    @State var enabledChannels: [Bool] = [Bool](repeating: true, count: 32)
    
    var body: some View {
        Form{
            Section{
                TextField(text: $address, prompt: Text("IP Address (Required)"), label: {Text("IP Address (Required)")})
                TextField(text: $port, prompt: Text("Port (Optional)"), label: {Text("Port (Optional)")})
                TextField(text: $name, prompt: Text("Name (Required)"), label: {Text("Name (Required)")})
                Picker("Model", selection: $type) {
                    ForEach(SupportedMixers.MixerInfo, id: \.modelName){ mixer in
                        Text(mixer.modelName).tag(mixer.type)
                    }
                }
            }
            
            Section(header: Text("Display Channels")){
                ForEach((1...SupportedMixers.MixerInfo[type.rawValue].nChannels), id: \.self){channel in
                    Toggle("Channel \(channel)", isOn: $enabledChannels[channel - 1])
                }
            }
            
            Section(header: Text("Display Buses")){
                ForEach((1...SupportedMixers.MixerInfo[type.rawValue].nBuses), id: \.self){bus in
                    Toggle("Bus \(bus)", isOn: $enabledBuses[bus - 1])
                }
            }
            
            Section{
                Button("Save"){
                    //validate inputs
                    
                    if (port == ""){
                        port = type == .X32 ? "10023" : type.oneOf(.XR12, .XR16, .XR18) ? "10024" : port
                    }
                    guard ((1...65535).contains(Int(port) ?? 0)) else{
                        print("Invalid port")
                        return
                    }
                    if (address.isEmpty){
                        print("No address")
                        return
                    }
                    if (name.isEmpty){
                        name = address
                    }
                    
                    MixerManager.shared.addNewMixer(address: address, port: port, type: type, name: name, channelEnables: enabledChannels, busEnables: enabledBuses)
                    dismiss()
                }.frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .interactiveDismissDisabled(initialLaunch)
    }
}

extension Equatable {
    func oneOf(_ other: Self...) -> Bool {
        return other.contains(self)
    }
}

struct MixerAddView_Previews: PreviewProvider {
    static var previews: some View {
        MixerAddView()
    }
}
