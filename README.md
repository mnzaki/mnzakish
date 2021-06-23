# mnzakish
`mnzakish`, or `msh` for short, is really just `bash` and some stuff over each other. _msh_ is pronounced مِشّْ

## Context / Stack Frame

`msh` is `cwd`-<abbr title="Current Working Directory">aware</abbr>, and <a
href="http://www.gnu.org/software/bash/manual/html_node/The-Directory-Stack.html#The-Directory-Stack">Directory Stack</a> aware, imbuing both with further function.

For _msh_ each `StackFrame`, or _SF_ for short, accounts for an _Activity_ such as browsing a directory listing or finding a file, or editing a file. Activities are grouped by an _Intent_. Intents are higher level tasks, like things from your todo list or task manager for example.

An _SF_ is a unit of attention attributable to an _Intent_. _msh_ is an intent manager at its core.



