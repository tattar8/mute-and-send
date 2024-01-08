//
//  ChannelRowView.swift
//  Mute and Send
//
//  Created by Taikhoom Attar on 4/5/23.
//

import SwiftUI

struct ChannelRowWatchView: View {
    var channelName: String = "Channel"
    var faderLevel: Binding<Double>
    var unmuted: Binding<Bool>
    var chColor: Color = .black
    var chColorInv: Bool = false
    var body: some View {
        VStack{
            ZStack{
                if (chColorInv){
                    RoundedRectangle(cornerRadius: 20).stroke(chColor == .black ? .clear : chColor, lineWidth: 2)
                    Text(channelName).font(.title2).foregroundColor(chColor.isDarkColor ? .white : .black)
                }
                else{
                    Rectangle().foregroundColor(chColor == .black ? .clear : chColor).cornerRadius(20)
                    Text(channelName).font(.title2).foregroundColor(chColor.isDarkColor ? .white : .black)
                }
                //Text("Channel 1").font(.title2)
            }
            Text(" ") //spacer doesn't work here since the ZStack takes precedence
            Toggle("", isOn: unmuted).labelsHidden().scaleEffect(1.5)
            Text(" ") //spacer doesn't work here since the ZStack takes precedence
            Slider(value: faderLevel, in: 0...100, step: 1)
            
            
            
        }
    }
}

extension UIColor
{
    var isDarkColor: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.50
    }
}

extension Color{
    var isDarkColor : Bool {
        return UIColor(self).isDarkColor
    }
}

struct ChannelRowWatchView_Previews: PreviewProvider {
    static var previews: some View {
        Text("test")
    }
}
