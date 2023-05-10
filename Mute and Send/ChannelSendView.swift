//
//  ChannelSendView.swift
//  Mute and Send
//
//  Created by Taikhoom Attar on 4/5/23.
//

import SwiftUI

struct ChannelSendView: View {
    var sendMuted: Binding<Bool>
    var busName: String = "Bus"
    var busNumber: Int = 2
    var body: some View {
        HStack{
            Text(busName)
            Spacer()
            Toggle("", isOn: sendMuted).labelsHidden()
        }
    }
}

struct ChannelSendView_Previews: PreviewProvider {
    static var previews: some View {
        Text("test")
    }
}
