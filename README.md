# Markdown Babel

A Markdown toolchain for literate programming and to make your documents executable.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

  - [Examples](#examples)
  - [Demo](#demo)
  - [Usage](#usage)
    - [Execute Block](#execute-block)
    - [Configuration](#configuration)
      - [Configuration File](#configuration-file)
    - [Select Executable Context](#select-executable-context)

<!-- markdown-toc end -->

## Examples

[See the examples file](Examples.md) to learn how to configure various evaluators to 

- 🖼 generate graphs, 
- 🌍 do HTTP requests, 
- 🤖 and run scripts.

## Demo

We'll 'execute' the code block in [`test.txt`](test.txt) that shells out to `date` (around [line 7](https://github.com/md-babel/swift-markdown-babel/blob/main/test.txt#L6), with 1-based counting), using the [`config.json`](config.json) that instructs `md-babel` how to interpret `sh` code blocks.

Clone the repository; 

    $ git clone https://github.com/md-babel/swift-markdown-babel.git
    $ cd swift-markdown-babel

-   **From source:** Use `swift run` to compile from source and then use the program.

    > [!NOTE]  
    > Why `2>/dev/null`? Because 'quiet' Swift still produces output, but routes it to standard error.

    ```sh
    swift run --quiet md-babel exec --file test.txt --line 7 --column 1 --config config.json  2>/dev/null
    ```

-   **From pre-built binary:** Download a [tagged release](https://github.com/md-babel/swift-markdown-babel/releases), then run `md-babel` directly (without the "`swift run --quiet`" part).

    ```sh
    ./md-babel exec --file test.txt --line 7 --column 1 --config config.json
    ```

The result will contain metadata that specifies the affected range in the document, but the interesting part is this:

```json
{
  ...,
  "replacementString" : "```sh\ndate\n```\n\n<!--Result:-->\n```\nFri Apr 11 13:00:28 CEST 2025```",
  "result" : "Fri Apr 11 13:00:28 CEST 2025"
}
```

-   Editor applications can use `"replacementString"` to modify the document directly, turning Markdown documents into executable notebooks.

    Check out the [md-babel GitHub organization's repositories](https://github.com/md-babel) to see whether your favorite editor has an integration!

-   Other applications can use the plain output from `"result"`.


## Usage

The `md-babel` program implements [the schema](https://github.com/md-babel/md-babel-schema) so that you can run your code from the command-line (very cumbersome) or an editor plugin (very convenient).

In any case, all calls are routed through `md-babel` as your executable Markdown hub.


### Execute Block

    Usage: md-babel execute [--file <file>] --line <line> --column <column> [--dir </path/to/project>] [--config <config>] [--no-load-user-config]

1.  Grab the the code block from `<file>` (or standard input) at/around `<line>:<column>` (starting at 1, not 0, to meet CommonMark standards), 
2.  execute it in its context,
3.  and produce a [md-babel:execute-block:response][execute-block-schema]-formatted JSON to stdandard output.

    Client editors can then process the resulting JSON response to insert the result of the code block. 
    See for [a reference implementation in Emacs][md-babel.el] or [the Visual Studio Code plugin][vscode].
    
Other options:

-   The `--no-load-user-config` flag determines whether the [global configuration file](#configuration-file) should be used.
    If you toggle this but then don't pass a `--config` file path to use instead, no code block evaluators will be known.
-   The optional `--config` argument loads a configuration file that is merged with the user's global configuration by default. 
    If you combine this with `--no-load-user-config`, only the config file you pass here will be used.
-   The optional `--dir` can be used to resolve relative build product paths from code blocks, including images.
    Editors set this to the project or workspace directory to put assets in a common folder.
    The default (unset) uses temporary directories.
  
    The effective evaluator configuration should _not_ use absolute output `"directory"` keys for relative paths to work. 
    Leaving the `"directory"` key out completely will put images in the project root; 
    using relative directives like `"directory": "./assets"` will put them in a shared subdirectory.
-   The `--no-relative-paths` flag forces e.g. image literals to always use absolute paths. 
    By default, relative paths will be preferred. 
    Relative paths are based on the `--dir` argument, if present, falling back to the dirname of `--file`, if present. 
    Without both, paths are resolved against the default temporary directory.

Examples for image output and the literal inserted into your document:

- ```
  Given arguments            : --file /home/you/test.md
  and evaluator directory    : "./assets"
  Then creates image at path : /tmp/assets/image.png
  and literal output         : ![](/tmp/assets/image.png)
  ```
- ```
  Given arguments            : --file /home/you/test.md --dir /home/you
  and evaluator directory    : "./assets"
  Then creates image at path : /home/you/assets/image.png
  and literal output         : ![](assets/image.png)
  ```
- ```
  Given arguments            : --file /home/you/test.md --dir /home/you --no-relative-paths
  and evaluator directory    : "./assets"
  Then creates image at path : /home/you/assets/image.png
  and literal output         : ![](/home/you/assets/image.png)
  ```

[execute-block-schema]: https://github.com/md-babel/md-babel-schema/tree/main/execute-block
[md-babel.el]: https://github.com/md-babel/md-babel.el
[vscode]: https://github.com/md-babel/vscode-md-babel

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

Here's a simple example for shell scripts and Python:

```json
{
  "evaluators": {
    "codeBlock" : {
      "sh": {
        "path": "/usr/bin/env",
        "defaultArguments": ["sh"]
      },
      "bash": {
        "path": "/usr/bin/env",
        "defaultArguments": ["bash"]
      },
      "python": {
        "path": "/usr/bin/env",
        "defaultArguments": ["python3"]
      }
    }
  }
}
```

If you can rely on `/usr/bin/env`, like with hash-bangs, you can set and forget it. 
(With pyenv, rbenv, asdf, ... your mileage may vary!)

[See the examples file](Examples.md) to learn how to configure various evaluators.

[config-schema]: https://github.com/md-babel/md-babel-schema/tree/main/config


### Select Executable Context

    Usage: md-babel select [--file <file>] --line <line> --column <column>

From `<file>`, with the point at `<line>:<column>` (starting at 1, not 0, to meet CommonMark standards), produces a [md-babel:select-block:response][select-block-schema]-formatted JSON to stdandard output. 
Client editors can process this to inspect `md-babel` components.

[select-block-schema]: https://github.com/md-babel/md-babel-schema/tree/main/select-block

<!-- 
Local Variables:
markdown-toc-user-toc-structure-manipulation-fn: cdr
End:
-->
