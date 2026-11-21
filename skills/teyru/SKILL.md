---
name: teyru
description: Write, build, run and debug Teyru code (.teyru files, teyru.mod) with the teyru compiler. Use it when a task creates or changes Teyru code, fixes a TY- diagnostic, or asks what a Java-shaped program does after it is compiled to a native executable. Covers the toolchain loop, the diagnostics agents keep hitting, and the places the standard library differs from the JDK.
---

# Teyru with teyru

Teyru is a compiled language with Java's shape — classes, records, sealed interfaces, generics, lambdas, checked exceptions, `java.*` package names — that builds a native executable. There is no JVM, no bytecode, no JAR, and no JDK: the standard library is a reimplementation written in Teyru. Do not assume JDK semantics; run the compiler and read the diagnostic.

`teyru` is the whole toolchain: build, run, test, fmt, lsp, emit.

## The loop

1. Find the code with `rg` (`rg 'class NAME'`, `rg 'NAME\('`). There is no query command. `teyru emit-java FILE.teyru` prints the equivalent Java, which is the fastest way to see what the compiler thinks a construct means.
2. After editing, `teyru build -O0 -o /tmp/prog FILE.teyru` (or `teyru build ./...` for a module). Diagnostics print `path:line:col: error[TY-XXX-nnnn]: message`, then `teyru: parse errors` or `teyru: semantic errors`; exit 1. Fix the first error first.
3. `teyru run FILE.teyru -- arg1 arg2` compiles and runs. Exit codes: `0` ok, `1` diagnostic or uncaught exception, `2` a diagnostic raised by `teyru test`, `70` the program reached a named unimplemented operation (`teyru: no implementation for ...`).
4. `teyru fmt -w PATH` rewrites in place (2-space indent, spaces around operators). Formatting is idempotent and keeps comments. **`fmt` is not a syntax check**: it exits 0 on a file that does not parse, so build after it.
5. `teyru test PATH` runs `@Test` classes. Output is `PASS Class.method` / `FAIL Class.method: expected X, but was Y`, then `N passed, M failed`; exit 0/1/2. The package's own `main` is not called.
6. Uncaught exceptions print `Exception in thread "main" java.lang.X: message` on stderr, exit 1. Messages are Java's, including the helpful NullPointerException text.

Defaults: `teyru build` is `-O2` and writes `a.out`; `teyru run` is `-O0`. Pass `-O0` while iterating — it links a cached standard library instead of optimizing the whole program.

One entry point per build. When two classes declare `main`, the first one the build reaches wins silently; pass the file you mean, or give the class a unique main.

## Rules agents get wrong

Each block shows the diagnostic the compiler gives. The block after it compiles.

A statement ends at the newline. Semicolons are accepted (and `fmt` keeps them), but canonical style leaves them out. `return`, `throw` and `yield` take their value only from the same line.

```teyru error TY-SYN-0003
class Main {
  public static void main(String[] args) {
    throw
      new RuntimeException("boom")
  }
}
```

```teyru
class Main {
  public static void main(String[] args) {
    throw new RuntimeException("boom")
  }
}
```

A `return` with its value on the next line is a different error: `TY-TYP-0032: return value required`.

The `for` header separates its three parts with colons. The semicolon form is also accepted, but colons are the documented form.

```teyru
class Main {
  public static void main(String[] args) {
    for (int i = 0 : i < 3 : i++) {
      System.out.println(i)
    }
  }
}
```

Methods live in classes; there are no top-level functions and no local function declarations. A `static int f() {...}` written at file scope is not a declaration — calling `f()` is `TY-TYP-0076: cannot find method f()`.

`String` has `length()`, an array has `.length`:

```teyru error TY-TYP-0080
class Main {
  public static void main(String[] args) {
    System.out.println("abc".length)
  }
}
```

```teyru
class Main {
  public static void main(String[] args) {
    System.out.println("abc".length())
    int[] xs = {1, 2}
    System.out.println(xs.length)
  }
}
```

`String` `==` is reference equality, exactly as in Java. Literals are interned, so `"x" == "x"` is true; anything computed is not.

```teyru
class Main {
  public static void main(String[] args) {
    String a = "x"
    String b = new String("x")
    System.out.println(a == b)
    System.out.println(a.equals(b))
  }
}
```

`List.of(...)` and `Map.of(...)` are immutable: `add`/`put` throw `UnsupportedOperationException` at run time. Copy first.

```teyru
class Main {
  public static void main(String[] args) {
    var xs = new ArrayList<>(List.of(1, 2))
    xs.add(3)
    System.out.println(xs)
  }
}
```

A raw generic is a box of `Object`, not of the type you put in: `new ArrayList()` then `sum + x` is `TY-TYP-0064: operator '+' cannot be applied to int and Object`.

```teyru
class Main {
  public static void main(String[] args) {
    var xs = new ArrayList<Integer>()
    xs.add(1)
    xs.add(2)
    int sum = 0
    for (int x : xs) {
      sum = sum + x
    }
    System.out.println(sum)
  }
}
```

Type inference is weaker than javac's. A method reference inside a generic stream chain can fail with `TY-TYP-0095: cannot infer the type arguments of map(?)`; a lambda usually does not.

```teyru error TY-TYP-0095
class Main {
  public static void main(String[] args) {
    var xs = List.of("ab", "c")
    xs.stream().map(String::length).forEach(n -> System.out.println(n))
  }
}
```

```teyru
class Main {
  public static void main(String[] args) {
    var xs = List.of("ab", "c")
    xs.stream().map(s -> s.length()).forEach(n -> System.out.println(n))
  }
}
```

