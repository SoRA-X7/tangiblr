//
//  SensorDevice.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/08/05.
//

import Foundation
import CoreBluetooth

public class SensorDevice: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let LOCAL_NAME = "Contactile Sensor M5"
    private let SERVICE_UUID = CBUUID(string: "4b958953-4ff5-45e6-97f2-629170aec1f3")
    private let CHARACTERISTIC_UUID_SENSOR = CBUUID(string: "adad0876-f4d1-4189-8604-53ed049f386c")
    
    private var centralManager: CBCentralManager? = nil
    private var peri: CBPeripheral? = nil
    private var chList: [CBCharacteristic] = []
    
    private var sensorValue: Int32 = 0
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        print(centralManager as Any)
    }
    
    public func getValue() -> Int32? {
        if let sensCh = chList.first(where: { $0.uuid == CHARACTERISTIC_UUID_SENSOR }) {
            peri?.readValue(for: sensCh)
            return sensorValue
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
//        print("Device \(uuid) found")
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
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        sensorValue = characteristic.value?.withUnsafeBytes { $0.load( as: Int32.self ) } ?? 0
        print(sensorValue)
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("Disconnection occured")
        self.peri = nil
        chList.removeAll()
    }
    
    public func connect(_ to: CBPeripheral) {
        to.delegate = self
        centralManager!.connect(to)
        peri = to
    }
    
    deinit {
        if let peri = peri {
            centralManager?.cancelPeripheralConnection(peri)
        }
    }
}
