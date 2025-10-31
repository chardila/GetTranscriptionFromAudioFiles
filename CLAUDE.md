# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an audio transcription tool that batch processes audio files using faster-whisper. The project consists of a bash script with a professional CLI interface that orchestrates transcription using a Python backend for efficient processing.

## How to Run

The main script is `GetTranscriptionFromAudioFiles.sh` with support for command-line options:

```bash
# Basic usage with defaults
./GetTranscriptionFromAudioFiles.sh

# Custom configuration
./GetTranscriptionFromAudioFiles.sh -i recordings -o texts -m medium -l auto -v

# Show help
./GetTranscriptionFromAudioFiles.sh --help
```

### Command Line Options

- `-i, --input DIR`: Input directory containing audio files (default: audios)
- `-o, --output DIR`: Output directory for transcripts (default: transcripts)
- `-m, --model MODEL`: Whisper model: tiny|base|small|medium|large (default: small)
- `-l, --lang LANG`: Language code (e.g., en, es, fr) or 'auto' for auto-detection (default: es)
- `-v, --verbose`: Enable verbose output for debugging
- `--no-mime-check`: Skip MIME type validation of audio files
- `-h, --help`: Show help message

## Dependencies

- **Python 3**: Required for running the transcription engine
- **faster-whisper**: Install with `pip install faster-whisper`
  - More efficient than OpenAI Whisper (uses CTranslate2 backend)
  - Supports GPU acceleration (CUDA) and CPU inference
  - Includes Voice Activity Detection (VAD) for better accuracy
- **Bash**: The script uses bash-specific features (arrays, process substitution, traps)
- **Standard Unix tools**: `find`, `tr`, `sed`, `mv`, `basename`, `file` (for MIME validation)

## Architecture

The project consists of two main components:

### 1. Bash Orchestrator (`GetTranscriptionFromAudioFiles.sh`)
Professional CLI wrapper with:
- Argument parsing with validation
- Colored output and progress indicators
- Dependency validation
- MIME type checking for audio files
- Error handling with cleanup traps
- Temporary file management
- Verbose logging mode
- Summary statistics

**Key functions:**
- `parse_args()`: Command-line argument parsing (lines 160-198)
- `validate_dependencies()`: Check for Python and faster-whisper (lines 108-133)
- `validate_config()`: Validate directories and model settings (lines 201-243)
- `validate_audio_file()`: MIME type validation (lines 136-157)
- `process_audio_file()`: Process individual files (lines 246-325)
- `cleanup()`: Trap handler for cleanup operations (lines 89-102)

### 2. Python Backend (`transcribe_faster_whisper.py`)
Efficient transcription engine using faster-whisper:
- Automatic device selection (CPU/CUDA)
- Automatic compute type optimization (int8 for CPU, float16 for GPU)
- Voice Activity Detection (VAD) for improved accuracy
- Language detection with confidence scores
- Proper segment handling and joining

**Key functions:**
- `transcribe_audio()`: Main transcription logic (lines 12-84)
- Supports models: tiny, base, small, medium, large, large-v2, large-v3

### Processing Flow

1. Parse command-line arguments and validate configuration
2. Validate all dependencies (Python, faster-whisper, file command)
3. Count and validate audio files in input directory
4. For each audio file:
   - Validate MIME type (if enabled)
   - Call Python transcription script with appropriate parameters
   - Locate generated transcript file
   - Convert multi-line transcript to single line
   - Save to output directory with cleaned formatting
5. Display summary statistics

### Error Handling

The bash script includes comprehensive error handling:
- Strict mode with `set -euo pipefail`
- Trap handlers for EXIT, INT, and TERM signals
- Temporary file cleanup on exit
- Per-file error tracking without halting batch processing
- Detailed error messages with troubleshooting hints

## File Structure

```
.
├── GetTranscriptionFromAudioFiles.sh   # Main bash orchestrator
├── transcribe_faster_whisper.py        # Python transcription backend
├── audios/                             # Input directory (created by user)
└── transcripts/                        # Output directory (created by script)
```

## Development Notes

- The bash script uses professional CLI patterns with colored output and emoji indicators
- Uses `find -print0` with null-delimited processing for handling special characters in filenames
- Audio file detection is case-insensitive using `-iname`
- Transcript cleanup converts multi-line output to single-line format for easier processing
- Python script writes to stderr for logging, keeping stdout clean
- VAD (Voice Activity Detection) is enabled by default for better accuracy
- The Python backend automatically selects the best device and compute type
- MIME type validation can be disabled for environments without the `file` command