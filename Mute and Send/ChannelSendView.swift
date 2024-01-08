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
    var chColor: Color = .black
    var chColorInv: Bool = false
    var body: some View {
        HStack{
            ZStack{
                if (chColorInv){
                    Text(busName).padding(.leading, 10).padding(.trailing, 10).overlay(RoundedRectangle(cornerRadius: 20).stroke(chColor == .black ? .clear : chColor, lineWidth: 2))
                }
                else{
                    Text(busName).foregroundColor(chColor.isDarkColor ? .white : .black).padding(.leading, 10).padding(.trailing, 10).background(chColor == .black ? .clear : chColor).cornerRadius(20)
                }
            }
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
