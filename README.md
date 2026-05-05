# Ubuntu Server Guide

A LaTeX book documenting my Ubuntu server learning journey.

## About

This project is a guide to using, setting up, and administering Linux servers based on Ubuntu. It is written in LaTeX and grew from my personal Ubuntu learning experience, which began in 2008. I started collecting this guide in 2011 as a way to capture practical server administration techniques, configuration notes, and helpful commands.

## Author

Adam Rees – [github.com/adamrees89](https://github.com/adamrees89)

## What is included

- `chapters/` — individual LaTeX chapters covering topics like Apache, SSH, Samba, MySQL, mail servers, and more
- `supportfiles/` — shared LaTeX setup files, templates, and document configuration
- `texlive/` — helper scripts and package lists for installing the LaTeX environment needed to build the guide

## Requirements

- Ubuntu-compatible environment for generating the book
- `pdflatex` to compile the main document
- `latexmk` for repeated build automation and dependency handling
- `python3-pygments` to support `minted` if used in the document
- `wget` and `perl` for the TeX Live installer scripts
- GitHub Actions workflow for CI-based builds with cached TeX Live state

## Project structure

- `Server Set ups.tex` — root LaTeX file for the full guide
- `chapters/` — chapter source files included into the main document
- `supportfiles/` — LaTeX setup, front matter, and helper input files
- `texlive/` — install script and package list for managing TeX Live dependencies
- `.github/workflows/actions.yml` — CI workflow for building the PDF and caching TeX Live

## Build instructions

The book is generated using `pdflatex` from the main TeX source file `Server Set ups.tex`.

A typical build flow is:

```bash
cd <repo-root>
cd templates
pdflatex 'Server Set ups.tex'
```

For CI, the workflow installs only the required TeX Live packages and caches the TeX Live installation to speed future builds.

## Notes

- The guide is written in LaTeX and is intended for Ubuntu server administration.
- It reflects years of experience and learning gathered since 2008.
- The document is still a work in progress and may contain draft material.

## Contributing

If you want to contribute improvements or additional chapters, please open a pull request with LaTeX changes and a short description of the updates.

## How to extend this guide

New content should be added as a new chapter file inside `chapters/` and included from `Server Set ups.tex`.

General conventions used in the existing document:

- Use `\chapter{}` for new chapters and `\label{chp:...}` to create cross-reference targets.
- Use `\section{}` and `\subsection{}` to break content into readable, task-focused sections.
- Refer to chapters, sections, tables and figures using `~\ref{...}` (for example, `Chapter~\ref{chp:first}` or `Table~\ref{tab:useful_commands}`).
- Use `\textbf{}` for software names, important commands, and key terms.
- Present shell commands in `\begin{lstlisting}...\end{lstlisting}` blocks rather than inline text when they are real commands.
- Use `table` environments for command summaries and shortcut lists, with `\caption{}` and `\label{}` for references.
- Keep explanations conversational and practical, with examples followed by brief descriptions.
- If a topic is unfinished, use a `\todo[inline,color=blue!40]{...}` note so it is easy to find later.

File and build conventions:

- Keep chapter source files in `chapters/` and name them with a `.tex` extension.
- Add the new chapter to `Server Set ups.tex` in the appropriate `\part{}` section using an `\input{./chapters/yourfile.tex}` line.
- If the new chapter belongs in the appendix, use `\appendix` and then `\input{...}` after the existing appendices.
- Preserve the existing style of short explanatory paragraphs followed by commands and tables.

Example workflow:

1. Create `chapters/mytopic.tex`.
2. Add structure:

```tex
\chapter{My New Topic}
\label{chp:mytopic}

\section{Overview}

A short introduction to the topic.

\section{Installation}

\begin{lstlisting}
sudo apt-get install example-package -y
\end{lstlisting}
```

3. Add the file to `Server Set ups.tex` in the proper section.
4. Build the PDF to confirm the new chapter compiles cleanly.

Following these conventions keeps the guide consistent with the existing chapters, makes cross-references work well, and helps future contributors understand the structure quickly.

## License

This project is available under the terms of the MIT License. See `LICENSE` for details.
