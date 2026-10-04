from pathlib import Path

import pandas as pd
from huggingface_hub import list_repo_files


# ==========================================
# 設定
# ==========================================

# Hugging Face のデータセット
REPO_ID = "L-FAME-Dataset-Benchmark/L-FAME"

# プロジェクトルート
ROOT_DIR = Path(
    r"C:\MATLAB\focused-attention-meditation-eeg-analysis"
)

# 被験者情報
PARTICIPANTS_TSV = ROOT_DIR / "participants.tsv"

# このスクリプトがある場所
SCRIPT_DIR = Path(__file__).resolve().parent


# 今回使用する4条件
# restOE（開眼安静）は使わない
TASKS = [
    "restCE01",
    "Medita",
    "restCE02",
    "slMedita",
]


# ==========================================
# 被験者IDをファイル名に合わせる
# ==========================================

def normalize_subject_id(subject):
    """
    participants.tsv のIDを
    Hugging Face上のファイル名に合わせて3桁にする。

    sub-01  -> sub-001
    sub-1   -> sub-001
    sub-001 -> sub-001
    """

    number = int(
        subject.replace("sub-", "")
    )

    return f"sub-{number:03d}"


# ==========================================
# Pre / Post の対象被験者を取得
# ==========================================

def get_subjects():
    """
    participants.tsv から、
    Pre / Post の記録がある被験者を取得する。
    """

    df = pd.read_csv(
        PARTICIPANTS_TSV,
        sep="\t"
    )

    # Preデータあり
    pre_subjects = df.loc[
        df["pre_test"] == "done",
        "participant_id"
    ].tolist()

    # Postデータあり
    post_subjects = df.loc[
        df["post_test"] == "done",
        "participant_id"
    ].tolist()

    return pre_subjects, post_subjects


# ==========================================
# 必要なファイル名を作る
# ==========================================

def make_expected_files(subjects, session_name):
    """
    各被験者 × 4条件について、
    必要なpreicaの .set / .fdt ファイル名を作る。
    """

    results = []

    for subject in subjects:

        subject_id = normalize_subject_id(subject)

        for task in TASKS:

            # .set
            set_filename = (
                f"{subject_id}_"
                f"{session_name}_"
                f"task-{task}_"
                f"eeg_preproc_preica.set"
            )

            # .fdt
            fdt_filename = (
                f"{subject_id}_"
                f"{session_name}_"
                f"task-{task}_"
                f"eeg_preproc_preica.fdt"
            )

            results.append({
                "subject": subject_id,
                "session": session_name,
                "task": task,
                "set_filename": set_filename,
                "fdt_filename": fdt_filename,
            })

    return results


# ==========================================
# メイン処理
# ==========================================

def main():

    # --------------------------------------
    # Hugging Face上の全ファイル一覧を取得
    # --------------------------------------

    print("=== Hugging Face file list ===")
    print("Repository:", REPO_ID)

    repo_files = list_repo_files(
        repo_id=REPO_ID,
        repo_type="dataset"
    )

    print("Files in repository:", len(repo_files))

    # ファイルパス → ファイル名だけにする
    #
    # 例:
    # derivatives/.../sub-001_....set
    # ↓
    # sub-001_....set
    #
    remote_filenames = {
        Path(filepath).name
        for filepath in repo_files
    }

    # --------------------------------------
    # 対象被験者を取得
    # --------------------------------------

    pre_subjects, post_subjects = get_subjects()

    print("\n=== Subjects ===")
    print("Pre :", len(pre_subjects))
    print("Post:", len(post_subjects))

    # --------------------------------------
    # 必要ファイル一覧を作成
    # --------------------------------------

    expected = []

    # Pre
    expected += make_expected_files(
        pre_subjects,
        "ses-premedita"
    )

    # Post
    expected += make_expected_files(
        post_subjects,
        "ses-posmedita"
    )

    # --------------------------------------
    # Hugging Face上に存在するか確認
    # --------------------------------------

    results = []

    for item in expected:

        set_exists = (
            item["set_filename"]
            in remote_filenames
        )

        fdt_exists = (
            item["fdt_filename"]
            in remote_filenames
        )

        results.append({
            "subject": item["subject"],
            "session": item["session"],
            "task": item["task"],
            "set_exists": set_exists,
            "fdt_exists": fdt_exists,
            "complete": set_exists and fdt_exists,
            "set_filename": item["set_filename"],
            "fdt_filename": item["fdt_filename"],
        })

    df = pd.DataFrame(results)

    # --------------------------------------
    # 不足しているものだけ取得
    # --------------------------------------

    missing_df = df[
        df["complete"] == False
    ]

    # --------------------------------------
    # 集計
    # --------------------------------------

    print("\n=== Summary ===")

    print("Conditions checked :", len(df))
    print(
        "Complete :",
        int(df["complete"].sum())
    )
    print(
        "Missing  :",
        len(missing_df)
    )

    print("\nExpected:")
    print("Pre :", len(pre_subjects) * len(TASKS))
    print("Post:", len(post_subjects) * len(TASKS))

    # --------------------------------------
    # 不足があれば表示
    # --------------------------------------

    if len(missing_df) == 0:

        print(
            "\nAll required preica files "
            "exist on Hugging Face."
        )

    else:

        print("\n=== Missing files ===")

        print(
            missing_df[
                [
                    "subject",
                    "session",
                    "task",
                    "set_exists",
                    "fdt_exists",
                ]
            ]
        )

    # --------------------------------------
    # CSV保存
    # --------------------------------------

    output_all = (
        SCRIPT_DIR
        / "remote_preica_file_check.csv"
    )

    output_missing = (
        SCRIPT_DIR
        / "remote_missing_preica_files.csv"
    )

    df.to_csv(
        output_all,
        index=False,
        encoding="utf-8-sig"
    )

    missing_df.to_csv(
        output_missing,
        index=False,
        encoding="utf-8-sig"
    )

    print("\n=== Saved ===")
    print(output_all)
    print(output_missing)


if __name__ == "__main__":
    main()