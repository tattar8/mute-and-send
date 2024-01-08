//
//  TestView.swift
//  Mute and Send Watch Watch App
//
//  Created by Taikhoom Attar on 5/10/23.
//

import SwiftUI


struct TestView: View {
    @State var value:Bool = false
    var body: some View {
        List {
            Toggle("Test", isOn: $value)
            Text("Item 2")
        }.onTapGesture {
            print("tapped")
        }
    }
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
