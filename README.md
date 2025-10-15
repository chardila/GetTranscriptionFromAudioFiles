# Audio File Transcription Tool

A bash script that batch transcribes audio files using OpenAI's Whisper speech recognition model.

## What it Does

This tool automatically:
- Finds all audio files in a specified directory
- Transcribes them using OpenAI Whisper
- Converts multi-line transcripts to single-line format
- Saves cleaned transcripts as text files

## Prerequisites

Before using this script, you need:

1. **Python 3** installed on your system
2. **OpenAI Whisper** installed:
   ```bash
   pip install openai-whisper
   ```

## Supported Audio Formats

- MP3 (.mp3)
- WAV (.wav)
- M4A (.m4a)
- FLAC (.flac)

## Quick Start

1. **Make the script executable** (if not already):
   ```bash
   chmod +x GetTranscriptionFromAudioFiles.sh
   ```

2. **Create your input directory** and add audio files:
   ```bash
   mkdir audios
   # Copy your audio files to the audios directory
   ```

3. **Run the script**:
   ```bash
   ./GetTranscriptionFromAudioFiles.sh
   ```

4. **Find your transcripts** in the `transcripts` directory

## Configuration

You can modify these variables at the top of the script (lines 4-7):

- **`INPUT_DIR`**: Directory containing your audio files (default: `"audios"`)
- **`OUTPUT_DIR`**: Where transcripts will be saved (default: `"transcripts"`)
- **`MODEL`**: Whisper model size (default: `"small"`)
- **`LANG`**: Language for transcription (default: `"es"` for Spanish)

### Available Whisper Models

| Model | Size | Speed | Accuracy |
|-------|------|-------|----------|
| tiny | 39 MB | Fastest | Lowest |
| base | 74 MB | Fast | Low |
| small | 244 MB | Medium | Medium |
| medium | 769 MB | Slow | High |
| large | 1550 MB | Slowest | Highest |

### Language Options

- Use `"auto"` for automatic language detection
- Use specific language codes like `"en"` (English), `"es"` (Spanish), `"fr"` (French), etc.
- Remove the `--language` parameter entirely for auto-detection

## Example Usage

### Basic Usage
```bash
./GetTranscriptionFromAudioFiles.sh
```

### Custom Configuration
Edit the script to change settings:
```bash
INPUT_DIR="my_recordings"
OUTPUT_DIR="my_transcripts"
MODEL="medium"
LANG="en"
```

## What Happens During Execution

1. The script creates the output directory if it doesn't exist
2. Searches for audio files in the input directory
3. For each audio file:
   - Shows progress: `▶ Transcribing: filename.mp3`
   - Runs Whisper transcription
   - Converts multi-line transcript to single line
   - Saves cleaned transcript as `filename.txt`
   - Shows completion: `✔ Saved: transcripts/filename.txt`

## Output Format

- Original Whisper output may have multiple lines
- This script converts transcripts to single-line format
- Newlines are replaced with spaces
- Multiple spaces are collapsed to single spaces
- Leading/trailing spaces are trimmed

## Troubleshooting

### Common Issues

**Error: `python3: command not found`**
- Install Python 3 from [python.org](https://python.org)

**Error: `No module named 'whisper'`**
- Install Whisper: `pip install openai-whisper`

**Error: `Permission denied`**
- Make script executable: `chmod +x GetTranscriptionFromAudioFiles.sh`

**No audio files found**
- Check that your audio files are in the correct input directory
- Verify file extensions are supported (mp3, wav, m4a, flac)

**Transcription fails**
- Check available disk space
- Ensure audio files are not corrupted
- Try a smaller Whisper model if running out of memory

### File Paths with Spaces

The script handles file paths with spaces and special characters correctly using proper bash techniques.

## Performance Notes

- Larger models provide better accuracy but are slower
- Processing time depends on audio length and model size
- The script processes files sequentially, not in parallel
- Consider using `tiny` or `base` models for faster processing of large batches

## Output Structure

```
project-directory/
├── GetTranscriptionFromAudioFiles.sh    # The main script
├── audios/                          # Your input audio files
│   ├── recording1.mp3
│   └── recording2.wav
└── transcripts/                     # Generated transcripts
    ├── recording1.txt
    └── recording2.txt
```