//
//  MixerSelectionView.swift
//  Mute and Send
//
//  Created by Taikhoom Attar on 5/5/23.
//

import SwiftUI

struct MixerSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State var selectedMixer: UUID = MixerManager.shared.activeMixerProfile.id
    @ObservedObject var viewModel = MixerManager.shared.activeMixer
    let nMixers: Binding<Int> = Binding<Int>(get: {
        return MixerManager.shared.mixerProfiles.count
    }, set: {_ in 
        
    })
    @State private var showingSheet = false
    var body: some View {
        VStack{
            Form{
                Section("Select mixer..."){
                    List(){
                        ForEach(MixerManager.shared.mixerProfiles, id: \.self.id){profile in
                            HStack{
                                Text(profile.name)
                                Spacer()
                                if (profile.id == selectedMixer){
                                    Image(systemName: "checkmark")
                                }
                                
                            }
                            .onTapGestureForced {
                                print("Tapped \(profile.name)")
                                selectedMixer = profile.id
                            }
                        }
#if os(iOS)
                        .onDelete(perform: {indices in
                            print("Attempt to delete \(indices.first!)")
                            MixerManager.shared.deleteMixer(mixerUUID: MixerManager.shared.mixerProfiles[indices.first!].id)
                        })
                        .deleteDisabled(MixerManager.shared.mixerProfiles.count <= 1)
#endif
                    }
                }
#if os(iOS)
                Section{
                    Button("Add..."){
                        showingSheet.toggle()
                    }
                }
#endif
            }.sheet(isPresented: $showingSheet) {
#if os(iOS)
                MixerAddView()
#endif
            }
            .onChange(of: selectedMixer, perform: {newValue in
                MixerManager.shared.setActiveMixer(activeMixerID: newValue)
            })
        }
        
        
    }
}

extension View {
    func onTapGestureForced(count: Int = 1, perform action: @escaping () -> Void) -> some View {
        self
            .contentShape(Rectangle())
            .onTapGesture(count:count, perform:action)
    }
}

struct MixerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MixerSelectionView()
    }
}
