# ATOOLS
## Multi-Functional SA-MP Helper & Lua Computer Science Modules (LABS 1-6)

This repository contains a comprehensive set of university/practical laboratory assignments (`LAB`), showcasing core computer science paradigms adapted for the **SA-MP (San Andreas Multiplayer)** Lua environment via **MoonLoader**.

The project ranges from low-level utilities (lazy generators, memoization with eviction policies, bidirectional priority queues) to a high-performance **mimgui** graphical user interface optimized using the core modules to handle complex gameplay features (ESP, WallHack, skeleton rendering) without performance drops.


Author: Benediuk Ruslan
---

## Project Structure

```
ATOOLS/
├── LAB-1/
│   ├── generators.lua
│   ├── iterator.lua
│   └── example.lua
├── LAB-3/
│   └── memoize.lua
├── LAB-4/
│   └── bipq.lua
├── LAB-5/
│   ├── async_filter.lua
│   └── demo.lua
├── LAB-6/
│   ├── stream.lua
│   └── demo.lua
└── main.lua
```

| File | Description |
|------|-------------|
| `LAB-1/generators.lua` | Closure-based factory state machines (Fibonacci, Pseudo-random, Round-Robin, Custom Counters) |
| `LAB-1/iterator.lua` | A time-bounded iterator wrapper that gathers processing statistics |
| `LAB-1/example.lua` | SA-MP execution script linking chat commands directly to live generator lifecycles |
| `LAB-3/memoize.lua` | A robust caching wrapper featuring customizable eviction strategies (`LRU`, `LFU`) and `TTL` expiration |
| `LAB-4/bipq.lua` | A Double-Ended (Bi-directional) Priority Queue tracking stable element entry order |
| `LAB-5/async_filter.lua` | Non-blocking array filtering using Lua coroutines, native implementation of Promises (`andThen`, `catch`), and Abort Tokens |
| `LAB-5/demo.lua` | Standalone console demonstration executing async operations on table benchmarks |
| `LAB-6/stream.lua` | A functional pipeline module for handling big datasets iteratively with extreme memory efficiency |
| `LAB-6/demo.lua` | Benchmarking pipelines on 10,000+ data records |
| `main.lua` | Entry point merging everything into a cohesive mimgui control panel |

---

## LAB-1 — Generators & Iterators

Implements generator factories maintaining their step state strictly within closed upvalues.

### generators.lua

| Function | Description |
|----------|-------------|
| `fibonacci()` | Yields the next number in the Fibonacci sequence endlessly |
| `random(min, max)` | Continuously yields random integers between min and max |
| `round_robin(list)` | Iterates over a given list indefinitely in a loop |
| `counter_generator(start, step)` | Yields an ever-increasing number from a given start value |
| `random_string(min_len, max_len)` | Yields random alphanumeric strings of variable length |

```lua
local G = require "LAB-1/generators"

local fib = G.fibonacci()
print(fib()) -- 0
print(fib()) -- 1
print(fib()) -- 1

local rr = G.round_robin({"A", "B", "C"})
print(rr()) -- A
print(rr()) -- B
print(rr()) -- C
print(rr()) -- A
```

### iterator.lua

**`timeout_iterator(iterator, timeout, callback)`** — consumes an iterator for a limited time.

| Argument | Type | Description |
|----------|------|-------------|
| `iterator` | function | Any generator from generators.lua |
| `timeout` | number | Duration in seconds |
| `callback(value, count, sum, avg, elapsed)` | function | Called for each value |

```lua
local iterator = require "LAB-1/iterator"
local G = require "LAB-1/generators"

iterator.timeout_iterator(G.fibonacci(), 2, function(value, count, sum, avg)
    print(string.format("val=%d | count=%d | avg=%.2f", value, count, avg))
end)
```

### In-game Chat Commands (example.lua)

