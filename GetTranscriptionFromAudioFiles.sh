#!/usr/bin/env bash
set -euo pipefail

# Default configuration
DEFAULT_INPUT_DIR="audios"
DEFAULT_OUTPUT_DIR="transcripts"
DEFAULT_MODEL="small"
DEFAULT_LANG="es"

# Initialize variables
INPUT_DIR="$DEFAULT_INPUT_DIR"
OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
MODEL="$DEFAULT_MODEL"
LANG="$DEFAULT_LANG"
VERBOSE=false
VALIDATE_MIME=true

# Temporary files tracking for cleanup
declare -a TEMP_FILES=()

# Colors for output
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Usage function
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Batch transcribe audio files using faster-whisper

OPTIONS:
    -i, --input DIR     Input directory containing audio files (default: $DEFAULT_INPUT_DIR)
    -o, --output DIR    Output directory for transcripts (default: $DEFAULT_OUTPUT_DIR)
    -m, --model MODEL   Whisper model: tiny|base|small|medium|large (default: $DEFAULT_MODEL)
    -l, --lang LANG     Language code (e.g., en, es, fr) or 'auto' (default: $DEFAULT_LANG)
    -v, --verbose       Enable verbose output
    --no-mime-check     Skip MIME type validation of audio files
    -h, --help          Show this help message

EXAMPLES:
    $0                                    # Use default settings
    $0 -i recordings -o texts -m medium   # Custom directories and model
    $0 -l auto -v                         # Auto-detect language with verbose output
    $0 --input "My Audio Files"           # Handle directories with spaces

SUPPORTED AUDIO FORMATS:
    MP3, WAV, M4A, FLAC

For more information, see the README.md file.
EOF
}

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✔${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*" >&2
}

log_error() {
    echo -e "${RED}✖${NC} $*" >&2
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}[VERBOSE]${NC} $*" >&2
    fi
}

# Cleanup function
cleanup() {
    local exit_code=$?
    log_verbose "Cleaning up temporary files..."
    for temp_file in "${TEMP_FILES[@]}"; do
        if [[ -f "$temp_file" ]]; then
            rm -f "$temp_file"
            log_verbose "Removed temporary file: $temp_file"
        fi
    done
    if [[ $exit_code -ne 0 ]]; then
        log_warning "Script interrupted or failed (exit code: $exit_code)"
    fi
    exit $exit_code
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Validate dependencies
validate_dependencies() {
    log_verbose "Validating dependencies..."

    if ! command -v python3 >/dev/null 2>&1; then
        log_error "python3 is not installed or not in PATH"
        log_error "Please install Python 3: https://python.org"
        exit 1
    fi

    log_verbose "Found python3: $(which python3)"

    if ! python3 -c "import faster_whisper" 2>/dev/null; then
        log_error "faster-whisper is not installed"
        log_error "Please install it with: pip install faster-whisper"
        exit 1
    fi

    log_verbose "faster-whisper is available"

    if [[ "$VALIDATE_MIME" == true ]] && ! command -v file >/dev/null 2>&1; then
        log_warning "file command not available, skipping MIME type validation"
        VALIDATE_MIME=false
    fi

    log_success "All dependencies validated"
}

# Validate audio file using MIME type
validate_audio_file() {
    local file="$1"

    if [[ "$VALIDATE_MIME" != true ]]; then
        return 0
    fi

    local mime_type
    mime_type=$(file --mime-type -b "$file" 2>/dev/null || echo "unknown")

    case "$mime_type" in
        audio/mpeg|audio/mp3|audio/wav|audio/x-wav|audio/wave|audio/x-m4a|audio/m4a|audio/flac|audio/x-flac)
            log_verbose "Validated audio file: $file (MIME: $mime_type)"
            return 0
            ;;
        *)
            log_warning "File may not be valid audio: $file (detected MIME: $mime_type)"
            log_warning "Proceeding anyway, but transcription may fail"
            return 1
            ;;
    esac
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--input)
                INPUT_DIR="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -m|--model)
                MODEL="$2"
                shift 2
                ;;
            -l|--lang)
                LANG="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --no-mime-check)
                VALIDATE_MIME=false
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use -h or --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Validate configuration
validate_config() {
    log_verbose "Validating configuration..."

    # Check input directory
    if [[ ! -d "$INPUT_DIR" ]]; then
        log_error "Input directory does not exist: $INPUT_DIR"
        log_error "Please create the directory and add audio files, or specify a different path with -i"
        exit 1
    fi

    # Check if input directory has audio files
    local audio_count
    audio_count=$(find "$INPUT_DIR" -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.m4a' -o -iname '*.flac' \) | wc -l)

    if [[ $audio_count -eq 0 ]]; then
        log_error "No audio files found in: $INPUT_DIR"
        log_error "Supported formats: MP3, WAV, M4A, FLAC"
        exit 1
    fi

    log_verbose "Found $audio_count audio files in input directory"

    # Validate model
    case "$MODEL" in
        tiny|base|small|medium|large)
            log_verbose "Using Whisper model: $MODEL"
            ;;
        *)
            log_error "Invalid model: $MODEL"
            log_error "Supported models: tiny, base, small, medium, large"
            exit 1
            ;;
    esac

    # Create output directory
    if ! mkdir -p "$OUTPUT_DIR"; then
        log_error "Failed to create output directory: $OUTPUT_DIR"
        exit 1
    fi

    log_verbose "Output directory ready: $OUTPUT_DIR"
    log_success "Configuration validated"
}

