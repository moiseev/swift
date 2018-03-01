//===--- Map.swift - Lazily map over a Sequence ---------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// A `Sequence` whose elements consist of those in a `Base`
/// `Sequence` passed through a transform function returning `Element`.
/// These elements are computed lazily, each time they're read, by
/// calling the transform function on a base element.
@_fixed_layout
public struct LazyMap<Base: Sequence, Element> {
  public typealias Elements = LazyMap

  @_versioned
  internal var _base: Base
  @_versioned
  internal let _transform: (Base.Element) -> Element

  /// Creates an instance with elements `transform(x)` for each element
  /// `x` of base.
  @_inlineable
  @_versioned
  internal init(_base: Base, transform: @escaping (Base.Element) -> Element) {
    self._base = _base
    self._transform = transform
  }
}

extension LazyMap {
  @_fixed_layout
  public struct Iterator {
    @_versioned
    internal var _base: Base.Iterator
    @_versioned
    internal let _transform: (Base.Element) -> Element

    @_inlineable
    public var base: Base.Iterator { return _base }

    @_inlineable
    @_versioned
    internal init(
      _base: Base.Iterator, 
      _transform: @escaping (Base.Element) -> Element
    ) {
      self._base = _base
      self._transform = _transform
    }
  }
}

extension LazyMap.Iterator: IteratorProtocol, Sequence {
  /// Advances to the next element and returns it, or `nil` if no next element
  /// exists.
  ///
  /// Once `nil` has been returned, all subsequent calls return `nil`.
  ///
  /// - Precondition: `next()` has not been applied to a copy of `self`
  ///   since the copy was made.
  @_inlineable
  public mutating func next() -> Element? {
    return _base.next().map(_transform)
  }
}

extension LazyMap: Sequence, LazySequenceProtocol {
  /// Returns an iterator over the elements of this sequence.
  ///
  /// - Complexity: O(1).
  @_inlineable
  public func makeIterator() -> Iterator {
    return Iterator(_base: _base.makeIterator(), _transform: _transform)
  }

  /// A value less than or equal to the number of elements in the sequence,
  /// calculated nondestructively.
  ///
  /// The default implementation returns 0. If you provide your own
  /// implementation, make sure to compute the value nondestructively.
  ///
  /// - Complexity: O(1), except if the sequence also conforms to `Collection`.
  ///   In this case, see the documentation of `Collection.underestimatedCount`.
  @_inlineable
  public var underestimatedCount: Int {
    return _base.underestimatedCount
  }

  @_inlineable
  public func dropFirst(_ n: Int) -> SubSequence {
    fatalError()
  }

  @_inlineable
  public func dropLast(_ n: Int) -> SubSequence {
    fatalError()
  }

  @_inlineable
  public func drop(
    while predicate: (Element) throws -> Bool
  ) rethrows -> SubSequence {
    fatalError()
  }

  @_inlineable
  public func prefix(_ maxLength: Int) -> SubSequence {
    fatalError()
  }

  @_inlineable
  public func prefix(
    while predicate: (Element) throws -> Bool
  ) rethrows -> SubSequence {
    fatalError()
  }

  @_inlineable
  public func suffix(_ maxLength: Int) -> SubSequence {
    fatalError()
  }

  @_inlineable
  public func split(
    maxSplits: Int, omittingEmptySubsequences: Bool,
    whereSeparator isSeparator: (Element) throws -> Bool
  ) rethrows -> [SubSequence] {
    fatalError()
  }
}

