//
//  ChannelRowView.swift
//  Mute and Send
//
//  Created by Taikhoom Attar on 4/5/23.
//

import SwiftUI

struct BusRowWatchView: View {
    var busName: String = "Bus"
    var unmuted: Binding<Bool>
    var chColor: Color = .black
    var chColorInv: Bool = false
    var body: some View {
        VStack{
            ZStack{
                if (chColorInv){
                    RoundedRectangle(cornerRadius: 20).stroke(chColor == .black ? .clear : chColor, lineWidth: 2)
                    Text(busName).font(.title2).foregroundColor(chColor.isDarkColor ? .white : .black)
                }
                else{
                    Rectangle().foregroundColor(chColor == .black ? .clear : chColor).cornerRadius(20)
                    Text(busName).font(.title2).foregroundColor(chColor.isDarkColor ? .white : .black)
                }
                //Text("Channel 1").font(.title2)
            }
            Text(" ") //spacer doesn't work here since the ZStack takes precedence
            Toggle("", isOn: unmuted).labelsHidden().scaleEffect(1.5)
            Text(" ") //spacer doesn't work here since the ZStack takes precedence
            
            
            
        }
    }
}


struct BusRowWatchView_Previews: PreviewProvider {
    static var previews: some View {
        Text("test")
    }
}
