# Markdown Babel

A Markdown toolchain to make your documents executable.

## Executable

`md-babel` implements [the schema](https://github.com/md-babel/md-babel-schema):

### Select Executable Context

    Usage: md-babel select [--file <file>] --line <line> --column <column>

From `<file>`, with the point at `<line>:<column>` (starting at 1, not 0, to meet CommonMark standards), produces a [md-babel:select-block:response][select-block-schema]-formatted JSON to stdandard output. 
Client editors can process this to inspect `md-babel` components.

[select-block-schema]: https://github.com/md-babel/md-babel-schema/tree/main/select-block


# License

