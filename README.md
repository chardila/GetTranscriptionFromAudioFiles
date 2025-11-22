# Audio File Transcription Tool

A professional audio transcription tool that batch processes audio files using faster-whisper for efficient speech recognition. Features a bash orchestrator with a comprehensive CLI and a Python backend optimized for performance with GPU acceleration support.

## ✨ Features

- **faster-whisper engine** for optimized performance (up to 4x faster than OpenAI Whisper)
- **GPU acceleration** support with automatic CUDA detection
- **Voice Activity Detection (VAD)** for improved transcription accuracy
- **Automatic device selection** (CPU/GPU) and compute type optimization
- **Command-line interface** with comprehensive options
- **Parallel processing** support for faster batch execution
- **Smart file skipping** to avoid re-processing existing transcripts
- **Automatic dependency validation** (Python 3, faster-whisper, ffmpeg)
- **Virtual environment detection** (.venv support)
- **Progress tracking** with `[2/10]` style indicators
- **Color-coded output** for better visibility
- **MIME type validation** for audio files
- **Robust error handling** with detailed messages
- **Safe temporary file handling** with automatic cleanup
- **Interrupt protection** (Ctrl+C handling)
- **Verbose mode** for debugging
- **Single-line transcript conversion** for easier processing
- **Language detection** with confidence scores

## 🔧 Prerequisites

The script automatically validates these dependencies at startup:

1. **Python 3** - Download from [python.org](https://python.org)
2. **faster-whisper** - Install with:
   ```bash
   pip install faster-whisper
   ```

   **Why faster-whisper?**
   - Up to 4x faster than OpenAI Whisper
   - Lower memory usage
   - GPU acceleration support (optional)
   - Built on CTranslate2 for optimized inference
   - Voice Activity Detection (VAD) included

3. **Optional: CUDA** for GPU acceleration
   - Automatically detected if available
   - Falls back to CPU if not present

## 🎵 Supported Audio Formats

- **MP3** (.mp3)
- **WAV** (.wav)
- **M4A** (.m4a)
- **FLAC** (.flac)
- **MP4** (.mp4, video files are supported if they contain audio)

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
    -j, --jobs N        Number of parallel jobs (default: 1)
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

With faster-whisper, all models run significantly faster than the standard OpenAI Whisper implementation:

| Model    | Size     | Speed        | Accuracy | Memory Usage | Notes                |
|----------|----------|--------------|----------|--------------|----------------------|
| tiny     | 39 MB    | Very Fast    | Lowest   | ~1 GB        | Good for quick tests |
| base     | 74 MB    | Fast         | Low      | ~1 GB        | Real-time capable    |
| small    | 244 MB   | Medium       | Medium   | ~2 GB        | Balanced (default)   |
| medium   | 769 MB   | Moderate     | High     | ~5 GB        | Production quality   |
| large    | 1550 MB  | Slower       | Highest  | ~10 GB       | Best accuracy        |
| large-v2 | 1550 MB  | Slower       | Highest  | ~10 GB       | Improved large       |
| large-v3 | 1550 MB  | Slower       | Highest  | ~10 GB       | Latest large model   |

**Performance boost with faster-whisper:**
- CPU: ~4x faster than standard Whisper
- GPU: Even faster with CUDA acceleration
- Lower memory footprint across all models

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

### Parallel Processing
```bash
# Process 4 files at a time
./GetTranscriptionFromAudioFiles.sh -j 4

# Combine parallel processing with other options
./GetTranscriptionFromAudioFiles.sh -j 2 -m medium -l en
```
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
   - Checks for Python 3 and faster-whisper installation
   - Validates input directory exists and contains audio files
   - Verifies model and language parameters

2. **📊 Configuration Display**:
   - Shows all settings being used
   - Displays detected device (CPU/GPU)
   - Counts total files to process

3. **🎵 Processing Phase**:
   - Progress tracking: `[2/10] Processing: recording.mp3`
   - MIME type validation for each audio file
   - Automatic device selection (GPU if available, else CPU)
   - Compute type optimization (int8 for CPU, float16 for GPU)
   - Voice Activity Detection (VAD) for better accuracy
   - faster-whisper transcription with error handling
   - Language detection with confidence scores
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

**Error: `faster-whisper is not installed`**
```bash
pip install faster-whisper
# Or with conda: conda install -c conda-forge faster-whisper
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
- **Network issues**: faster-whisper downloads models on first use
- **GPU issues**: Script automatically falls back to CPU if GPU fails

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
├── GetTranscriptionFromAudioFiles.sh    # Main bash orchestrator with CLI
├── transcribe_faster_whisper.py         # Python backend for transcription
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

## 🏛️ Architecture

The tool consists of two components working together:

1. **Bash Orchestrator** (`GetTranscriptionFromAudioFiles.sh`):
   - Professional CLI with argument parsing
   - Dependency validation and configuration management
   - File discovery and batch processing
   - Progress tracking and error handling
   - Output formatting (single-line conversion)

2. **Python Backend** (`transcribe_faster_whisper.py`):
   - faster-whisper integration for efficient transcription
   - Automatic device selection (CPU/CUDA)
   - Compute type optimization
   - Voice Activity Detection (VAD)
   - Language detection with confidence scores
   - Segment processing and text joining

## 🔒 Safety Features

- **Automatic cleanup**: Temporary files removed on exit/interrupt
- **Safe file handling**: Uses `mktemp` for temporary files
- **Input validation**: Comprehensive checks before processing
- **Error recovery**: Continues processing other files if one fails
- **Interrupt handling**: Clean shutdown with Ctrl+C

## ⚡ Performance Tips

- **GPU acceleration**: If you have an NVIDIA GPU with CUDA, faster-whisper will automatically use it
- **For speed**: Use `tiny` or `base` models (already very fast with faster-whisper)
- **For accuracy**: Use `medium`, `large`, or `large-v3` models
- **For unknown languages**: Use `--lang auto` (automatic detection)
- **For debugging**: Always use `--verbose` flag to see device selection
- **For large batches**: faster-whisper uses less memory, but still process in groups if needed
- **CPU optimization**: The tool automatically uses int8 quantization on CPU for efficiency
- **GPU optimization**: Automatically uses float16 on GPU for speed and memory efficiency

## 🎛️ Advanced Configuration

The Python backend (`transcribe_faster_whisper.py`) can be called directly for more control:

```bash
python3 transcribe_faster_whisper.py audio.mp3 \
    --model medium \
    --language es \
    --device cuda \
    --compute_type float16 \
    --output_dir transcripts
```

Available options:
- `--device`: cpu, cuda, or auto (default: auto)
- `--compute_type`: int8, int8_float16, int16, float16, float32, or auto (default: auto)
- VAD is always enabled for better accuracy

## 🤝 Contributing

This tool is designed to be simple and focused. For bugs or feature requests, please check the repository issues.

## 📄 License

This project is open source. See the repository for license details.