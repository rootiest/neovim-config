#!/usr/bin/env python3
"""Generate cheatsheet.html: every Vim/Neovim key and this config's keymaps.

Run from anywhere:  python3 gen_cheatsheet.py [--dump FILE]

Sources, merged into one searchable single-file page:
  * $VIMRUNTIME/doc/index.txt   every built-in key in every mode, plus Ex commands
  * the live config             dump.lua runs Neovim headless with this config and
                                records every keymap/command with the file and
                                line that set it (config, plugin or runtime)
  * curated/*.json              plugin-internal keys (pickers, completion, text
                                objects, …), descriptions, categories and notes

Built-in keys that a mapping replaces, delays or makes unreachable are flagged.
--dump FILE reuses (or, when FILE is missing, writes) a dump instead of
starting Neovim each run.
"""

import json
import os
import re
import subprocess
import sys
import tempfile
from datetime import date
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "cheatsheet.html"

MOTION_MODES = ["n", "x", "o"]

# ---------------------------------------------------------------------------
# Live dump
# ---------------------------------------------------------------------------


def run_dump(path):
    env = dict(os.environ, CHEATSHEET_DUMP=str(path))
    subprocess.run(
        ["nvim", "--headless", "-V1", "-c", f"luafile {HERE / 'dump.lua'}"],
        env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=120, check=False,
    )
    if not Path(path).exists():
        sys.exit("dump.lua produced no output — run it by hand to see the error:\n"
                 f"  CHEATSHEET_DUMP=/tmp/d.json nvim --headless -V1 -c 'luafile {HERE / 'dump.lua'}'")
    return json.loads(Path(path).read_text())


def load_dump():
    args = sys.argv[1:]
    if "--dump" in args:
        path = Path(args[args.index("--dump") + 1])
        return json.loads(path.read_text()) if path.exists() else run_dump(path)
    with tempfile.TemporaryDirectory() as tmp:
        return run_dump(Path(tmp) / "dump.json")


# ---------------------------------------------------------------------------
# Key notation
# ---------------------------------------------------------------------------


def index_keys(raw):
    """index.txt key column ("CTRL-W CTRL-B", "z<CR>", "a\"") -> Vim notation."""
    out = []
    if raw == '"``"':  # index.txt quotes this one so the help syntax stays intact
        return "``"
    for word in raw.split(" "):
        if not word:
            continue
        word = re.sub(r"CTRL-SHIFT-(.)", lambda m: f"<C-S-{m.group(1).upper()}>", word)
        word = re.sub(r"CTRL-(<[^>]+>|\{char\}|.)", lambda m: ctrl(m.group(1)), word)
        out.append(word)
    return "".join(out)


def ctrl(k):
    if k.startswith("<") and k.endswith(">"):
        return f"<C-{k[1:-1]}>"
    if k == "{char}":
        return "<C-{char}>"
    return f"<C-{k.upper() if k.isalpha() else k}>"


def canon(lhs):
    """Comparable form of a key sequence (keytrans style, case-folded names)."""
    def fix(m):
        inner = m.group(1)
        parts = inner.split("-")
        mods, key = parts[:-1], parts[-1] or "-"
        if len(key) > 1:
            key = {"cr": "CR", "esc": "Esc", "tab": "Tab", "bs": "BS", "space": "Space", "nl": "NL",
                   "lt": "lt", "bar": "Bar", "bslash": "Bslash"}.get(key.lower(), key[0].upper() + key[1:])
        elif mods and set(m.upper() for m in mods) == {"C"} and key.isalpha():
            key = key.upper()
        return "<" + "-".join([*(x.upper() for x in mods), key]) + ">"
    return re.sub(r"<([^<>]+)>", fix, lhs).replace("<lt>", "<").replace("<Lt>", "<")


TOKEN = re.compile(r'\["x\]|\{[^}]+\}|<(?:[A-Za-z0-9]+-)*(?:[A-Za-z0-9]+|[^>\s])>|.')


