# Leptos minimized example
This is a toy repo used for experimenting  with leptos with the goal to achive a minimized wasm distribution binary as possible.

### Sizes
* VanillaJs: `~148k`
* Wasm-Bindgen: `185.7k`
* Leptos (v2.5.0): `~248k` <---------
* React-hooks (v18.2.0): `~280k`

### How
The binary size can be minified in release mode by minimizing mangled function names for js/wasm glue code, as well as using nightly rust opting into a nightly feature that drops all panic messages from the binary. The caveat is that runtime errors from users will be cryptic since that data is lost, but the wasm binary size is almost a 40% overall improvement compared to the official leptos version.

## Required Tools
* rust nightly
* wasm-opt installed
* nodejs (for swc js-minimizer)

## Build minimized version
Build release version of frontend.

```
cargo build --release
```
The result is somewhat minimized but we can minimize it further (~10-15% improvement). So, go to target dir:
```
cd target/dist/js-framework-benchmark-leptos
```

This command will replace js/wasm glue code function names (in a hacky way) to minimized versions (requires wasm-opt):
```
../../../replace.sh index.js index.wasm
```

Install swc and minimize javascript one final time (requires node/npm)
```
npm install swc
npx swc index.js -C jsc.target=es2017 -C minify=true -C jsc.minify.compress=true -C jsc.minify.mangle=true -o index.js
```

Now, test your site with python http server (or similar):
```
python3 -m http.server 8080
```

The result should be ~`248k` of assets (total), where
- index.js is `8.4k`
- index.wasm is `99.8k`
- site.css is `122k` (why is this so big lol)
- font is `18k`

The official leptos version at https://krausest.github.io/js-framework-benchmark uses ~`324k`, so ~`248k` is a pretty big improvement. This is better than react hooks v18.2.0 which uses ~`280k` in total `\o/`

## Further improvements
There is still some paths from the build process in the wasm binary that seems unecessary. I havn't figured out how to drop them.

Some more optimizations regarding custom memory allocations could be done. This might however reduce memory or speed performance metrics which is bad.

## Unsolved Problems:
Running in debug mode with `cargo run` results in a broken "swap rows" implementation. This might just be problems with rust nightly, or it might be a real issue. Release build works fine though.