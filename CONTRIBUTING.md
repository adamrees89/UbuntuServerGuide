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