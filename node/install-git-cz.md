# How to install Commitizen
```bash
$ npm install -g commitizen
```

#### Conventional commit messages as a global utility

Install `commitizen` globally, if you have not already.

```
npm install -g commitizen
```

Install your preferred `commitizen` adapter globally, for example [`cz-conventional-changelog`](https://www.npmjs.com/package/cz-conventional-changelog)

```
npm install -g cz-conventional-changelog
```

Create a `.czrc` file in your `home` directory, with `path` referring to the preferred, globally installed, `commitizen` adapter

```
echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc
```