| Command | Description |
|---------|-------------|
| `/gen-1` | Toggles live Fibonacci sequence generator |
| `/gen-2 [Min] [Max]` | Instantiates a continuous bounded pseudo-random engine |
| `/gen-3 [Words]` | Parses arguments into an endless Round-Robin rotation loop |
| `/gen-4 [Start] [Step]` | Registers an incremental arithmetic progression tracker |
| `/gen-5 [MinLen] [MaxLen]` | Continuously generates random alphanumeric strings |
| `/gen-6` | Loops endlessly through the days of the week |
| `/iter-1 [Seconds]` | Runs Fibonacci iterator for N seconds, prints first 10 values |
| `/iter-2 [Seconds]` | Runs Round-Robin days iterator for N seconds |
| `/iter-3 [Min] [Max] [Seconds]` | Runs Random number iterator for N seconds |

---

## LAB-3 — Memoization (`LAB-3/memoize.lua`)

Wraps expensive, deterministic calculations to prevent redundant execution cycles.

### Usage

```lua
local memoize = require "LAB-3/memoize"

local cached = memoize.new(myFunction, {
    max_size = 100,
    policy = "lru",
    ttl = 60
})

local result = cached(arg1, arg2)
cached.stats()
cached.clear()
```

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `max_size` | number | unlimited | Maximum number of cached entries |
| `policy` | string/function | `"lru"` | Eviction policy |
| `ttl` | number | none | Time-to-live in seconds |

### Eviction Policies

| Policy | Description |
|--------|-------------|
| `"lru"` | Least Recently Used — evicts elements not accessed for the longest duration |
| `"lfu"` | Least Frequently Used — evicts elements with the lowest hit counter |
| `"ttl"` | Purges entries that cross a lifespan window in seconds |
| `function` | Custom eviction function `function(cache, meta)` |

### Methods

| Method | Description |
|--------|-------------|
| `cached(...)` | Call memoized function |
| `cached.stats()` | Returns `{size, hits, misses, policy, max_size, ttl}` |
| `cached.clear()` | Clears all cached entries |

### Production Use Case

Applied in `main.lua` to FFI bone coordinate lookups (`getbonePosition` at `0x5E4280`) and 3D space projections (`convert3DCoordsToScreen`) to guarantee stable 60+ FPS rendering.

---

## LAB-4 — Bi-Directional Priority Queue (`LAB-4/bipq.lua`)

A double-ended queue structure enabling retrieval across 4 distinct dimensions.

### Usage

```lua
local bipq = require "LAB-4/bipq"

local pq = bipq.new()
pq:enqueue("low", 1)
pq:enqueue("high", 10)
pq:enqueue("mid", 5)

pq:peek("highest")    -- high, 10
pq:peek("lowest")     -- low, 1
pq:peek("oldest")     -- low (first inserted)
pq:peek("newest")     -- mid (last inserted)

pq:dequeue("highest") -- removes and returns high
pq:size()             -- 2
pq:isEmpty()          -- false
```

### Methods

| Method | Description |
|--------|-------------|
| `enqueue(item, priority)` | Insert element with priority |
| `peek(mode)` | View element without removing |
| `dequeue(mode)` | Remove and return element |
| `size()` | Number of elements |
| `isEmpty()` | Returns true if empty |

### Modes

| Mode | Description | Complexity |
|------|-------------|------------|
| `"highest"` | Highest priority element | O(n) |
| `"lowest"` | Lowest priority element | O(n) |
| `"oldest"` | First inserted element | O(1) |
| `"newest"` | Last inserted element | O(1) |

### Production Use Case

Used in `main.lua` to sort the ESP render queue by player distance — nearest players are rendered first.

---

## LAB-5 — Async Filter (`LAB-5/async_filter.lua`)

Non-blocking array filtering using Lua coroutines. Avoids system thread freezes by splitting processing tasks across progressive execution cycles.

### Usage

**Synchronous**
```lua
local result = async_filter.filter(arr, function(x) return x > 5 end)
```

**Callback-based**
```lua
async_filter.filterCallback(arr, predicate, function(err, result)
    if err then print("Error:", err) return end
    -- use result
end)
```

**Promise-like**
```lua
async_filter.filterPromise(arr, predicate)
    :andThen(function(result)
        -- use result
    end)
    :catch(function(err)
        print("Error:", err)
    end)
```

