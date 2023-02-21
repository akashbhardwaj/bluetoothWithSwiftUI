#  Bluetooth Manager


## Steps to discover Peripherals
    1. Create a CBCenteralManger with proper CBCentralManagerDelegate other u eill hit a console error
    2. We will receive the CBCenteral's state in `centralManagerDidUpdateState(central: CBCentralManager)`
        delegate method 
    
    3. start scanning CBPeripherals (bluetooth devices) centeralManager.scanForPeripherals(withServices:) you can pass CBUUID of the services for which you want to specific CBPeripherals
    4. We will receive the peripherals in the vicinity via `centralManager(central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)`
        delegate method.
    5. From the peripheral devices you can connect to the peripheral device with `centralManager.connect(peripheral)` method. Once the peripheral is connected you will be notifiy via `centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)` method of the delegate
    6. After connecting to a Peripheral we will try and read data from it. In oreder to that we need to find the services which are provided by a Peripheral.
        We can do that by calling `discoverServices(_ services: )` method of CBPeripheral. Before that we need to adpot to the `CBPeripheralDelegate`.
    7. We will receive the Peripheral's services via CBPeripheralDelegate method `peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)`
    
