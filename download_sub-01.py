from huggingface_hub import snapshot_download

snapshot_download(
    repo_id="L-FAME-Dataset-Benchmark/L-FAME",
    repo_type="dataset",
    allow_patterns=[
        "derivatives/eeglab_preproc/sub-001/**",
        "participants.tsv"
    ],
    local_dir="./data"
)