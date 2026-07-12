from faster_whisper import WhisperModel

# Initialize the model
model = WhisperModel("large-v3-turbo", device="cpu", compute_type="int8")  # Use "cuda" if you have NVIDIA GPU

print("Starting transcription...")
print("This will take a while for a 16-hour file...")

# Transcribe the audio
segments, info = model.transcribe(
    "Full Financial AI Course With Timestamp.m4a", 
    beam_size=5, 
    vad_filter=True
)

print(f"Detected language: {info.language}")
print(f"Transcription probability: {info.language_probability:.2f}")

# Save to file
with open("transcript.txt", "w", encoding="utf-8") as f:
    for segment in segments:
        f.write(segment.text + " ")
        
print("Done! Transcript saved to transcript.txt")