def tokens(lhs):
    return TOKEN.findall(lhs)


def is_ph(tok):
    return tok == '["x]' or (tok.startswith("{") and len(tok) > 1)


def base(lhs):
    """The keys a mapping would have to take over to replace this command:
    leading count/register and trailing {placeholders} removed; None when a
    placeholder sits in the middle (e.g. "<C-K>{char1}{char2}" is fine,
    "{char1}<BS>{char2}" is not)."""
    t = tokens(lhs)
    # Only a count or register can come before the keys; "{char1}<BS>{char2}"
    # starts with a typed character, so no mapping can replace it.
    while t and t[0] in ('["x]', "{count}"):
        t.pop(0)
    while t and is_ph(t[-1]):
        t.pop()
    if not t or any(is_ph(x) for x in t):
        return None
    return t


def starts_with(longer, shorter):
    return len(longer) > len(shorter) and longer[: len(shorter)] == shorter


# ---------------------------------------------------------------------------
# Built-ins: index.txt
# ---------------------------------------------------------------------------

SECTIONS = {
    "insert-index": ("i", "Insert mode"),
    "normal-index": ("n", "Normal mode"),
    "objects": ("o", "Text objects"),
    "CTRL-W": ("n", "Window commands"),
    "[": ("n", "Square bracket commands"),
    "g": ("n", "g commands"),
    "z": ("n", "z commands"),
    "operator-pending-index": ("o", "Operator-pending mode"),
    "visual-index": ("x", "Visual mode"),
    "ex-edit-index": ("c", "Command-line editing"),
    "terminal-mode-index": ("t", "Terminal mode"),
    "ex-cmd-index": (":", "Ex commands"),
}

# help file -> category, for built-ins without a more specific rule below.
FILE_CAT = {
    "motion.txt": "Motion", "change.txt": "Edit", "undo.txt": "Undo & repeat", "scroll.txt": "Scroll & view",
    "windows.txt": "Window", "tabpage.txt": "Buffer & tab", "fold.txt": "Fold", "pattern.txt": "Search",
    "insert.txt": "Insert", "visual.txt": "Visual", "cmdline.txt": "Command line", "quickfix.txt": "Quickfix & lists",
    "tagsrch.txt": "Tags", "diff.txt": "Diff", "spell.txt": "Spell", "editing.txt": "Files", "terminal.txt": "Terminal",
    "lsp.txt": "LSP & diagnostics", "diagnostic.txt": "LSP & diagnostics", "repeat.txt": "Register & macro",
    "digraph.txt": "Insert", "map.txt": "Misc", "options.txt": "Misc", "various.txt": "Misc", "message.txt": "Misc",
    "starting.txt": "Files", "helphelp.txt": "Help", "eval.txt": "Misc", "gui.txt": "Misc", "sign.txt": "Misc",
    "if_pyth.txt": "Misc", "if_lua.txt": "Misc", "lua.txt": "Misc", "syntax.txt": "Misc", "autocmd.txt": "Misc",
    "usr_41.txt": "Misc", "vimfn.txt": "Misc", "vimeval.txt": "Misc", "print.txt": "Misc", "remote.txt": "Misc",
    "mbyte.txt": "Misc", "arabic.txt": "Misc", "rileft.txt": "Misc", "provider.txt": "Misc", "pi_netrw.txt": "Files",
    "pi_spec.txt": "Misc", "treesitter.txt": "Misc", "news.txt": "Misc", "uganda.txt": "Help", "intro.txt": "Help",
}
OPERATORS = {"c", "d", "y", "<", ">", "!", "=", "g~", "gu", "gU", "g?", "gq", "gw", "g@", "zf", "gc"}
MARKS = re.compile(r"^(m|'|`|g'|g`|<C-O>|<C-I>|<Tab>|g;|g,|''|``|\['|\]'|\[`|\]`|'\[|'\]|`\[|`\]|'<|'>|`<|`>|'\"|`\"|'\^|`\^|'\.|`\.)")
REGISTERS = re.compile(r'^("|q|@|Q)')


