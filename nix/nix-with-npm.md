Source: https://matthewrhone.dev/nixos-npm-globally

Since the nix store is immutable and cannot be modified, you need to define a writable location for NPM packages to be installed globally.

Install NodeJS if you haven’t already.

Add the following to your ~/.npmrc to have it put the packages in the ~/.npm-packages folder:
```
prefix = ${HOME}/.npm-packages
```

You need to add the npm bin folder to your PATH in your shell’s rc file (i.e. .bashrc or .zshrc for example, so you can access the executables:
```
export PATH=~/.npm-packages/bin:$PATH
```

You also need to add the NODE_PATH to the same file:

```
export NODE_PATH=~/.npm-packages/lib/node_modules
```
Doing a source ./zshrc will allow you to not have to reload your terminal session (assuming you are using zsh for your shell, change to whatever you are using).

In the `shell.nix`
```
 shellHook = ''
      export PATH=$PATH:~/.npm-packages/bin
      export NODE_PATH=~/.npm-packages/lib/node_modules
      '';
```
