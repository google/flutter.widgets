Contributing to Flutter Widgets
===============================

_See also: [Flutter's code of conduct](https://flutter.io/design-principles/#code-of-conduct)_

Things you will need
--------------------

 * Linux, Mac OS X, or Windows.
 * git (used for source version control).
 * An ssh client (used to authenticate with GitHub).

Getting the code and configuring your environment
-------------------------------------------------

 * Ensure all the dependencies described in the previous section are installed.
 * Fork `https://github.com/google/flutter.widgets` into your own GitHub account.
   If you already have a fork and are now installing a development environment on
   a new machine, make sure you've updated your fork so that you don't use stale
   configuration options from long ago.
 * If you haven't configured your machine with an SSH key that's known to github, then
   follow [GitHub's directions](https://help.github.com/articles/generating-ssh-keys/)
   to generate an SSH key.
 * `git clone git@github.com:<your_name_here>/flutter.widgets.git`
 * `cd widgets`
 * `git remote add upstream git@github.com:google/flutter.widgets.git`
   (So that you fetch from the master repository, not your clone, when running
   `git fetch` et al.)

Contributing code
-----------------

We gladly accept contributions via GitHub pull requests.

Please peruse Flutter's
[style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) and
[design principles](https://flutter.io/design-principles/) before
working on anything non-trivial. These guidelines are intended to
keep the code consistent and avoid common pitfalls.

You must complete the
[Contributor License Agreement](https://cla.developers.google.com/clas). You can
do this online, and it takes only a minute. If you've never submitted code
before, you must add your (or your organization's) name and contact info to the
[AUTHORS](AUTHORS) file.

To start working on a patch:

 * `git fetch upstream`
 * `git checkout upstream/master -b <name_of_your_branch>`
 * Hack away.
 * `git commit -a -m "<your informative commit message>"`
 * `git push origin <name_of_your_branch>`

To send us a pull request:

* `git pull-request` (if you are using [Hub](http://github.com/github/hub/)) or
  go to `https://github.com/google/flutter.widgets` and click the
  "Compare & pull request" button

Please make sure all your checkins have detailed commit messages explaining 
what the patch does and *why*. **Changes to code behavior should include unit
tests** that would fail without the change.

Once you've gotten an LGTM from a project maintainer and once your PR has
received the green light from all our automated testing (Travis, Appveyor, etc),
one of the project maintainers will test the changes to our internal repo. This
might cause test failures that need to be debugged internally so we might make
further suggestions on your PR.
