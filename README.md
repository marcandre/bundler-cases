# bundler-cases
Simple integration tests for Bundler.

bundler-cases provides a simple framework to describe various test scenarios with Bundler. 

These are inspired by and similar to Bundler specs, but the Bundler codebase is a bit
large, and the goal of this repo is to be a smaller/simpler tool for non-Bundler
devs to work and communicate with.

The first case defined re-creates the [Conservative Updating](http://bundler.io/v1.12/man/bundle-install.1.html#CONSERVATIVE-UPDATING) scenario in the `bundle install` docs.
