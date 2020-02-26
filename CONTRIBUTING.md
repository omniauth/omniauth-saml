# Contributing


## Workflow

We are using the [Feature Branch Workflow (also known as GitHub Flow)](https://guides.github.com/introduction/flow/),
and prefer delivery as pull requests.

Our first line of defense is the [Travis CI](https://travis-ci.org/omniauth/omniauth-saml) build defined within [.travis.yml](.travis.yml) and triggered for every pull request.

Create a feature branch:

```sh
git checkout -B feat/contributing
```

## Git Commit

The cardinal rule for creating good commits is to ensure there is only one
"logical change" per commit. Why is this an important rule?

*   The smaller the amount of code being changed, the quicker & easier it is to
    review & identify potential flaws.

*   If a change is found to be flawed later, it may be necessary to revert the
    broken commit. This is much easier to do if there are not other unrelated
    code changes entangled with the original commit.

*   When troubleshooting problems using Git's bisect capability, small well
    defined changes will aid in isolating exactly where the code problem was
    introduced.

*   When browsing history using Git annotate/blame, small well defined changes
    also aid in isolating exactly where & why a piece of code came from.

Things to avoid when creating commits

*   Mixing whitespace changes with functional code changes.
*   Mixing two unrelated functional changes.
*   Sending large new features in a single giant commit.

## Git Commit Conventions

We use git commit as per [Conventional Changelog](https://github.com/ajoslin/conventional-changelog):

```none
<type>(<scope>): <subject>
```

Allowed types:

*   **feat**: A new feature
*   **fix**: A bug fix
*   **docs**: Documentation only changes
*   **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, newline, line endings, etc)
*   **refactor**: A code change that neither fixes a bug or adds a feature
*   **perf**: A code change that improves performance
*   **test**: Adding missing tests
*   **chore**: Changes to the build process or auxiliary tools and libraries such as documentation generation

You can add additional details after a new line to describe the change in detail or automatically close a issue on Github.

```none
feat: create initial CONTRIBUTING.md

This closes #73
```

## Release process

Example for version `v1.7.0`

1. Bump the version in `lib/omniauth-saml/version.rb`
1. Update [CHANGELOG.md](CHANGELOG.md) with `bundle exec conventional-changelog version=v1.7.0 since_version=v1.6.0`
1. Commit all your changes
1. Tag the latest commit with `git tag v1.7.0`
1. Contact the maintainers