def parse_tags(runtime):
    tags = {}
    for line in (Path(runtime) / "doc/tags").read_text(errors="replace").splitlines():
        parts = line.split("\t")
        if len(parts) >= 2:
            tags[parts[0]] = parts[1]
    return tags


def parse_index(runtime, tags):
    lines = (Path(runtime) / "doc/index.txt").read_text().splitlines()
    entries, section, in_table, cur, sub = [], None, False, None, None

    def flush():
        nonlocal cur
        if cur:
            cur["desc"] = re.sub(r"\s+", " ", cur["desc"]).strip()
            if cur["desc"] and not cur["desc"].startswith("not used") and cur["desc"] != "reserved":
                entries.append(cur)
        cur = None

    for raw in lines:
        m = re.search(r"\*([^*\s]+)\*", raw)
        if raw.startswith(tuple("0123456789")) and m:
            flush()
            names = re.findall(r"\*([^*\s]+)\*", raw)
            section = next((n for n in names if n in SECTIONS), None)
            in_table, sub = False, None
            continue
        if section is None:
            continue
        if raw.rstrip().endswith("~") and raw.startswith("-----"):
            in_table = True
            continue
        if not in_table:
            continue
        if raw.startswith("====="):
            flush()
            section, in_table = None, False
            continue
        line = raw.expandtabs(8)
        if not line.strip():
            flush()
            continue
        indent = len(line) - len(line.lstrip())
        if raw.startswith("'") and "\t" in raw:
            # "'cedit'  CTRL-F  ...": an option name in the tag column.
            raw = raw.split("\t", 1)[1].lstrip("\t")
        elif indent == 0 and not raw.startswith("|"):
            # Sub-heading inside a table ("commands in CTRL-X submode").
            flush()
            sub = re.sub(r"\s*\*[^*]+\*\s*", "", raw).replace("|", "").strip()
            continue
        if indent >= 24 and cur is not None:
            cur["desc"] += " " + line.strip()
            continue
        if indent >= 24:
            continue
        flush()
        m = re.match(r"^(?:\|([^|]+)\|)?\s*(\S.*)$", raw)
        if not m:
            continue
        tag, body = m.group(1), m.group(2)
        sep = re.search(r"\t+|\s{2,}", body)
        if sep:
            key, rest = body[: sep.start()].strip(), body[sep.end():]
        else:
            # Key column overflowed into the description with single spaces:
            # keep key-like words ("CTRL-V {number}", "CTRL-\\ e {expr}").
            words, key_words = body.split(" "), []
            while words and (not key_words or len(words[0]) == 1
                             or re.match(r"^(CTRL-|<|\{)", words[0])):
                key_words.append(words.pop(0))
            key, rest = " ".join(key_words), " ".join(words)
        note = ""
        nm = re.match(r"^([12])\s+(.*)$", rest.strip())
        if nm and section in ("normal-index", "CTRL-W", "[", "g", "z", "visual-index"):
            note, rest = nm.group(1), nm.group(2)
        mode, sect_name = SECTIONS[section]
        cur = {"raw": key, "tag": tag, "note": note, "desc": rest, "section": sect_name, "sect": section, "mode": mode,
               "sub": sub}
    flush()

    out = []
    for e in entries:
        if e["mode"] == ":":
            out.append(ex_entry(e, tags))
            continue
        keys = index_keys(e["raw"])
        tag = e["tag"]
        if e["sect"] == "objects":
            modes = ["x", "o"]
        elif e["note"] == "1" and e["mode"] == "n":
            modes = MOTION_MODES
        else:
            modes = [e["mode"]]
        out.append({
            "k": keys, "m": modes, "d": e["desc"], "s": "builtin",
            "t": tag, "h": tags.get(tag) if tag else None, "sec": e["section"],
            "cat": builtin_cat(e, keys, tags.get(tag, "") if tag else ""),
            "mo": 1 if e["note"] == "1" else None, "ch": 1 if e["note"] == "2" else None,
            "ctx": e["sub"][0].upper() + e["sub"][1:] if e["sub"] else None,
        })
    return out


