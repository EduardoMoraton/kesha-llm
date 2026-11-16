# Kesha Code LLM

Tiny local AI for the M5Stack Cardputer Zero (Raspberry Pi CM0, 320x170 LCD, keyboard only).

- **Code** - projects (folders in `~/kesha-code`) with a file manager, an sh/Python editor and a run console.
  A local model writes, names and edits scripts from the project chat. The top bar shows the model in use and
  the battery. Built-in *skills* (wifi, web server, Python snippets, battery, temperature…) and your
  `.context/` notes are fed to it as hints; saved scripts are kept clean (no stray comments).
- **Chat** - talk to a small GGUF model through the bundled llama.cpp server.
- **Vision** - live object detection (YOLOX via ONNX Runtime), OCR (tesseract), photos, annotated video.
- **Models** - download / select / delete models; your own `.gguf` or `.onnx` go in `~/.local/share/kesha-llm/models`.
- **Settings** - "Power mode" (lowers `gpu_mem` to 16 in `/boot/firmware/config.txt` so a 350M model fits in
  RAM; turns the camera off, asks for the admin password, reversible, needs a restart) and camera flip.

## Keys

F / X move up and down, Z / C left and right (or Fn+arrows), Enter selects, Esc goes back, Tab changes view.
In a project, Fn+Z / Fn+C focus the chat (left) or the files (right) — the focused panel has an accent border.
Tab cycles the screens: Files+Chat, Models, Runs. In chat focus, type your request (the bubble grows) and Enter
sends (Fn+F/X scroll). In files focus, Fn+F/X move, Enter edits, R runs, N new, D delete, Z up a folder. Models:
Enter uses the selected one. Runs: Enter shows output, K stops a run. Delete a project with D in the project
list. F1 shows help anywhere. In the editor: Esc saves and closes, Ctrl+R saves and runs, Ctrl+Q discards.

## Build and install

    ./deploy.sh pi@<cardputer-ip>      # copies the sources, builds the .deb on the device, installs it
    python3 kesha-llm --selftest       # unit checks (any machine with pygame)

`build-deb.sh` needs `curl`, `tar`, `python3 -m pip` and `dpkg-deb`; it downloads pinned llama.cpp and
ONNX Runtime binaries into `build/` and writes `dist/kesha-llm_<version>_arm64.deb`.
Set `MAINTAINER="Name <email>"` when building a release.

## What fits

A stock Cardputer Zero shows 352 MB of RAM (`gpu_mem=128`), and with the system and this app loaded only
models up to about 90 MB stay in memory: the 56 MB `falcon-h1-90m` generates ~13 tokens/s, a 98 MB build of
the same model drops to 0.4 because part of it no longer fits. **Power mode** drops `gpu_mem` to 16, which
shows ~462 MB of RAM and lets a 350 MB model stay resident: `lfm2-350m` then generates ~5 tokens/s and writes
noticeably better code (on a benchmark it got 4/8 device tasks fully right versus 2/8 for the 90M). The 469 MB
`qwen2.5-coder-0.5b` is the strongest coder (8/8) but does not fit even in Power mode, so it streams from the
SD card at ~1 token/s — usable only for "leave it thinking". Always read a script before running it. The first
Code request with a model takes about a minute (it reads the examples once and saves that state); after that a
request takes 20-40 seconds (longer for `qwen`).

## Publishing to the CardputerZero Hub

1. Fill in `store/meta.json` (`author`, `source_repo`; check `license` and the 4-character `share_code`)
   and add a LICENSE file to the repository.
2. Build with a real maintainer: `MAINTAINER="Name <email>" ./build-deb.sh`.
3. Upload through https://dev.cardputer.cc/#/upload (GitHub login) or `czdev publish --deb dist/...deb`.
   Both open a pull request against `CardputerZero/packages` that adds `pool/main/kesha-llm/` with
   `meta.json`, `kesha-llm_icon.png`, `screenshots/` (PNG, exactly 320x170) and the release JSON.
4. First release only: post a video of the app running on a real device in that pull request.

## Third-party components

llama.cpp (MIT), ONNX Runtime (MIT), YOLOX-nano weights (Apache-2.0); models are downloaded from
Hugging Face under their own licences.
