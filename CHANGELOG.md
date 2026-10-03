# Changelog

## 1.0.0

First release published on npm, as `@crepesourcing/happn`.

### Breaking changes

* The package is renamed `@crepesourcing/happn`: install it with `npm install --save @crepesourcing/happn` and require it with `require("@crepesourcing/happn")`.
* Node.js 24 or later is required.
* CoffeeScript 2 is used: `Happn`, `Projector` and the other classes are now native ES classes. Projectors must extend `Projector` with `class ... extends Projector` (in CoffeeScript or JavaScript); prototype-based inheritance (`util.inherits`, `Projector.call(this)`) is no longer supported.

### Changed

* Upgrade `amqplib` to `^2.2.0`.
* Ship precompiled JavaScript (`dist/`) built with `npm run build`: CoffeeScript is no longer compiled at runtime nor installed with the package. The deprecated `coffee-script` package is replaced with `coffeescript` (`^2.7.0`) as a development dependency.
* Remove the deprecated `q` dependency in favor of native Promises.

### Added

* Automated release: pushing a `vX.Y.Z` tag builds the package and publishes it to npm with provenance, through GitHub Actions.
