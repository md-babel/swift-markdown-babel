# Markdown Babel

A Markdown toolchain to make your documents executable.

    
## Usage

The `md-babel` program implements [the schema](https://github.com/md-babel/md-babel-schema) so that you can run your code from the command-line (very cumbersome) or an editor plugin (very convenient).

In any case, all calls are routed through `md-babel` as your executable Markdown hub.


### Execute Block

    Usage: md-babel execute [--file <file>] --line <line> --column <column> [--no-load-user-config] [--config <config>]

1. Grab the the code block from `<file>` (or standard input) at/around `<line>:<column>` (starting at 1, not 0, to meet CommonMark standards), 
2. execute it in its context,
3. and produce a [md-babel:execute-block:response][execute-block-schema]-formatted JSON to stdandard output.

The optional `--config` uses a separate environment configuration file that is merged with the user's global configuration.

Client editors can then process this to insert the result of the code block. 
See [md-babel.el][] for an implementation in Emacs.

[execute-block-schema]: https://github.com/md-babel/md-babel-schema/tree/main/execute-block
[md-babel.el]: https://github.com/md-babel/md-babel.el

### Configuration

    Usage: md-babel config dump [--no-load-user-config] [--config <config>]

Pretty-prints the JSON configuration as found in your global configuration file, merged with `<config>` (if you pass that).

#### Configuration File

- **Location:** `~/.config/md-babel/config.json`
- **Precedence:** Loaded first. Skip with `--no-load-user-config`.

Pass overrides to `md-babel execute` with the `--config` option.
Client applications can define their own block handlers this way.

The configuration file consists of key--object pairs.
The key is the code block language, and the object contains an absolute `"path"` to the program to run.
You can pass `"defaultArguments"` to influence how the program is executed.
See the [`md-babel:config` schema][config-schema] for details.

Here's a simple example for shell scripts:

```json
{
  "sh": {
    "path": "/usr/bin/env",
    "defaultArguments": ["sh"]
  },
  "bash": {
    "path": "/usr/bin/env",
    "defaultArguments": ["bash"]
  }
}
```

If you can rely on `/usr/bin/env`, like with hash-bangs, you can set and forget it. 
(With pyenv, rbenv, asdf, ... your mileage may vary!)

[config-schema]: https://github.com/md-babel/md-babel-schema/tree/main/config


### Select Executable Context

    Usage: md-babel select [--file <file>] --line <line> --column <column>

From `<file>`, with the point at `<line>:<column>` (starting at 1, not 0, to meet CommonMark standards), produces a [md-babel:select-block:response][select-block-schema]-formatted JSON to stdandard output. 
Client editors can process this to inspect `md-babel` components.

[select-block-schema]: https://github.com/md-babel/md-babel-schema/tree/main/select-block

