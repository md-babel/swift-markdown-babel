# Markdown Babel

A Markdown toolchain to make your documents executable.

## Executable

`md-babel` implements [the schema](https://github.com/md-babel/md-babel-schema):


### Execute Block

    Usage: md-babel execute [--file <file>] --line <line> --column <column>

1. Grab the the code block from `<file>` (or standard input) at/around `<line>:<column>` (starting at 1, not 0, to meet CommonMark standards), 
2. execute it in its context,
3. and produce a [md-babel:execute-block:response][execute-block-schema]-formatted JSON to stdandard output.

Client editors can then process this to insert the result of the code block. 
See [md-babel.el][] for an implementation in Emacs.

[execute-block-schema]: https://github.com/md-babel/md-babel-schema/tree/main/execute-block
[md-babel.el]: https://github.com/md-babel/md-babel.el


### Select Executable Context

    Usage: md-babel select [--file <file>] --line <line> --column <column>

From `<file>`, with the point at `<line>:<column>` (starting at 1, not 0, to meet CommonMark standards), produces a [md-babel:select-block:response][select-block-schema]-formatted JSON to stdandard output. 
Client editors can process this to inspect `md-babel` components.

[select-block-schema]: https://github.com/md-babel/md-babel-schema/tree/main/select-block


# License

