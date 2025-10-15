# Audio File Transcription Tool

A professional bash script that batch transcribes audio files using OpenAI's Whisper speech recognition model with comprehensive error handling, progress tracking, and command-line interface.

## ✨ Features

- **Command-line interface** with comprehensive options
- **Automatic dependency validation** (Python 3, Whisper)
- **Progress tracking** with `[2/10]` style indicators
- **Color-coded output** for better visibility
- **MIME type validation** for audio files
- **Robust error handling** with detailed messages
- **Safe temporary file handling** with automatic cleanup
- **Interrupt protection** (Ctrl+C handling)
- **Verbose mode** for debugging
- **Single-line transcript conversion** for easier processing

## 🔧 Prerequisites

The script automatically validates these dependencies at startup:

1. **Python 3** - Download from [python.org](https://python.org)
2. **OpenAI Whisper** - Install with:
   ```bash
   pip install openai-whisper
   ```

## 🎵 Supported Audio Formats

- **MP3** (.mp3)
- **WAV** (.wav)
- **M4A** (.m4a)
- **FLAC** (.flac)

## 🚀 Quick Start

1. **Make the script executable**:
   ```bash
   chmod +x GetTranscriptionFromAudioFiles.sh
   ```

2. **Create input directory and add audio files**:
   ```bash
   mkdir audios
   # Copy your audio files to the audios directory
   ```

3. **Run with default settings**:
   ```bash
   ./GetTranscriptionFromAudioFiles.sh
   ```

4. **Find your transcripts** in the `transcripts` directory

## 📋 Command-Line Options

```bash
Usage: ./GetTranscriptionFromAudioFiles.sh [OPTIONS]

OPTIONS:
    -i, --input DIR     Input directory containing audio files (default: audios)
    -o, --output DIR    Output directory for transcripts (default: transcripts)
    -m, --model MODEL   Whisper model: tiny|base|small|medium|large (default: small)
    -l, --lang LANG     Language code (e.g., en, es, fr) or 'auto' (default: es)
    -v, --verbose       Enable verbose output for debugging
    --no-mime-check     Skip MIME type validation of audio files
    -h, --help          Show help message

EXAMPLES:
    ./GetTranscriptionFromAudioFiles.sh                                    # Use defaults
    ./GetTranscriptionFromAudioFiles.sh -i recordings -o texts -m medium   # Custom settings
    ./GetTranscriptionFromAudioFiles.sh -l auto -v                         # Auto-detect language
    ./GetTranscriptionFromAudioFiles.sh --input "My Audio Files"           # Handle spaces
```

## 📊 Whisper Models

| Model  | Size     | Speed   | Accuracy | Memory Usage |
|--------|----------|---------|----------|--------------|
| tiny   | 39 MB    | Fastest | Lowest   | ~1 GB        |
| base   | 74 MB    | Fast    | Low      | ~1 GB        |
| small  | 244 MB   | Medium  | Medium   | ~2 GB        |
| medium | 769 MB   | Slow    | High     | ~5 GB        |
| large  | 1550 MB  | Slowest | Highest  | ~10 GB       |

## 🌍 Language Support

- **Automatic detection**: `--lang auto`
- **Specific languages**: `--lang en` (English), `--lang es` (Spanish), `--lang fr` (French), etc.
- **Default**: Spanish (`es`)

Common language codes: `en`, `es`, `fr`, `de`, `it`, `pt`, `ru`, `ja`, `ko`, `zh`

## 💡 Usage Examples

### Basic Usage
```bash
# Process all audio files in 'audios' directory
./GetTranscriptionFromAudioFiles.sh
```

### Custom Directories
```bash
# Use custom input and output directories
./GetTranscriptionFromAudioFiles.sh -i "My Recordings" -o "My Transcripts"
```

### Different Models and Languages
```bash
# Use medium model with English
./GetTranscriptionFromAudioFiles.sh -m medium -l en

# Auto-detect language with verbose output
./GetTranscriptionFromAudioFiles.sh -l auto -v

# High accuracy for important recordings
./GetTranscriptionFromAudioFiles.sh -m large -l auto -v
```

### Debugging and Troubleshooting
```bash
# Verbose mode shows detailed information
./GetTranscriptionFromAudioFiles.sh -v

# Skip MIME validation for problematic files
./GetTranscriptionFromAudioFiles.sh --no-mime-check -v
```

## 🎯 What Happens During Execution

1. **🔍 Validation Phase**:
   - Checks for Python 3 and Whisper installation
   - Validates input directory exists and contains audio files
   - Verifies model and language parameters

2. **📊 Configuration Display**:
   - Shows all settings being used
   - Counts total files to process

3. **🎵 Processing Phase**:
   - Progress tracking: `[2/10] Processing: recording.mp3`
   - MIME type validation for each audio file
   - Whisper transcription with error handling
   - Converts multi-line output to single-line format

4. **📈 Summary Report**:
   - Total files processed successfully
   - Number of failed files (if any)
   - Location of generated transcripts

## 📝 Output Format

- **Single-line format**: Newlines replaced with spaces
- **Clean text**: Multiple spaces collapsed, trimmed edges
- **UTF-8 encoding**: Supports international characters
- **Same basename**: `recording.mp3` → `recording.txt`

## 🛠️ Troubleshooting

### Dependency Issues

**Error: `python3 is not installed`**
```bash
# Install Python 3 from https://python.org
# Or on macOS: brew install python3
# Or on Ubuntu: sudo apt install python3
```

**Error: `OpenAI Whisper is not installed`**
```bash
pip install openai-whisper
# Or with conda: conda install -c conda-forge openai-whisper
```

### File and Directory Issues

**Error: `Input directory does not exist`**
```bash
# Create the directory:
mkdir audios
# Or specify existing directory:
./GetTranscriptionFromAudioFiles.sh -i /path/to/existing/directory
```

**Error: `No audio files found`**
- Check file extensions are supported: `.mp3`, `.wav`, `.m4a`, `.flac`
- Use verbose mode to see what files are detected: `-v`
- Check file permissions are readable

### Processing Issues

**Error: `Whisper failed for file`**
- **Corrupted file**: Try playing the audio file first
- **Unsupported format**: Convert to a supported format
- **Memory issues**: Try a smaller model (`tiny` or `base`)
- **Network issues**: Whisper downloads models on first use

**Warning: `File may not be valid audio`**
- The file doesn't have a proper audio MIME type
- Try `--no-mime-check` to skip validation
- Convert file to a standard audio format

### Performance Issues

**Slow processing**
- Use smaller model: `-m tiny` or `-m base`
- Check available RAM (large models need ~10GB)
- Consider processing files in smaller batches

**Out of memory errors**
- Use smaller model: `-m tiny` (uses ~1GB RAM)
- Close other applications
- Process fewer files at once

## 🏗️ Project Structure

```
GetTranscriptionFromAudioFiles/
├── GetTranscriptionFromAudioFiles.sh    # Main script
├── README.md                            # This documentation
├── CLAUDE.md                            # Development guide
├── .gitignore                          # Git ignore rules
├── audios/                             # Input directory (create this)
│   ├── interview1.mp3
│   ├── meeting2.wav
│   └── presentation3.m4a
└── transcripts/                        # Output directory (auto-created)
    ├── interview1.txt
    ├── meeting2.txt
    └── presentation3.txt
```

## 🔒 Safety Features

- **Automatic cleanup**: Temporary files removed on exit/interrupt
- **Safe file handling**: Uses `mktemp` for temporary files
- **Input validation**: Comprehensive checks before processing
- **Error recovery**: Continues processing other files if one fails
- **Interrupt handling**: Clean shutdown with Ctrl+C

## ⚡ Performance Tips

- **For speed**: Use `tiny` or `base` models
- **For accuracy**: Use `medium` or `large` models
- **For unknown languages**: Use `--lang auto`
- **For debugging**: Always use `--verbose` flag
- **For large batches**: Process in smaller groups to avoid memory issues

## 🤝 Contributing

This tool is designed to be simple and focused. For bugs or feature requests, please check the repository issues.

## 📄 License

This project is open source. See the repository for license details.