//
//  ContentView.swift
//  BluetoothSearching
//
//  Created by Akash Bhardwaj on 10/02/23.
//

import SwiftUI
import Combine

struct ContentView: View {

    
    
    var body: some View {

        NavigationStack {
//            List($bluetoothManager.peripheralsDetected) { item in
//            }
            Text("item.wrappedValue.name ?? No Peripheral")

        }
        .onAppear {
//            bluetoothManager.scanPeripherals()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