# Process a single audio file
process_audio_file() {
    local file="$1"
    local current="$2"
    local total="$3"

    local filename
    filename=$(basename "$file")
    local base="${filename%.*}"

    log_info "[$current/$total] Processing: $filename"

    # Validate audio file if MIME checking is enabled
    validate_audio_file "$file"

    # Get the directory where this script is located
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Prepare whisper command using faster-whisper Python script
    local whisper_cmd=(
        "python3" "$script_dir/transcribe_faster_whisper.py"
        "$file"
        "--model" "$MODEL"
        "--output_dir" "$OUTPUT_DIR"
    )

    # Add language parameter if not auto
    if [[ "$LANG" != "auto" ]]; then
        whisper_cmd+=("--language" "$LANG")
    fi

    log_verbose "Running: ${whisper_cmd[*]}"

    # Run whisper with error handling
    if ! "${whisper_cmd[@]}" 2>&1 | tee /tmp/whisper_output.log; then
        log_error "Whisper failed for: $file"
        log_error "This could be due to:"
        log_error "  - Corrupted or unsupported audio file"
        log_error "  - Insufficient memory for the model"
        log_error "  - Network issues (if downloading model)"
        return 1
    fi

    # Find the generated transcript
    local transcript="$OUTPUT_DIR/$base.txt"

    # Try alternative locations if not found
    if [[ ! -f "$transcript" ]]; then
        log_verbose "Transcript not found at expected location, searching..."
        transcript=$(find "$OUTPUT_DIR" -maxdepth 1 -type f -iname "${base}*.txt" -print -quit 2>/dev/null || echo "")
    fi

    if [[ -z "$transcript" ]] || [[ ! -f "$transcript" ]]; then
        log_error "Generated transcript file not found for: $file"
        log_error "Expected location: $OUTPUT_DIR/$base.txt"
        return 1
    fi

    log_verbose "Found transcript: $transcript"

    # Process transcript to single line format
    local temp_file
    temp_file=$(mktemp "$OUTPUT_DIR/${base}.txt.XXXXXX")
    TEMP_FILES+=("$temp_file")

    if tr '\n' ' ' < "$transcript" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//' > "$temp_file"; then
        if mv "$temp_file" "$OUTPUT_DIR/$base.txt"; then
            # Remove from cleanup array since we successfully moved it
            TEMP_FILES=("${TEMP_FILES[@]/$temp_file}")
            log_success "Saved: $OUTPUT_DIR/$base.txt"
            return 0
        else
            log_error "Failed to move processed transcript to final location"
            return 1
        fi
    else
        log_error "Failed to process transcript text"
        return 1
    fi
}

# Main processing function
main() {
    echo "🎤 Audio Transcription Tool with faster-whisper"
    echo "================================================="

    # Parse command line arguments
    parse_args "$@"

    # Validate dependencies and configuration
    validate_dependencies
    validate_config

    # Show configuration
    log_info "Configuration:"
    log_info "  Input directory:  $INPUT_DIR"
    log_info "  Output directory: $OUTPUT_DIR"
    log_info "  Whisper model:    $MODEL"
    log_info "  Language:         $LANG"
    log_info "  MIME validation:  $VALIDATE_MIME"
    echo

    # Count total files for progress tracking
    local total_files
    total_files=$(find "$INPUT_DIR" -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.m4a' -o -iname '*.flac' \) | wc -l)

    log_info "Processing $total_files audio files..."
    echo

    # Process files
    local processed=0
    local failed=0
    local current=0

    log_verbose "Starting file processing loop..."
    while IFS= read -r -d '' file; do
        ((current++)) || true
        log_verbose "Found file: $file"
        if process_audio_file "$file" "$current" "$total_files"; then
            ((processed++)) || true
        else
            ((failed++)) || true
        fi
        echo
    done < <(find "$INPUT_DIR" -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.m4a' -o -iname '*.flac' \) -print0)
    log_verbose "Finished file processing loop"

    # Summary
    echo "================================================="
    log_success "Processing complete!"
    log_info "Successfully processed: $processed files"
    if [[ $failed -gt 0 ]]; then
        log_warning "Failed to process: $failed files"
    fi
    log_info "Transcripts saved in: $OUTPUT_DIR"

    if [[ $failed -gt 0 ]]; then
        exit 1
    fi
}

# Run main function with all arguments
main "$@"