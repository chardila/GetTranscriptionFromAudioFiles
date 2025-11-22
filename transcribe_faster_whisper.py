#!/usr/bin/env python3
"""
Transcription script using faster-whisper for efficient audio transcription.
"""

import argparse
import sys
from pathlib import Path
from faster_whisper import WhisperModel


def transcribe_audio(
    audio_file: str,
    model_name: str,
    output_dir: str,
    language: str = None,
    device: str = "auto",
    compute_type: str = "auto"
) -> bool:
    """
    Transcribe an audio file using faster-whisper.

    Args:
        audio_file: Path to the audio file to transcribe
        model_name: Name of the Whisper model (tiny, base, small, medium, large)
        output_dir: Directory to save the transcript
        language: Language code (e.g., 'en', 'es') or None for auto-detection
        device: Device to use ('cpu', 'cuda', or 'auto')
        compute_type: Compute type ('int8', 'int8_float16', 'int16', 'float16', 'float32', or 'auto')

    Returns:
        bool: True if successful, False otherwise
    """
    try:
        # Determine device and compute type
        if device == "auto":
            try:
                import torch
                device = "cuda" if torch.cuda.is_available() else "cpu"
            except ImportError:
                device = "cpu"

        if compute_type == "auto":
            compute_type = "int8" if device == "cpu" else "float16"

        print(f"Loading model '{model_name}' on {device} with {compute_type}...", file=sys.stderr)

        # Initialize the model
        model = WhisperModel(model_name, device=device, compute_type=compute_type)

        print(f"Transcribing: {audio_file}", file=sys.stderr)

        # Transcribe the audio
        segments, info = model.transcribe(
            audio_file,
            language=language,
            beam_size=5,
            vad_filter=True,  # Voice activity detection for better accuracy
            vad_parameters=dict(min_silence_duration_ms=500)
        )

        # Collect all segments
        transcript_text = []
        for segment in segments:
            transcript_text.append(segment.text.strip())

        # Join all segments
        # Join all segments into a single line
        full_transcript = " ".join(transcript_text).replace("\n", " ").strip()
        
        # Prepare output file path
        audio_path = Path(audio_file)
        output_path = Path(output_dir) / f"{audio_path.stem}.txt"
        
        # Atomic write: write to temp file then rename
        temp_path = output_path.with_suffix(".tmp")
        try:
            temp_path.write_text(full_transcript, encoding='utf-8')
            temp_path.replace(output_path)
        except Exception as e:
            if temp_path.exists():
                temp_path.unlink()
            raise e

        print(f"Detected language: {info.language} (probability: {info.language_probability:.2f})", file=sys.stderr)
        print(f"Transcript saved to: {output_path}", file=sys.stderr)

        return True

    except Exception as e:
        print(f"ERROR: Transcription failed: {e}", file=sys.stderr)
        return False


def main():
    """Main entry point for the script."""
    parser = argparse.ArgumentParser(
        description="Transcribe audio files using faster-whisper"
    )
    parser.add_argument(
        "audio_file",
        help="Path to the audio file to transcribe"
    )
    parser.add_argument(
        "--model",
        default="small",
        choices=["tiny", "base", "small", "medium", "large", "large-v2", "large-v3"],
        help="Whisper model to use (default: small)"
    )
    parser.add_argument(
        "--output_dir",
        default="transcripts",
        help="Output directory for transcripts (default: transcripts)"
    )
    parser.add_argument(
        "--language",
        default=None,
        help="Language code (e.g., en, es, fr) or omit for auto-detection"
    )
    parser.add_argument(
        "--device",
        default="auto",
        choices=["auto", "cpu", "cuda"],
        help="Device to use for inference (default: auto)"
    )
    parser.add_argument(
        "--compute_type",
        default="auto",
        choices=["auto", "int8", "int8_float16", "int16", "float16", "float32"],
        help="Compute type for inference (default: auto)"
    )

    args = parser.parse_args()

    # Create output directory if it doesn't exist
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Transcribe the audio file
    success = transcribe_audio(
        audio_file=args.audio_file,
        model_name=args.model,
        output_dir=str(output_dir),
        language=args.language,
        device=args.device,
        compute_type=args.compute_type
    )

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
