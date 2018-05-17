# ADADT : API-Derived Algebraic Data Types
[![Build Status](https://travis-ci.org/jdonaldson/adadt.svg?branch=master)](https://travis-ci.org/jdonaldson/adadt)

ADADT is an *API-Derived Algebraic Data Type*.  This type is a common [Algebraic
Data Type](https://en.wikipedia.org/wiki/Algebraic_data_type) that is bound to
field and method return types.  In essence, ADADTs describe and define every type
that can be emitted by a public member of an associated class.

To see an ADADT in action, it's necessary to define a simple example class:

```haxe
class Foo {
   public function bar() : String {
      return "HI";
   }
   public function baz() : Int {
      return 1;
   }
   public var bing : Float;
}
```

The ADADT class contains a
[@:genericBuild](https://haxe.org/manual/macro-generic-build.html) metadata
directive that constructs an enum from its type parameter.  You can specify the
class like so:

```haxe
import adadt.*;
//...
var some_var : ADADT<Foo>;
```

The `some_var` variable now is set to a type equivalent to:

```haxe
enum Foo_ADT {
   Bar(result : String);
   Baz(result : Int);
   Bing(result : Float);
}
```

Note that the resulting enum contains constructors equivalent to the (title
cased) methods and fields of Foo.

It's also possible to define ADADT through a `@:build` directive directly on an
enum definition:

```haxe
@:build(adadt.Build.build(Foo))
enum FooResult {
   AdditionalState;
}
```
This directive builds enum constructors on the given enum using the class type
of its argument.  The resulting enum behaves as if it were specified as :

```haxe
enum FooResult {
   Bar(result : String);
   Baz(result : Int);
   Bing(result : Float);
   AdditionalState;
}
```


It's possible to add additional states to an ADADT enum this way, and have more
control over the name, metadata, and documentation of the resulting type.

Finally, it's also possible to provide a separate alias for the `@:genericBuild`
class:

```haxe
@:genericBuild(adadt.Build.generic())
class Alias<T> {}

```

You can now generate an ADADT type def with :

```haxe
var t : Alias<Foo>;
```


ADADT types are useful when determining the outcome of a result matched against
an entire class API.  Examples include determining the result of a routing
request.  See [golgi](https://github.com/jdonaldson/golgi) for an example of
use.


