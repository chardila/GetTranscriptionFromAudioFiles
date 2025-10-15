# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a bash script project for batch transcribing audio files using OpenAI's Whisper. The project consists of a single executable bash script that processes audio files from an input directory and generates text transcriptions in an output directory.

## How to Run

The main script is `GetTranscriptionFromAudioFiles.sh` (executable bash script):

```bash
./GetTranscriptionFromAudioFiles.sh
```

## Dependencies

- **Python 3**: Required for running Whisper
- **OpenAI Whisper**: Install with `pip install openai-whisper`
- **Bash**: The script uses bash-specific features (arrays, process substitution)
- **Standard Unix tools**: `find`, `tr`, `sed`, `mv`, `basename`

## Configuration

The script has configurable variables at the top (lines 4-7):
- `INPUT_DIR`: Directory containing audio files (default: "audios")
- `OUTPUT_DIR`: Directory for transcript files (default: "transcripts")
- `MODEL`: Whisper model size (default: "small")
- `LANG`: Language code for transcription (default: "es" for Spanish, use "auto" for auto-detection)

## Architecture

This is a single-file bash script with the following flow:
1. Creates output directory if it doesn't exist
2. Uses `find` to locate audio files (mp3, wav, m4a, flac) in the input directory
3. For each audio file:
   - Runs `python3 -m whisper` with specified parameters
   - Locates the generated transcript file
   - Converts multi-line transcript to single line (replaces newlines with spaces)
   - Saves cleaned transcript to output directory

The script handles:
- File paths with spaces and special characters (using `find -print0` and null-delimited processing)
- Error handling for failed transcriptions
- Flexible transcript file location detection
- Text normalization (collapsing whitespace, trimming)

## File Structure

```
.
├── GetTranscriptionFromAudioFiles.sh  # Main executable script
├── audios/                        # Input directory (created by user)
└── transcripts/                   # Output directory (created by script)
```

## Development Notes

- The script uses `set -euo pipefail` for strict error handling
- Audio file detection is case-insensitive using `-iname`
- The script preserves Whisper's output and error handling
- Transcript cleanup converts multi-line output to single-line format for easier processing