def ex_entry(e, tags):
    name = e["raw"]
    return {
        "k": name, "m": [":"], "d": e["desc"], "s": "builtin", "t": e["tag"],
        "h": tags.get(e["tag"]) if e["tag"] else None, "sec": "Ex commands",
        "cat": FILE_CAT.get(tags.get(e["tag"], ""), "Misc") if e["tag"] else "Misc", "ex": 1,
    }


def builtin_cat(e, keys, helpfile):
    if e["sect"] == "objects":
        return "Text object"
    if e["sect"] == "CTRL-W":
        return "Window"
    if e["sect"] == "ex-edit-index":
        return "Command line"
    if e["sect"] == "insert-index":
        return "Insert"
    if e["sect"] in ("normal-index", "g", "z", "visual-index", "operator-pending-index", "["):
        if keys in OPERATORS or (e["sect"] == "visual-index" and keys in OPERATORS):
            return "Operator"
        if MARKS.match(keys) and e["sect"] != "visual-index":
            return "Mark & jump"
        if REGISTERS.match(keys) and helpfile in ("change.txt", "repeat.txt", "undo.txt"):
            return "Register & macro"
    cat = FILE_CAT.get(helpfile)
    if cat == "Motion" and e["note"] != "1":
        return "Mark & jump" if "jump" in e["desc"] or "mark" in e["desc"] else "Motion"
    return cat or ("Motion" if e["note"] == "1" else "Misc")


# ---------------------------------------------------------------------------
# Live maps
# ---------------------------------------------------------------------------


def source_of(path, d):
    """(source id, short file label) for the file that set a mapping."""
    if not path:
        return "unknown", None
    cfg, runtime = d["config"].rstrip("/") + "/", d["vimruntime"].rstrip("/") + "/"
    packs = d["data"].rstrip("/") + "/site/pack/"
    if path.startswith(cfg):
        return "config", path[len(cfg):]
    if path.startswith(runtime):
        rel = path[len(runtime):]
        if rel.startswith("ftplugin/"):
            return "ftplugin", rel
        if "matchit" in rel:
            return "matchit", rel
        return "neovim", rel
    if path.startswith(packs):
        m = re.match(r"[^/]+/(?:opt|start)/([^/]+)/(.*)", path[len(packs):])
        if m:
            return m.group(1), m.group(2)
    if "/vimfiles/" in path or path.startswith("/usr/share/vim"):
        return Path(path).stem + " (system)", path
    return "other", path


def live_entries(d, curated_desc):
    out = []
    leader = d.get("leader") or "\\"
    lead = canon("<Space>") if leader == " " else leader

    def add(m, buffer_ctx=None):
        lhs = m["lhs"]
        if lhs.startswith("<Plug>") or lhs.startswith("<SNR>") or "<Plug>" in lhs[:1]:
            return
        src, file = source_of(m.get("file"), d)
        key = canon(lhs)
        desc = m.get("desc")
        rhs = m.get("rhs")
        help_tag = desc[6:].strip() if desc and desc.startswith(":help ") else None
        # map_desc may carry a `ctx` ("markdown buffers") to target one buffer-local
        # map; entries without one apply everywhere.
        cd = next((curated_desc[t] for c in dict.fromkeys((buffer_ctx, None))
                   for t in ((src, m["mode"], key, c), (src, "*", key, c)) if t in curated_desc), {})
        # The config's own desc wins (which-key shows it too) unless it is
        # missing or only a ":help" pointer; category/notes always apply.
        if cd.get("d") and (not desc or desc.startswith(":help") or cd.get("force")):
            desc = cd["d"]
        if not desc:
            if rhs and rhs.startswith("<Plug>("):
                desc = rhs[7:-1].replace("-", " ")
            elif rhs:
                desc = f"runs {rhs}"
            else:
                desc = "(disabled)" if not m.get("callback") else "(Lua function)"
        if desc == "which_key_ignore" or (src == "which-key" and not cd.get("d")):
            return  # which-key's own trigger maps: they only show the popup
        e = {
            "k": key, "m": [m["mode"]], "d": desc, "s": src, "f": file, "l": m.get("line"),
            "rhs": rhs if rhs and not rhs.startswith("<Plug>(leap") else None,
            "nw": 1 if m.get("nowait") else None,
            "cat": cd.get("cat"), "n": cd.get("n"), "e": cd.get("e"), "sl": cd.get("sl"),
        }
        if key.startswith(lead) and leader == " " and m["mode"] in ("n", "x", "s", "o"):
            e["ld"] = 1
        if help_tag:
            e["t"] = help_tag
        if buffer_ctx:
            e["ctx"] = buffer_ctx
        out.append(e)

    for m in d["maps"]:
        add(m)
    for b in d["buffers"]:
        for m in b["maps"]:
            add(m, f"{b['filetype']} buffers")
    return merge_modes(out)


