# ADADT : API-Derived Algebraic Data Types

ADADT is an *API-Derived Algebraic Data Type*.  This type is a common [Algebraic
Data Type](https://en.wikipedia.org/wiki/Algebraic_data_type) that is boudn to
field and method return types.  In essence, they describe and define every type
that can be emitted by a public member of a given class.


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


It's possible to add additional state this way, and have more
control over the name, metadata, and documentation of the resulting type.


ADADT types are useful in a few situations, such as determining the result of a
routing request.  See [golgi](https://github.com/jdonaldson/golgi) for an
example of use.







