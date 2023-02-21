//
//  BluetoothManager.swift
//  BluetoothSearching
//
//  Created by Akash Bhardwaj on 10/02/23.
//

import Foundation
import CoreBluetooth
import Combine
class BluetoothManager: NSObject, ObservableObject {
    private var _peripheralsDetected = PassthroughSubject<CBPeripheral, Never>()
    private var _centeralStatePublisher = PassthroughSubject<CBManagerState, Never>()
    private var _didFindCharacterStics = PassthroughSubject<[CBCharacteristic], Never>()
    private var _connectedPeripheralPublisher = PassthroughSubject<CBPeripheral, Never>()
    private var _didFindServices = PassthroughSubject<[CBService], Never>()
    private var _updatedValueForConnectedPeripheral = PassthroughSubject<(peripheral: CBPeripheral, characterstic: CBCharacteristic), Error>()
    

    
    var preDefinedPeripheralServiceCBIUIDs: [CBUUID]? = [CBUUID(string: "0x180D")]

    private var connectedPeripheral: CBPeripheral?
    
    
    
    
    lazy var centralManager: CBCentralManager = {
        let centeral = CBCentralManager(delegate: self, queue: nil)
        return centeral
    }()
    
    init(preDefinedPeripheralCBIUIDs: [CBUUID]? = nil) {
        self.preDefinedPeripheralServiceCBIUIDs = preDefinedPeripheralCBIUIDs
    }
    
    func scanPeripherals () {
        print("Bluetooth centeral is searching for peripherals")
        centralManager.scanForPeripherals(withServices: preDefinedPeripheralServiceCBIUIDs)
    }
    
    func stopScanningForPeripherals() {
        centralManager.stopScan()
    }
    
    func connectTo(_ peripheral: CBPeripheral) {
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }
    
    func didConnect(to peripheral: CBPeripheral) {
        _connectedPeripheralPublisher.send(peripheral)
    }
    
    func disconnetPeripheral() {
        guard let peripheral = connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func findServices(for peripheral: CBPeripheral, services: [CBUUID]? = nil) {
        peripheral.discoverServices(services)
    }
    
    func discoverCharacterstics(_ characterstic: CBUUID? = nil, for service: CBService) {
        guard let peripheral = connectedPeripheral else {
            print("No connected peripheral")
            return
        }
        var characterStics: [CBUUID]?
        if let targetCharacterStic = characterstic {
            characterStics = [targetCharacterStic]
        }
        peripheral.discoverCharacteristics(characterStics, for: service)
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
    
    func write(_ data: Data, for characterstic: CBCharacteristic) {
        guard let peripheral = connectedPeripheral,
              peripheral.canSendWriteWithoutResponse else {
            return
        }
        var rawPacket = [UInt8]()
        let mtu = peripheral.maximumWriteValueLength(for: .withoutResponse)
        let bytesToCopy = min(mtu, data.count)
        data.copyBytes(to: &rawPacket, count: bytesToCopy)
        
        let packetData = Data(bytes: &rawPacket, count: bytesToCopy)
        peripheral.writeValue(packetData, for: characterstic, type: .withoutResponse)
        
    }
    
}
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        _centeralStatePublisher.send(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Found peripheral \(peripheral)")
        _peripheralsDetected.send(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Bluetooth centeral is connected to \(peripheral)")
        didConnect(to: peripheral)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        print("Connected peripheral services are \(services)")
        _didFindServices.send(services)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characterstics = service.characteristics else {
            return
        }
        
        characterstics.forEach { characterstic in
            print("Found Characterstic: \(characterstic) with properties:\(characterstic.properties) for service \(service) for peripheral \(peripheral)")
        }
        _didFindCharacterStics.send(characterstics)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Received value \(String(describing: characteristic.value)) for characterstic \(characteristic)" )
        if let error = error {
            _updatedValueForConnectedPeripheral.send(completion: .failure(error))
            return
        }
        _updatedValueForConnectedPeripheral.send((peripheral: peripheral, characterstic: characteristic))
        
        
    }
    

}
extension CBPeripheral: Identifiable {
    public var id: String {
        name ?? UUID().uuidString
    }
}

extension BluetoothManager {
    var peripheralsDetected: AnyPublisher<CBPeripheral, Never> {
        _peripheralsDetected.eraseToAnyPublisher()
    }
    var centeralStatePublisher: AnyPublisher<CBManagerState, Never> {
        _centeralStatePublisher.eraseToAnyPublisher()
    }
    var didFindCharacterStics: AnyPublisher<[CBCharacteristic], Never> {
        _didFindCharacterStics.eraseToAnyPublisher()
    }
    var didConnectTo: AnyPublisher<CBPeripheral, Never> {
        _connectedPeripheralPublisher.eraseToAnyPublisher()
    }
    var didFindServices: AnyPublisher<[CBService], Never> {
        _didFindServices.eraseToAnyPublisher()
    }
    var updatedValueForConnectedPeripheral: AnyPublisher<(peripheral: CBPeripheral, characterstic: CBCharacteristic), Error> {
        _updatedValueForConnectedPeripheral.eraseToAnyPublisher()
    }
}
