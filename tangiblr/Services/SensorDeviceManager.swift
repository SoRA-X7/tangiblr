//
//  SensorDevice.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/08/05.
//

import Foundation
import CoreBluetooth

@Observable
public class SensorDeviceManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let LOCAL_NAME = "Contactile Sensor M5"
    private let SERVICE_UUID = CBUUID(string: "4b958953-4ff5-45e6-97f2-629170aec1f3")
    private let CHARACTERISTIC_UUID_SENSOR = CBUUID(string: "adad0876-f4d1-4189-8604-53ed049f386c")
    
    private var centralManager: CBCentralManager? = nil
    private var peri: CBPeripheral? = nil
    private var chList: [CBCharacteristic] = []
    
    private var sensorValues: [Int32] = []
    private var recording = false
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        print(centralManager as Any)
    }
    
    public func isConnected() -> Bool {
        return peri != nil
    }
    
    public func getValues() -> [Int32]? {
        if let sensCh = chList.first(where: { $0.uuid == CHARACTERISTIC_UUID_SENSOR }) {
            peri?.readValue(for: sensCh)
            defer {
                sensorValues = []
            }
            return sensorValues
        }
        return nil
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state update")
        switch central.state {
            case .poweredOff:
                print("poweredOff")
            case .unknown:
                print("unknown")
            case .resetting:
                print("resetting")
            case .unsupported:
                print("unsupported")
            case .unauthorized:
                print("unauthorized")
            case .poweredOn:
                print("poweredOn")
            central.scanForPeripherals(withServices: nil)
        @unknown default:
            fatalError()
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let uuid = UUID(uuid: peripheral.identifier.uuid)
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("UUID=[\(uuid)] Name=[\(localName)]")
            if localName == LOCAL_NAME {
                connect(peripheral)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to: \(peripheral.identifier.uuidString)")
        peripheral.discoverServices([SERVICE_UUID])
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        print(peripheral.services ?? [])
        peripheral.discoverCharacteristics([CHARACTERISTIC_UUID_SENSOR], for: peripheral.services![0])
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        chList.removeAll()
        chList.append(contentsOf: service.characteristics!)
        print(chList)
    }
    
//    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
//        sensorValue = characteristic.value?.withUnsafeBytes { $0.load( as: Int32.self ) } ?? 0
//    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
//        print(characteristic.value)
        if recording {
            sensorValues.append(characteristic.value?.withUnsafeBytes { $0.load( as: Int32.self ) } ?? 0)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("Disconnection occured")
        self.peri = nil
        chList.removeAll()
        central.scanForPeripherals(withServices: nil)
    }
    
    public func connect(_ to: CBPeripheral) {
        to.delegate = self
        centralManager!.connect(to)
        peri = to
    }
    
    public func start() {
        recording = true
        peri?.setNotifyValue(true, for: chList[0])
    }
    
    public func stop() {
        recording = false
        peri?.setNotifyValue(false, for: chList[0])
        sensorValues.removeAll()
    }
    
    deinit {
        if let peri = peri {
            centralManager?.cancelPeripheralConnection(peri)
        }
    }
}