def merge_modes(entries):
    """Collapse identical maps registered for several modes into one entry."""
    merged, order = {}, []
    for e in entries:
        k = (e["k"], e["d"], e["s"], e.get("f"), e.get("l"), e.get("ctx"))
        if k in merged:
            for mode in e["m"]:
                if mode not in merged[k]["m"]:
                    merged[k]["m"].append(mode)
        else:
            merged[k] = e
            order.append(k)
    return [merged[k] for k in order]


# ---------------------------------------------------------------------------
# Curated data
# ---------------------------------------------------------------------------


def load_curated():
    cur = {"entries": [], "notes": [], "map_desc": [], "builtin": {}, "essentials": [], "commands": {}, "groups": {}}
    for f in sorted((HERE / "curated").glob("*.json")):
        data = json.loads(f.read_text())
        for k in ("entries", "notes", "map_desc", "essentials"):
            cur[k] += data.get(k, [])
        for tag, fields in data.get("builtin", {}).items():
            cur["builtin"].setdefault(tag, {}).update(fields)  # several files may add to one tag
        cur["commands"].update(data.get("commands", {}))
        cur["groups"].update(data.get("groups", {}))
    return cur


# ---------------------------------------------------------------------------
# Conflicts: what the config changes about stock Vim
# ---------------------------------------------------------------------------


def annotate(builtins, live):
    by_mode_key = {}
    for i, b in enumerate(builtins):
        if b.get("ex"):
            continue
        bt = base(canon(b["k"]))
        if bt is None:
            continue
        b["_t"] = bt
        for mode in b["m"]:
            by_mode_key.setdefault((mode, tuple(bt)), []).append(i)

    live_by_mode = {}
    for j, e in enumerate(live):
        e["_t"] = tokens(e["k"])
        if e.get("ctx"):
            continue
        for mode in e["m"]:
            live_by_mode.setdefault(mode, {})[tuple(e["_t"])] = j

    for j, e in enumerate(live):
        for mode in e["m"]:
            for i in by_mode_key.get((mode, tuple(e["_t"])), []):
                builtins[i].setdefault("ov", []).append({"m": mode, "by": j})
                e.setdefault("rep", []).append({"m": mode, "b": i})

    for mode, maps in live_by_mode.items():
        # Longer maps that a shorter `nowait` map makes unreachable.
        for lhs, j in maps.items():
            if live[j].get("nw"):
                for other, k in maps.items():
                    if starts_with(list(other), list(lhs)):
                        live[k].setdefault("sh", []).append({"m": mode, "by": j})
        # Complete built-in commands that now wait for 'timeoutlen' because a
        # mapping extends them (e.g. "ga" once "gai"/"gao" exist).
        for (bmode, bkey), idxs in by_mode_key.items():
            if bmode != mode or bkey in maps:
                continue
            ext = [live[j]["k"] for lhs, j in maps.items() if starts_with(list(lhs), list(bkey))]
            if ext:
                for i in idxs:
                    if not is_ph(tokens(builtins[i]["k"])[-1]):
                        builtins[i].setdefault("wait", []).append({"m": mode, "ext": sorted(ext)[:6], "n": len(ext)})
    for x in builtins + live:
        x.pop("_t", None)


