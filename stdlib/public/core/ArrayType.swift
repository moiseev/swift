//===--- ArrayType.swift - Protocol for Array-like types ------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

public // @testable
protocol _ArrayProtocol
  : RangeReplaceableCollection,
    ArrayLiteralConvertible
{
  //===--- public interface -----------------------------------------------===//
  /// The number of elements the Array stores.
  var length: Int {get}

  /// The number of elements the Array can store without reallocation.
  var capacity: Int {get}

  /// `true` if and only if the Array is empty.
  var isEmpty: Bool {get}

  /// An object that guarantees the lifetime of this array's elements.
  var _owner: AnyObject? {get}

  /// If the elements are stored contiguously, a pointer to the first
  /// element. Otherwise, `nil`.
  var _baseAddressIfContiguous: UnsafeMutablePointer<Element> {get}

  subscript(index: Int) -> Iterator.Element {get set}

  //===--- basic mutations ------------------------------------------------===//

  /// Reserve enough space to store minimumCapacity elements.
  ///
  /// - Postcondition: `capacity >= minimumCapacity` and the array has
  ///   mutable contiguous storage.
  ///
  /// - Complexity: O(`self.length`).
  mutating func reserveCapacity(minimumCapacity: Int)

  /// Operator form of `appendContentsOf`.
  func += <
    S: Sequence where S.Iterator.Element == Iterator.Element
  >(inout lhs: Self, rhs: S)

  /// Insert `newElement` at index `i`.
  ///
  /// Invalidates all indices with respect to `self`.
  ///
  /// - Complexity: O(`self.length`).
  ///
  /// - Requires: `i <= length`.
  mutating func insert(newElement: Iterator.Element, at i: Int)

  /// Remove and return the element at the given index.
  ///
  /// - returns: The removed element.
  ///
  /// - Complexity: Worst case O(N).
  ///
  /// - Requires: `length > index`.
  mutating func removeAt(index: Int) -> Iterator.Element

  //===--- implementation detail  -----------------------------------------===//

  associatedtype _Buffer : _ArrayBufferProtocol
  init(_ buffer: _Buffer)

  // For testing.
  var _buffer: _Buffer {get}
}

internal struct _ArrayProtocolMirror<
  T : _ArrayProtocol where T.Index == Int
> : _Mirror {
  let _value : T

  init(_ v : T) { _value = v }

  var value: Any { return (_value as Any) }

  var valueType: Any.Type { return (_value as Any).dynamicType }

  var objectIdentifier: ObjectIdentifier? { return nil }

  var length: Int { return _value.length }

  subscript(i: Int) -> (String, _Mirror) {
    _require(i >= 0 && i < length, "_Mirror access out of bounds")
    return ("[\(i)]", _reflect(_value[_value.startIndex + i]))
  }

  var summary: String {
    if length == 1 { return "1 element" }
    return "\(length) elements"
  }

  var quickLookObject: PlaygroundQuickLook? { return nil }

  var disposition: _MirrorDisposition { return .IndexContainer }
}