Checked exceptions are checked on your code (`TY-TYP-0122: unreported exception IOException; must be caught or declared to be thrown`). `try` without `catch`/`finally` is `TY-SYN-0108`.

```teyru
import java.io.IOException

class Main {
  static void fail() throws IOException {
    throw new IOException("io")
  }

  public static void main(String[] args) {
    try {
      fail()
    } catch (IOException e) {
      System.out.println(e.getMessage())
    }
  }
}
```

A switch **expression** must be exhaustive (`TY-TYP-0096`); a switch **statement** does not have to be. One switch cannot mix `->` and `:` labels (`TY-SYN-0110`).

```teyru error TY-TYP-0096
enum Color {
  RED, GREEN
}

class Main {
  public static void main(String[] args) {
    Color c = Color.RED
    int n = switch (c) {
      case RED -> 1
    }
    System.out.println(n)
  }
}
```

```teyru
enum Color {
  RED, GREEN
}

class Main {
  public static void main(String[] args) {
    Color c = Color.RED
    int n = switch (c) {
      case RED -> 1
      case GREEN -> 2
    }
    System.out.println(n)
  }
}
```

Enum constants and the member section are separated by a colon when there are members; `enum Color { RED, GREEN }` needs none.

A field followed by accessor blocks is a property. Inside the accessors the backing storage is `field` and the incoming value is `value`, not `this.field`.

```teyru
class Gauge {
  public int level {
    get {
      return field
    }
    set {
      field = value < 0 ? 0 : value > 100 ? 100 : value
    }
  }
}

class Main {
  public static void main(String[] args) {
    var g = new Gauge()
    g.level = -5
    System.out.println(g.level)
  }
}
```

`val` is an inferred-type final local: reassigning it is `TY-TYP-0057: cannot assign a value to final variable x`. Two locals of the same name in one block are `TY-TYP-0021`; a nested block may shadow.

Boxing identity follows Java only for `valueOf`/autoboxing. `new Integer(127) == Integer.valueOf(127)` is false even inside the cache.

```teyru
class Main {
  public static void main(String[] args) {
    System.out.println(Integer.valueOf(127) == Integer.valueOf(127))
    System.out.println(new Integer(127) == Integer.valueOf(127))
  }
}
```

Arrays print their identity, not their contents: `System.out.println(cs)` for `char[]` prints `char[]@...`, and `"" + cs` does the same (Java prints the characters). Use `String.valueOf(cs)` for `char[]` and `Arrays.toString(xs)` for the rest.

`String.format` implements `%s %d %f %x %c %n %%` and numeric flags such as `%05.2f`. `%t` is not implemented: it compiles and then stops with `teyru: no implementation for String.format: %t is not implemented`, exit 70.

A `native` method has no body, and the build fails at link time with `undefined symbol: tyn_Class_method` until you provide the C. `teyru build --native-header native.h program.teyru` writes the exact prototypes; add `--native impl.c`.

Code from other languages: `let` is `TY-TYP-0003: cannot find type let`, `===` and `=>` are `TY-SYN-0111: expected expression`, a backtick string is `TY-SYN-0002: unexpected character`, `console.log` is `TY-TYP-0048: cannot find symbol console`.

## Standard library

`java.lang`, `java.util`, `java.util.stream`, `java.util.regex`, `java.util.function`, `java.time`, `java.io`, `java.math`, `java.security` (MessageDigest), Gson (`com.google.gson.*`), `teyru.test`, plus a web server, HTTP client, WebSocket, JSON binding, validation, reflection and threads. The `java.*` prefixes are global: `List`, `Map`, `Optional`, `ArrayList`, `Arrays`, `Collections`, `Pattern` need no import. An `import` that names a package the library does not answer is `TY-TYP-0115`, not a warning.

Where it differs from the JDK, verified:

- Reflection reads annotation elements **by name** (`ann.stringValue("value")`), not `ann.value()`.
- `HashMap` iteration order matches JDK 21 below 64 buckets; bucket treeification is not implemented.
- `String.length()` is code units, storage is WTF-8, so `"中文".length()` is 2 and `getBytes().length` is 6.
- Threads cover `Thread`, `synchronized`, `wait`/`notify`, interrupts, daemon threads, `ThreadLocal` and virtual threads. Missing, as named methods: priorities, `ThreadGroup`, `join(long)`, `Thread.State`.
- Missing APIs fail loudly, never silently: `String.format` `%t` is the runtime stop above; `MessageDigest.getInstance("SHA3-256")` throws `NoSuchAlgorithmException`.

The library source is `lib/*.teyru` in the compiler repository; `teyru emit-java` is the faster oracle for a single construct.

## Tests

Tests are plain classes with annotated methods, in the same package as the code.

```teyru
import teyru.test.*

class CalculatorTest {
  @Test
  public void adds() {
    Assert.assertEquals(5, 2 + 3)
  }
}
```

`@BeforeEach`, `@AfterEach`, `@BeforeAll`, `@AfterAll` follow JUnit's shape. `Assert` has `assertEquals` for `Object`/`int`/`long`/`char`/`boolean`/`double`, `assertTrue`, `assertFalse`, `assertNull`, `assertNotNull`, `assertThrows(Class, Runnable)` and `fail(String)`.

## More

The language reference, the diagnostic table (one row per `TY-` code), modules (`teyru.mod`, `teyru get`, `teyru mod tidy`), native C interop and the toolchain are at <https://docs.teyru.dev/docs/language>, `/docs/diagnostics`, `/docs/modules`, `/docs/native` and `/docs/tooling`. Compiler source: <https://github.com/teyru-lang/Teyru>.
