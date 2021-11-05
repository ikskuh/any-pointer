# any-pointer type erasure

This package provides a single file `any-pointer.zig` that implements a type-erased pointer for Zig.

This pointer type supports two functions `make` and `cast`.

```zig
const AnyPointer = @import("any-pointer").AnyPointer;

var i: u32 = 0;

const erased = AnyPointer.make(*u32, &i);

const ptr = erased.cast(*u32);

ptr.* = 42;

std.debug.assert(i == 42);
```

In safe modes (`Debug` and `ReleaseSafe`) `cast` will type-check the pointer and might `@panic` when a type confusion would happen.

## Usage

Just add a package pointing to `any-pointer.zig` to your project.
