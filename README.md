# kyte for Hermes

Your company's **kyte** workspace, in the [Hermes agent](https://github.com/NousResearch/hermes-agent):
customers, contacts, deals, projects, hours, invoices, goals, people and documents — read and
changed as you, under your own permissions.

kyte is the company OS by [Pirol Labs](https://pirol.ai). This repository holds what makes it
reachable from Hermes.

## What is here

| | |
| - | - |
| `optional-mcps/kyte/` | the MCP catalog entry, in the form Hermes reads it. The copy we propose upstream lives here too, so the one people install and the one we maintain are the same file. |
| `check.sh` | proves the entry works, in a throwaway Hermes home that never touches yours |

## Install it today

The catalog entry is not upstream yet, so add the server by hand — it is the same two lines the
entry writes for you:

```
hermes mcp add kyte --command kyte --args mcp --db "$HOME/.kyte/hermes"
```

(The entry itself writes `~/.kyte/hermes` and leaves the `~` for kyte to expand, which is right on
every platform. Doing that by hand needs a shell to expand it, hence `$HOME` in the line above.)

Once it is in the catalog, that becomes:

```
hermes mcp install kyte
```

Either way, kyte itself has to be on the machine and signed in once:

```
curl -fsSL https://updates.pirol.ai/cli/install.sh | sh     # macOS / Linux
~/.local/bin/kyte login --db ~/.kyte/hermes
```

The full path in step two is on purpose: the installer's folder is not always on your `PATH` yet,
and a bare `kyte login` then answers "command not found" to someone who did everything right.

## Why Hermes gets its own folder

kyte keeps an encrypted local copy of your workspace, and one folder serves one process. A Hermes
session and a kyte session in a terminal pointed at the same folder are two writers on one
database. `~/.kyte/hermes` keeps them apart — which is why you sign in for that folder, not just
anywhere.

## What it runs, sends and stores

- **Runs:** `kyte mcp`, from the kyte you installed. Nothing is fetched at install time and this
  repository ships no program.
- **Sends:** what Hermes reads through these tools goes to whichever model you run Hermes on. kyte
  keeps your workspace in step with your company's kyte team server, run by your company itself or
  by Pirol on its behalf in German data centers. Nothing goes anywhere else.
- **Stores:** the local copy in the data folder above, its key in your operating system's keychain.
  Every change made here is recorded in kyte as made by an agent on your behalf.
- **Credentials:** none in this repository and none in the config. `kyte login` signs in through
  the browser and stores the session in the data folder.

## Checking it

```
./check.sh
```

It gives itself a temporary `HERMES_HOME` and `HOME`, lists the entry, installs it, connects, and
prints the tools it found. Without a kyte session that is a single tool explaining how to sign in —
which is the behaviour worth having, and worth checking.

## License

MIT — see [LICENSE](LICENSE).
