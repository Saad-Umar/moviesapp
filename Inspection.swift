//
//  Inspection.swift
//  MoviesApp
//
//  Created by Saad Umar on 4/30/23.
//

import Combine

///For interaction with Views,  such as button taps etc
internal final class Inspection<V> {
  let notice = PassthroughSubject<UInt, Never>()
  var callbacks: [UInt: (V) -> Void] = [:]

  func visit(_ view: V, _ line: UInt) {
    if let callback = callbacks.removeValue(forKey: line) {
      callback(view)
    }
  }
}
