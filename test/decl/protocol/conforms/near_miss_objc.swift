// RUN: %target-parse-verify-swift

// Test "near misses" where a member of a class or extension thereof
// nearly matches an optional requirement, but does not exactly match.

@objc protocol P1 {
  @objc optional func doSomething(a: Int, b: Double) // expected-note 2{{requirement 'doSomething(a:b:)' declared here}}
}

class C1a : P1 {
  @objc func doSomething(a: Int, c: Double) { }
  // expected-warning@-1{{instance method 'doSomething(a:c:)' nearly matches optional requirement 'doSomething(a:b:)' of protocol 'P1'}}
  // expected-note@-2{{rename to 'doSomething(a:b:)' to satisfy this requirement}}{{34-34=b }}{{8-8=(doSomethingWithA:b:)}}
  // expected-note@-3{{move 'doSomething(a:c:)' to an extension to silence this warning}}
  // expected-note@-4{{make 'doSomething(a:c:)' private to silence this warning}}{{9-9=private }}
}

class C1b : P1 {
}

extension C1b {
  @objc func doSomething(a: Int, c: Double) { } // don't warn
}

class C1c {
}

extension C1c : P1 {
  func doSomething(a: Int, c: Double) { }
  // expected-warning@-1{{instance method 'doSomething(a:c:)' nearly matches optional requirement 'doSomething(a:b:)' of protocol 'P1'}}
  // expected-note@-2{{rename to 'doSomething(a:b:)' to satisfy this requirement}}{{28-28=b }}{{3-3=@objc(doSomethingWithA:b:) }}
  // expected-note@-3{{move 'doSomething(a:c:)' to another extension to silence this warning}}
  // expected-note@-4{{make 'doSomething(a:c:)' private to silence this warning}}{{3-3=private }}
}

class C1d : P1 {
  @objc private func doSomething(a: Int, c: Double) { } // don't warn
}

class C1e : P1 {
  @nonobjc func doSomething(a: Int, c: Double) { } // don't warn
}

// Don't try to match an optional requirement against a declaration
// that already satisfies one witness.
@objc protocol P2 {
  @objc optional func doSomething(a: Int, b: Double)
  @objc optional func doSomething(a: Int, d: Double)
}

class C2a : P2 {
  @objc func doSomething(a: Int, b: Double) { } // don't warn: this matches something
}

// Cope with base names that change.
@objc protocol P3 {
  @objc optional func doSomethingWithPriority(_ a: Int, d: Double) // expected-note{{requirement 'doSomethingWithPriority(_:d:)' declared here}}
}

class C3a : P3 {
  func doSomething(priority: Int, d: Double) { }
  // expected-warning@-1{{instance method 'doSomething(priority:d:)' nearly matches optional requirement 'doSomethingWithPriority(_:d:)' of protocol 'P3'}}
  // expected-note@-2{{rename to 'doSomethingWithPriority(_:d:)' to satisfy this requirement}}{{20-20=_ }}
  // expected-note@-3{{move 'doSomething(priority:d:)' to an extension to silence this warning}}
  // expected-note@-4{{make 'doSomething(priority:d:)' private to silence this warning}}{{3-3=private }}
}

@objc protocol P4 {
  @objc optional func doSomething(priority: Int, d: Double) // expected-note{{requirement 'doSomething(priority:d:)' declared here}}
}

class C4a : P4 {
  func doSomethingWithPriority(_ a: Int, d: Double) { }
  // expected-warning@-1{{instance method 'doSomethingWithPriority(_:d:)' nearly matches optional requirement 'doSomething(priority:d:)' of protocol 'P4'}}
  // expected-note@-2{{rename to 'doSomething(priority:d:)' to satisfy this requirement}}{{32-33=priority}}
  // expected-note@-3{{move 'doSomethingWithPriority(_:d:)' to an extension to silence this warning}}
  // expected-note@-4{{make 'doSomethingWithPriority(_:d:)' private to silence this warning}}{{3-3=private }}
}

@objc class SomeClass { }

@objc protocol P5 {
  @objc optional func methodWithInt(_: Int, forSomeClass: SomeClass, dividingDouble: Double)
  // expected-note@-1{{requirement 'methodWithInt(_:forSomeClass:dividingDouble:)' declared here}}
}

class C5a : P5 {
  func method(_: Int, for someClass: SomeClass, dividing double: Double) { }
  // expected-warning@-1{{instance method 'method(_:for:dividing:)' nearly matches optional requirement 'methodWithInt(_:forSomeClass:dividingDouble:)' of protocol 'P5'}}
  // expected-note@-2{{rename to 'methodWithInt(_:forSomeClass:dividingDouble:)' to satisfy this requirement}}{{3-3=@objc(methodWithInt:forSomeClass:dividingDouble:) }}{{8-14=methodWithInt}}{{23-26=forSomeClass}}{{49-57=dividingDouble}}
  // expected-note@-3{{move 'method(_:for:dividing:)' to an extension to silence this warning}}
  // expected-note@-4{{make 'method(_:for:dividing:)' private to silence this warning}}{{3-3=private }}
}

@objc protocol P6 {
  @objc optional func method(_: Int, for someClass: SomeClass, dividing double: Double)
  // expected-note@-1{{requirement 'method(_:for:dividing:)' declared here}}
}

class C6a : P6 {
  func methodWithInt(_: Int, forSomeClass: SomeClass, dividingDouble: Double) { }
  // expected-warning@-1{{instance method 'methodWithInt(_:forSomeClass:dividingDouble:)' nearly matches optional requirement 'method(_:for:dividing:)' of protocol 'P6'}}
  // expected-note@-2{{rename to 'method(_:for:dividing:)' to satisfy this requirement}}{{3-3=@objc(method:for:dividing:) }}{{8-21=method}}{{30-30=for }}{{55-55=dividing }}
  // expected-note@-3{{move 'methodWithInt(_:forSomeClass:dividingDouble:)' to an extension to silence this warning}}
  // expected-note@-4{{make 'methodWithInt(_:forSomeClass:dividingDouble:)' private to silence this warning}}{{3-3=private }}
}

// Use the first note to always describe why it didn't match.
@objc protocol P7 {
  @objc optional func method(foo: Float)
  // expected-note@-1{{requirement 'method(foo:)' declared here}}
}

class C7a : P7 {
  @objc func method(foo: Double) { }
  // expected-warning@-1{{instance method 'method(foo:)' nearly matches optional requirement 'method(foo:)' of protocol 'P7'}}
  // expected-note@-2{{candidate has non-matching type '(foo: Double) -> ()'}}
  // expected-note@-3{{move 'method(foo:)' to an extension to silence this warning}}
  // expected-note@-4{{make 'method(foo:)' private to silence this warning}}
}

