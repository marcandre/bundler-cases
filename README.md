# bundler-arena
DSL for writing up integration tests for Bundler

need a way to only focus on dependency cases, like we do in the unit tests, but that's
not easily accessible by users.

they need a way to mock up a Gemfile and lockfile with fake gem names, and then have 
Bundler actually do the resolution 

unit tests have all these mechanisms, but they have to clone the whole damn thing and
it's this big mess.

...


...

Gemfile
Gemfile.lock
Gemfile.edit
execute.sh
Gemfile.expected
Gemfile.lock.expected

Stashing this all in local files won't be as readable at all one shot. 

Building out BundlerFixture to move in a bunch of their builders will still be a bit of ruby code to code up.

A cucumber-y type Given When in a simple DSL might be the best compromise.


the cucumber-y though is going to need to implement BundlerFixture crap anyway. What bundler-patch has as integration tests is already in the right direction. It just needs more and more refinement to make it simpler for folks to just jump in with.

Then there's executing them. Put it all inside a big case block. `BundlerTest.case do ... end`
