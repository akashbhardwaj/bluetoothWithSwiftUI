//
//  BluetoothManager.swift
//  BluetoothSearching
//
//  Created by Akash Bhardwaj on 10/02/23.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject {
    var preDefinedPeripheralCBIUIDs: [CBUUID]? = [CBUUID(string: "0x180D")]
    @Published var peripheralsDetected: [CBPeripheral] = []
    @Published var centralState: CBManagerState = .unknown {
        didSet {
            switch centralState {
            case .poweredOff:
                print("Bluetooth centeral is powered off")
            case .poweredOn:
                print("Bluetooth centeral is powered on")
                scanPeripherals()
            case .resetting:
                print("Bluetooth centeral is reseting")
            case .unauthorized:
                print("You are unautorized to use Bluetooth Centeral")
            case .unknown:
                print("Bluetooth centeral is in Unknown state")
            case .unsupported:
                print("Bluetooth centeral is unsuppoeted in this device")
            @unknown default:
                print("Bluetooth centeral is in unknown default state")
            }
        }
    }
    
    @Published var connectedPeripheral: CBPeripheral?
    
    
    lazy var centralManager: CBCentralManager = {
        let centeral = CBCentralManager(delegate: self, queue: nil)
        return centeral
    }()
    
    init(preDefinedPeripheralCBIUIDs: [CBUUID]? = nil) {
        self.preDefinedPeripheralCBIUIDs = preDefinedPeripheralCBIUIDs
    }
    
    func scanPeripherals () {
        print("Bluetooth centeral is searching for peripherals")
        centralManager.scanForPeripherals(withServices: preDefinedPeripheralCBIUIDs)
    }
    
    func connectTo(_ peripheral: CBPeripheral) {
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }
    
    func disconnectedPeripheral() {
        guard let peripheral = connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func findServices(for peripheral: CBPeripheral, services: [CBUUID]? = nil) {
        peripheral.discoverServices(services)
    }
    
    func discoverCharacterstics(_ characterstics: [CBUUID]? = nil, for service: CBService) {
        guard let peripheral = connectedPeripheral else {
            print("No connected peripheral")
            return
        }
        peripheral.discoverCharacteristics(characterstics, for: service)
    }
    
    func readValue(for characterstic: CBCharacteristic) {
        if characterstic.properties.contains(.read) {
            connectedPeripheral?.readValue(for: characterstic)
        } else if characterstic.properties.contains(.notify) {
            connectedPeripheral?.setNotifyValue(true, for: characterstic)
        } else {
            print("Characterstic provided do not contain read property")
        }
    }
    
}
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralState = central.state

    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Found peripheral \(peripheral)")
        peripheralsDetected.append(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Bluetooth centeral is connected to \(peripheral)")
        connectedPeripheral = peripheral
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        print("Connected peripheral services are \(services)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characterstics = service.characteristics else {
            return
        }
        
        characterstics.forEach { characterstic in
            print("Found Characterstic: \(characterstic) with properties:\(characterstic.properties) for service \(service) for peripheral \(peripheral)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Received value \(characteristic.value) for characterstic \(characteristic)" )
    }
}
extension CBPeripheral: Identifiable {
    public var id: String {
        rssi?.stringValue ?? name ?? "No name"
    }
}
