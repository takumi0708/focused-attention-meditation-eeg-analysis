from huggingface_hub import snapshot_download

snapshot_download(
    repo_id="L-FAME-Dataset-Benchmark/L-FAME",
    repo_type="dataset",

    allow_patterns=[
        # participants
        "participants.tsv",

        # -------------------------
        # Pre
        # MF = slMedita
        # -------------------------
        "derivatives/eeglab_preproc/sub-001/ses-premedita/eeg/*slMedita*icrm.set",

        # MW = restCE01
        "derivatives/eeglab_preproc/sub-001/ses-premedita/eeg/*restCE01*icrm.set",

        # Rest = restOE
        "derivatives/eeglab_preproc/sub-001/ses-premedita/eeg/*restOE*preica.set",
        "derivatives/eeglab_preproc/sub-001/ses-premedita/eeg/*restOE*preica.fdt",

        # -------------------------
        # Post
        # MF = slMedita
        # -------------------------
        "derivatives/eeglab_preproc/sub-001/ses-posmedita/eeg/*slMedita*icrm.set",

        # MW = restCE01
        "derivatives/eeglab_preproc/sub-001/ses-posmedita/eeg/*restCE01*icrm.set",

        # Rest = restOE
        "derivatives/eeglab_preproc/sub-001/ses-posmedita/eeg/*restOE*preica.set",
        "derivatives/eeglab_preproc/sub-001/ses-posmedita/eeg/*restOE*preica.fdt",
    ],

    local_dir="./data"
)