# ---------------------------------------------------------------------------


def main():
    d = load_dump()
    runtime = d["vimruntime"]
    tags = parse_tags(runtime)
    builtins = parse_index(runtime, tags)
    cur = load_curated()

    for b in builtins:
        extra = cur["builtin"].get(f"{''.join(b['m'])}|{b['k']}") or cur["builtin"].get(b.get("t") or "")
        if extra:
            b.update({k: v for k, v in extra.items() if v is not None})
    ess = {(e.get("t") or "", e.get("k") or "") for e in cur["essentials"]}
    for b in builtins:
        if (b.get("t") or "", "") in ess or ("", b["k"]) in ess:
            b["e"] = 1

    curated_desc = {(c["s"], c.get("m", "*"), canon(c["k"].replace("<leader>", "<Space>")), c.get("ctx")): c
                    for c in cur["map_desc"]}
    live = live_entries(d, curated_desc)
    annotate(builtins, live)
    # Help links for the template: Neovim's own defaults describe themselves as
    # ":help <tag>"; curated entries name a tag in "h". "hf" is the runtime help
    # file holding that tag (None for plugin docs, which neovim.io doesn't host).
    for e in live:
        if e.get("t"):
            e["hf"] = tags.get(e["t"])
    for c in cur["entries"]:
        if c.get("h"):
            c["hf"] = tags.get(c["h"])
    for e in live:
        if not e.get("cat"):
            group = next((g for g in sorted(cur["groups"], key=len, reverse=True)
                          if canon(g.replace("<leader>", "<Space>")) == e["k"][: len(canon(g.replace("<leader>", "<Space>")))]
                          and cur["groups"][g].get("cat")), None)
            if group:
                e["cat"] = cur["groups"][group]["cat"]
            elif e.get("rep"):
                e["cat"] = builtins[e["rep"][0]["b"]]["cat"]
            else:
                e["cat"] = "Misc"

    commands = []
    for c in d["commands"] + [dict(c, ctx=b["filetype"]) for b in d["buffers"] for c in b["commands"]]:
        src, file = source_of(c.get("file"), d)
        commands.append({"k": ":" + c["name"], "d": cur["commands"].get(c["name"]) or c.get("desc") or "",
                         "s": src, "f": file, "na": c.get("nargs"), "r": 1 if c.get("range") else None,
                         "ctx": c.get("ctx")})

    plugins = sorted({p["name"] for p in d["plugins"] if p.get("active")})
    data = {
        "meta": {
            "version": d["version"], "leader": d["leader"], "localleader": d["localleader"],
            "date": date.today().isoformat(), "plugins": plugins, "options": d["options"],
            "timeoutlen": d["options"]["timeoutlen"],
        },
        "builtins": builtins,
        "live": live,
        "curated": cur["entries"],
        "notes": cur["notes"],
        "groups": cur["groups"],
        "commands": commands,
        "picker": d.get("snacks_picker"),
        "explorer": d.get("snacks_explorer"),
        "blink": d.get("blink"),
        "flash": d.get("flash"),
    }
    payload = json.dumps(data, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
    template = (HERE / "cheatsheet.template.html").read_text().split("\n", 1)[1]  # drop the template note
    OUT.write_text(template.replace("/*DATA*/null", payload))
    n_ov = sum(1 for b in builtins if b.get("ov"))
    print(f"wrote {OUT.name}: {len(builtins)} built-ins ({n_ov} overridden), {len(live)} live maps, "
          f"{len(cur['entries'])} curated, {len(commands)} commands, {len(cur['notes'])} notes")


if __name__ == "__main__":
    main()
