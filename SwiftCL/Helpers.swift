//
//  Helpers.swift
//  ReceiptRecognizer
//
//  Created by Lukasz Kwoska on 28/11/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation

// Given sequence of 2-tuples, return two arrays
func unzip<T, U>(sequence: SequenceOf<(T, U)>) -> ([T], [U]) {
  var t = Array<T>()
  var u = Array<U>()
  for (a, b) in sequence {
    t.append(a)
    u.append(b)
  }
  return (t, u)
}

/**
Convert an array to a dictionary using tranformer.

:param: array     Array to convert
:param: transform Transformer function

:returns: Dictionary representation of the array.
*/
public func toDictionary<K, V, E> (array:[E], transform:(E) -> (K, V)?) -> [K: V] {
  var dict = [K: V]()
  
  for entry in array {
    if let (key, value) = transform(entry) {
      dict[key] = value
    }
  }
  return dict
}

func withResolvedPointers<A,B,C,R>(a:[A]?, b:[B]?, c:[C]?, handler:(UnsafePointer<A>, UnsafePointer<B>, UnsafePointer<C>) -> R) -> R {
  switch (a,b,c) {
  case (.None, .None, .None):
    return handler(nil, nil, nil)
  case (.None, .None, .Some (let c)):
    return handler(nil, nil, c)
  case (.None, .Some(let b), .None):
    return handler(nil, b, nil)
  case (.None, .Some(let b), .Some(let c)):
    return handler(nil, b, c)

  case (.Some(let a), .None, .None):
    return handler(a, nil, nil)
  case (.Some(let a), .None, .Some (let c)):
    return handler(a, nil, c)
  case (.Some(let a), .Some(let b), .None):
    return handler(a, b, nil)
  case (.Some(let a), .Some(let b), .Some(let c)):
    return handler(a, b, c)
  }
}

func withResolvedPointers<A,B,R>(a:[A]?, b:[B]?, handler:(UnsafePointer<A>, UnsafePointer<B>) -> R) -> R {
  switch (a,b) {
  case (.None, .None):
    return handler(nil, nil)
  case (.None, .Some (let b)):
    return handler(nil, b)
  case (.Some(let a), .None):
    return handler(a, nil)
  case (.Some(let a), .Some(let b)):
    return handler(a, b)
  }
}

func withResolvedPointer<A,R>(a:[A]?, handler:(UnsafePointer<A>) -> R) -> R {
  switch a {
  case .None:
    return handler(nil)
  case .Some (let b):
    return handler(b)
  }
}

func curry<A,B,C,D,E,F,G,H,I,R>(fun:(a:A, b:B, c:C, d:D, e:E, f:F, g:G, h:H, i:I) -> R) -> A->B->C->D->E->F->G->H->I->R {
  return
    {a in
      {b in
        {c in
          {d in
            {e in
              {f in
                {g in
                  {h in
                    {i in
                      fun(a: a, b: b, c: c, d: d, e: e, f: f, g: g, h: h, i: i)
                    }
                  }
                }
              }
            }
          }
        }
      }
  }
}
