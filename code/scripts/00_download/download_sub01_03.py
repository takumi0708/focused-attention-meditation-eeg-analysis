from pathlib import Path

from huggingface_hub import hf_hub_download


# ============================================================
# 設定
# ============================================================

REPO_ID = "L-FAME-Dataset-Benchmark/L-FAME"

SUBJECTS = [
    "sub-001",
    "sub-002",
    "sub-003",
]

SESSIONS = {
    "pre": "ses-premedita",
    "post": "ses-posmedita",
}

TASKS = [
    "restCE01",  # MW
    "slMedita",  # MF
]

# .set と .fdt の両方を取得
EXTENSIONS = [
    ".set",
    ".fdt",
]


# ============================================================
# プロジェクト
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[3]

DATA_DIR = PROJECT_ROOT / "data" / "preprocessed"

TEMP_DIR = PROJECT_ROOT / ".hf_download"


# ============================================================
# ダウンロード
# ============================================================

def download_data():

    for subject in SUBJECTS:

        for period, session in SESSIONS.items():

            save_dir = DATA_DIR / subject / period
            save_dir.mkdir(parents=True, exist_ok=True)

            for task in TASKS:

                # 拡張子ごとにダウンロード
                for extension in EXTENSIONS:

                    filename = (
                        f"derivatives/eeglab_preproc/"
                        f"{subject}/"
                        f"{session}/"
                        f"eeg/"
                        f"{subject}_{session}_task-{task}"
                        f"_eeg_preproc_icrm{extension}"
                    )

                    print()
                    print("=" * 60)
                    print(f"Subject   : {subject}")
                    print(f"Period    : {period}")
                    print(f"Task      : {task}")
                    print(f"Extension : {extension}")
                    print("=" * 60)

                    try:

                        downloaded_file = hf_hub_download(
                            repo_id=REPO_ID,
                            repo_type="dataset",
                            filename=filename,
                            local_dir=TEMP_DIR,
                        )

                        downloaded_file = Path(downloaded_file)

                        destination = save_dir / downloaded_file.name

                        # すでに存在する場合は削除
                        if destination.exists():
                            destination.unlink()

                        # 最終保存先へ移動
                        downloaded_file.replace(destination)

                        print(f"Saved: {destination}")

                    except Exception as e:

                        print("Download failed")
                        print(f"File: {filename}")
                        print(f"Error: {e}")


# ============================================================
# 実行
# ============================================================

if __name__ == "__main__":

    print("L-FAME download start")

    download_data()

    print()
    print("L-FAME download completed")