//
//  MyBluetoothManager+State.swift
//  KozBon
//
//  Created by Kelvin Kosbab on 1/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import CoreBluetooth

enum MyBluetoothManagerState {
  case poweredOff, poweredOn, resetting, unauthorized, unknown, unsupported
  
  static func convert(cbMManagerState state: CBManagerState) -> MyBluetoothManagerState {
    switch state {
    case .poweredOff: return .poweredOff
    case .poweredOn: return .poweredOn
    case .resetting: return .resetting
    case .unauthorized: return .unauthorized
    case .unknown: return .unknown
    case .unsupported: return .unsupported
    }
  }
  
  var string: String {
    switch self {
    case .poweredOff: return "Powered Off"
    case .poweredOn: return "Powered On"
    case .resetting: return "Resetting"
    case .unauthorized: return "Unauthorized"
    case .unknown: return "Unknown"
    case .unsupported: return "Unsupported"
    }
  }
  
  var isPoweredOn: Bool {
    return self == .poweredOn
  }
  
  var isPoweredOff: Bool {
    return self == .poweredOff
  }
  
  var isResetting: Bool {
    return self == .resetting
  }
  
  var isUnauthorized: Bool {
    return self == .unauthorized
  }
  
  var isUnknown: Bool {
    return self == .unknown
  }
  
  var isUnsupported: Bool {
    return self == .unsupported
  }
}

extension CBCentralManager {
  
  var bluetoothManagerState: MyBluetoothManagerState {
    return MyBluetoothManagerState.convert(cbMManagerState: self.state)
  }
}