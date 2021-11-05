# any-pointer type erasure

This package provides a single file `any-pointer.zig` that implements a type-erased pointer for Zig.

This pointer type supports three functions `make`, `cast` and `isNull` and exports the symbol `null_pointer`.

```zig
const AnyPointer = @import("any-pointer").AnyPointer;

var i: u32 = 0;

const erased = AnyPointer.make(*u32, &i);

const ptr = erased.cast(*u32);

ptr.* = 42;

std.debug.assert(!ptr.isNull());
std.debug.assert(i == 42);
```

In safe modes (`Debug` and `ReleaseSafe`) `cast` will type-check the pointer and might `@panic` when a type confusion would happen.

## Usage

Just add a package pointing to `any-pointer.zig` to your project.

The package will export three types:

- `SafePointer`, which will provide type checking and panics in safe modes.
- `UnsafePointer`, which will not provide type checking and will only have the size of a single pointer.
- `AnyPointer`, which will be `SafePointer` in safe modes and `UnsafePointer` in unsafe modes.

In addition to `make`, `cast` and `isNull`, `SafePointer` also has the function `tryCast` which works like `cast`, but will return an optional.
