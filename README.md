# Markdown Babel

A Markdown toolchain to make your documents executable.

## Executable

`md-babel` implements [the schema](https://github.com/md-babel/md-babel-schema):

### Select Executable Context

    Usage: md-babel select [--file <file>] --line <line> --column <column>

From `<file>`, with the point at `<line>:<column>` (starting at 1, not 0, to meet CommonMark standards), produces a [md-babel:select-block:response][select-block-schema]-formatted JSON to stdandard output. 
Client editors can process this to inspect `md-babel` components.

[select-block-schema]: https://github.com/md-babel/md-babel-schema/tree/main/select-block


# Transformer Pipelines

Transform a Markdown document so that

- **selected** parts of the document are
- **proessed by a pipeline** that executes side-effects, like image rendering,
- **producing a projection** of the document that includes the pipeline's output.

<!-- -->

    Document --> Pipeline -------------> Document
                     `---> Attachments ---^

## Library

Use the package as a library for transformations directly in your app.

## Executable

Each transformer comes with an executable target that you can use from the command line.
This is the intended usage.

Eventually, the goal is to execute a single command `swift run md-babel` with flags to turn on/off various processors.
Until then, we have commands for each individual pipeline.

## Supported Pipelines

### Mermaid graphs

To run the Mermaid transformer so that it renders all Mermaid language code blocks into SVGs onto your Desktop, 

1. Install [`mermaid-cli`](https://github.com/mermaid-js/mermaid-cli), and copy the full path to the executable:

        $ npm install -g @mermaid-js/mermaid-cli
        ...
        $ which mmdc
        /path/to/mermaid/cli/mmdc

2. Run the `render-mermaid` executable target: provide the executable path, an input file (or standard input), and a location to write images to:

        $ swift run render-mermaid \
            -i test.txt -o "~/Desktop/" \
            -f svg \
            -v --mermaid "/path/to/mermaid/cli/mmdc"

If you use the `text.txt` file from this repository, that will produce two images on your Desktop. 

Repeated runs will skip image generation unless the checksum of the code (and thus the code's content) has changed.

## Planned Pipelines

- Graphviz. Render the graphic for every `dot` code block in a document and insert the resulting image.
- LaTeX. Use PDF/SVG output to preview mathematical formulae (and other LaTeX documents and snippets).
- Table formulae. Re-render Markdown tables by running formulae on cells.

## Running the Samples

Since each pipeline requires an external program, you need to tweak the launch settings yourself.
Xcode is can run a CLI with arguments, but you will need to customize the scheme yourself.

It's easier to run from the command line (see examples in the pipelines above).

# License