**With AbortToken**
```lua
local token = async_filter.newAbortToken()
token:abort()

async_filter.filterPromise(arr, predicate, token)
    :andThen(function(result) end)
    :catch(function(err)
        if err == "aborted" then print("Cancelled") end
    end)
```

### Methods

| Method | Description |
|--------|-------------|
| `filter(arr, predicate)` | Synchronous filter |
| `filterCallback(arr, predicate, callback, token?)` | Callback-based async filter |
| `filterPromise(arr, predicate, token?)` | Promise-based async filter |
| `newAbortToken()` | Creates cancellation token |

---

## LAB-6 — Lazy Evaluation Streams (`LAB-6/stream.lua`)

Builds complex operational pipelines over collections or infinite generator functions. Iterations are computed strictly on-demand, bypassing intermediate table caching allocations.

### Usage

```lua
local stream = require "LAB-6/stream"

local result = stream.collect(
    stream.take(
        stream.map(
            stream.filter(
                stream.from(bigData),
                function(p) return p.hp < 50 end
            ),
            function(p) return p.name .. " | HP:" .. p.hp end
        ),
        5
    )
)
```

**Infinite stream**
```lua
local function counter()
    local n = 0
    return function()
        n = n + 1
        return n
    end
end

local first10even = stream.collect(
    stream.take(
        stream.filter(
            stream.from(counter()),
            function(n) return n % 2 == 0 end
        ),
        10
    )
)
```

### Methods

| Method | Description |
|--------|-------------|
| `from(source)` | Create stream from table or generator function |
| `map(s, fn)` | Transform each element lazily |
| `filter(s, predicate, token?)` | Filter elements by condition |
| `take(s, n)` | Take first n elements |
| `skip(s, n)` | Skip first n elements |
| `forEach(s, fn, token?)` | Consume stream with callback |
| `collect(s)` | Collect remaining elements into table |
| `next(s)` | Get next single element |

### Production Use Case

Used in `main.lua` via `statsStream()` to process daily activity logs incrementally without loading the full dataset into memory.

---

## main.lua — Integrated SA-MP Script

The entry point merging all modules into a cohesive **mimgui** control panel with FontAwesome 6 icons and local JSON configuration.

### Visual ESP Features

| Feature | Description |
|---------|-------------|
| Skeleton (Bones) | Live 3D bone overlay with distance clipping, thickness, and color modes |
| Bone Ends | Geometric markers on joints (Square, Circle, Triangle, Pentagon) with scale and rotation |
| Tracing Lines | Lines projecting toward players with color synchronization |
| Name Tags | Extended nickname visibility across dense environments |
| Analytics Dashboard | Tracks server events (Kicks, Mutes, Jails, Warns) via timeapi.io |

### In-game Commands

| Command | Description |
|---------|-------------|
| `/cc` | Toggle control panel |
| `/save-cfg` | Save current settings |
| `/clear-cfg` | Reset settings to default |
| `/stats-warn` | Show days with warns via stream filter |
| `/stats-top` | Show top 3 days by PM activity |
| `/stats-filter` | Filter statistics by activity |
| `/mstats` | Show memoization cache statistics |

---

## Dependencies

| Dependency | Description |
|------------|-------------|
| MoonLoader v0.26+ | Lua script loader for GTA SA |
| mimgui | Modern Dear ImGui wrapper for GTA SA |
| fAwesome6 | FontAwesome 6 embedded typefaces |
| LuaSAMP-API | SA-MP chat, commands, and player packet registers |
| requests | HTTP client for web connections |
| json | JSON encode/decode |
| memory | Direct memory read/write |
| carbjsonconfig | JSON-based config persistence |

---

## Installation

Copy the contents of the repository into your `moonloader/` directory:

```
GTA San Andreas/
└── moonloader/
    ├── LAB-1/
    ├── LAB-3/
    ├── LAB-4/
    ├── LAB-5/
    ├── LAB-6/
    └── main.lua
```

---

## License

MIT