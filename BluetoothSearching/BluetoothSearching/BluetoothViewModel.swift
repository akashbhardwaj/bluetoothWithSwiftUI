//
//  BluetoothViewModel.swift
//  BluetoothSearching
//
//  Created by Akash Bhardwaj on 20/02/23.
//

import Combine
import CoreBluetooth

class BluetoothViewModel: ObservableObject {
    
    @Published var peripherals: [CBPeripheral] = []
    @Published var state: CBManagerState = .unknown
    
    private let bluetoothManager: BluetoothManager
    
    private var subscription = Set<AnyCancellable>()
    private var connectedPeripheral: CBPeripheral?
    private var discoversServices: [CBService] = []

    
    init(_ bluetoothManager: BluetoothManager = BluetoothManager()) {
        self.bluetoothManager = bluetoothManager
        self.setupBluetoothManager()
    }
    
    private func setupBluetoothManager () {
        setupStateDetection()
        setPeripheralDetection()
        setConnectedPeripheralPublisher()
        setDiscoverServicesPublisher()
        setDidDiscoverCharacterstic()
    }
    
    private func setupStateDetection() {
        bluetoothManager.centeralStatePublisher.sink { [weak self] state in
            self?.state = state
        }
        .store(in: &subscription)
    }
    
    private func setPeripheralDetection() {
        bluetoothManager.peripheralsDetected.sink { [weak self] peripheral in
            self?.peripherals.append(peripheral)
        }
        .store(in: &subscription)
    }
    
    private func setConnectedPeripheralPublisher() {
        bluetoothManager.didConnectTo.sink { [weak self] peripheral in
            self?.bluetoothManager.findServices(for: peripheral)
        }
        .store(in: &subscription)
    }
    

    private func setDiscoverServicesPublisher() {
        bluetoothManager.didFindServices.sink { [weak self] services in
            self?.discoversServices = services
        }
        .store(in: &subscription)
    }
    
    private func setDidDiscoverCharacterstic() {
        bluetoothManager.didFindCharacterStics.sink { characterstics in
            
        }
        .store(in: &subscription)
    }
    
    func connect(to peripheral: CBPeripheral) {
        bluetoothManager.connectTo(peripheral)
    }
    
    func readData(for characterstics: CBCharacteristic) {
        bluetoothManager.readValue(for: characterstics)
    }
    
    func findCharacterStics(for service: CBService) {
        bluetoothManager.discoverCharacterstics(for: service)
    }
    
    func writeData() {
        
    }
    
    
}