extension LazyMap: Collection, LazyCollectionProtocol
where Base: Collection {
  public typealias Index = Base.Index
  public typealias Indices = Base.Indices
  public typealias SubSequence = LazyMap<Base.SubSequence, Element>

  @_inlineable
  public var startIndex: Base.Index { return _base.startIndex }
  @_inlineable
  public var endIndex: Base.Index { return _base.endIndex }

  @_inlineable
  public func index(after i: Index) -> Index { return _base.index(after: i) }
  @_inlineable
  public func formIndex(after i: inout Index) { _base.formIndex(after: &i) }

  /// Accesses the element at `position`.
  ///
  /// - Precondition: `position` is a valid position in `self` and
  ///   `position != endIndex`.
  @_inlineable
  public subscript(position: Base.Index) -> Element {
    return _transform(_base[position])
  }

  @_inlineable
  public subscript(bounds: Range<Base.Index>) -> SubSequence {
    return SubSequence(_base: _base[bounds], transform: _transform)
  }

  @_inlineable
  public var indices: Indices {
    return _base.indices
  }

  /// A Boolean value indicating whether the collection is empty.
  @_inlineable
  public var isEmpty: Bool { return _base.isEmpty }

  /// The number of elements in the collection.
  ///
  /// To check whether the collection is empty, use its `isEmpty` property
  /// instead of comparing `count` to zero. Unless the collection guarantees
  /// random-access performance, calculating `count` can be an O(*n*)
  /// operation.
  ///
  /// - Complexity: O(1) if `Index` conforms to `RandomAccessIndex`; O(*n*)
  ///   otherwise.
  @_inlineable
  public var count: Int {
    return _base.count
  }

  @_inlineable
  public var first: Element? { return _base.first.map(_transform) }

  @_inlineable
  public func index(_ i: Index, offsetBy n: Int) -> Index {
    return _base.index(i, offsetBy: n)
  }

  @_inlineable
  public func index(
    _ i: Index, offsetBy n: Int, limitedBy limit: Index
  ) -> Index? {
    return _base.index(i, offsetBy: n, limitedBy: limit)
  }

  @_inlineable
  public func distance(from start: Index, to end: Index) -> Int {
    return _base.distance(from: start, to: end)
  }
}

extension LazyMap: BidirectionalCollection
where Base: BidirectionalCollection {

  /// A value less than or equal to the number of elements in the collection.
  ///
  /// - Complexity: O(1) if the collection conforms to
  ///   `RandomAccessCollection`; otherwise, O(*n*), where *n* is the length
  ///   of the collection.
  @_inlineable
  public func index(before i: Index) -> Index { return _base.index(before: i) }

  @_inlineable
  public func formIndex(before i: inout Index) {
    _base.formIndex(before: &i)
  }

  @_inlineable
  public var last: Element? { return _base.last.map(_transform) }
}

extension LazyMap: RandomAccessCollection
where Base: RandomAccessCollection { }

//===--- Support for s.lazy -----------------------------------------------===//

extension LazySequenceProtocol {
  /// Returns a `LazyMapSequence` over this `Sequence`.  The elements of
  /// the result are computed lazily, each time they are read, by
  /// calling `transform` function on a base element.
  @_inlineable
  public func map<U>(
    _ transform: @escaping (Elements.Element) -> U
  ) -> LazyMap<Self.Elements, U> {
    return LazyMap(_base: self.elements, transform: transform)
  }
}

extension LazyCollectionProtocol {
  /// Returns a `LazyMapCollection` over this `Collection`.  The elements of
  /// the result are computed lazily, each time they are read, by
  /// calling `transform` function on a base element.
  @_inlineable
  public func map<U>(
    _ transform: @escaping (Elements.Element) -> U
  ) -> LazyMap<Self.Elements, U> {
    return LazyMap(_base: self.elements, transform: transform)
  }
}

extension LazyMap {
  // This overload is needed to re-enable Swift 3 source compatibility related
  // to a bugfix in ranking behavior of the constraint solver.
#if false
  @available(swift, obsoleted: 4.0)
  public static func + <
    Other : LazyCollectionProtocol
  >(lhs: LazyMap, rhs: Other) -> [Element]
  where Other.Element == Element {
    var result: [Element] = []
    result.reserveCapacity(numericCast(lhs.count + rhs.count))
    result.append(contentsOf: lhs)
    result.append(contentsOf: rhs)
    return result
  }
#endif
}

extension LazyMap {
  @_inlineable
  @available(swift, introduced: 5)
  public func map<ElementOfResult>(
    _ transform: @escaping (Element) -> ElementOfResult
  ) -> LazyMap<Base, ElementOfResult> {
    return LazyMap<Base, ElementOfResult>(
      _base: _base,
      transform: {transform(self._transform($0))})
  }
}

// @available(*, deprecated, renamed: "LazyMapSequence.Iterator")
public typealias LazyMapIterator<T, E> = LazyMapSequence<T, E>.Iterator where T: Sequence
@available(*, deprecated, renamed: "LazyMap")
public typealias LazyMapSequence<T, E> = LazyMap<T, E> where T: Sequence
@available(*, deprecated, renamed: "LazyMap")
public typealias LazyMapCollection<T, E> = LazyMap<T, E> where T: Collection
@available(*, deprecated, renamed: "LazyMap")
public typealias LazyMapBidirectionalCollection<T, E> = LazyMapCollection<T, E> where T : BidirectionalCollection
@available(*, deprecated, renamed: "LazyMap")
public typealias LazyMapRandomAccessCollection<T, E> = LazyMapCollection<T, E> where T : RandomAccessCollection
