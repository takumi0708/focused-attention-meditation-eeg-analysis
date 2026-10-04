from pathlib import Path
import pandas as pd


# ==========================================
# パス設定
# ==========================================

# プロジェクトのルート
ROOT_DIR = Path(
    r"C:\MATLAB\focused-attention-meditation-eeg-analysis"
)

# 前処理済みEEGデータの保存先
DATA_DIR = (
    ROOT_DIR
    / "data"
    / "derivatives"
    / "eeglab_preproc"
)

# 被験者情報
PARTICIPANTS_TSV = ROOT_DIR / "participants.tsv"

# このPythonファイルがあるフォルダ
SCRIPT_DIR = Path(__file__).resolve().parent


# ==========================================
# 使用する4条件
# ==========================================

# restOE（開眼安静）は使わない
TASKS = [
    "restCE01",
    "Medita",
    "restCE02",
    "slMedita",
]


# ==========================================
# 被験者IDを3桁表記に統一
# ==========================================

def normalize_subject_id(subject):
    """
    participant.tsv の被験者IDを、
    実際のファイル名に合わせて3桁表記に統一する。

    例
    ----
    sub-01  -> sub-001
    sub-1   -> sub-001
    sub-001 -> sub-001
    """

    number = int(
        subject.replace("sub-", "")
    )

    return f"sub-{number:03d}"


# ==========================================
# pre / post の対象被験者を取得
# ==========================================

def get_subjects():
    """
    participants.tsv を読み込み、
    pre と post のデータが存在する被験者を取得する。

    Returns
    -------
    pre_subjects : list
        pre_test が done の被験者

    post_subjects : list
        post_test が done の被験者
    """

    # TSV読み込み
    df = pd.read_csv(
        PARTICIPANTS_TSV,
        sep="\t"
    )

    # pre_test が done の被験者
    pre_subjects = df.loc[
        df["pre_test"] == "done",
        "participant_id"
    ].tolist()

    # post_test が done の被験者
    post_subjects = df.loc[
        df["post_test"] == "done",
        "participant_id"
    ].tolist()

    return pre_subjects, post_subjects


# ==========================================
# preicaファイル確認
# ==========================================

def check_files(subjects, session_name):
    """
    各被験者・各条件について、
    preicaの .set と .fdt が両方存在するか確認する。

    Parameters
    ----------
    subjects : list
        確認する被験者一覧

    session_name : str
        ses-premedita
        または
        ses-posmedita

    Returns
    -------
    results : list
        ファイル確認結果
    """

    results = []

    # 被験者ごとに確認
    for subject in subjects:

        # sub-01 -> sub-001 に変換
        subject_id = normalize_subject_id(subject)

        # EEGデータのディレクトリ
        eeg_dir = (
            DATA_DIR
            / subject_id
            / session_name
            / "eeg"
        )

        # 4条件を確認
        for task in TASKS:

            # ==================================
            # 想定されるファイル名を作成
            # ==================================

            set_filename = (
                f"{subject_id}_"
                f"{session_name}_"
                f"task-{task}_"
                f"eeg_preproc_preica.set"
            )

            fdt_filename = (
                f"{subject_id}_"
                f"{session_name}_"
                f"task-{task}_"
                f"eeg_preproc_preica.fdt"
            )

            # ファイルのフルパス
            set_path = eeg_dir / set_filename
            fdt_path = eeg_dir / fdt_filename

            # ==================================
            # ファイルが存在するか確認
            # ==================================

            set_exists = set_path.exists()
            fdt_exists = fdt_path.exists()

            # .set と .fdt が両方あればcomplete
            complete = (
                set_exists
                and fdt_exists
            )

            # 結果を保存
            results.append({
                "subject": subject_id,
                "session": session_name,
                "task": task,
                "set_exists": set_exists,
                "fdt_exists": fdt_exists,
                "complete": complete,
                "set_path": str(set_path),
                "fdt_path": str(fdt_path),
            })

    return results


# ==========================================
# メイン処理
# ==========================================

def main():

    # --------------------------------------
    # 基本パス確認
    # --------------------------------------

    print("=== Path check ===")
    print("ROOT_DIR :", ROOT_DIR)
    print("DATA_DIR :", DATA_DIR)
    print("DATA_DIR exists :", DATA_DIR.exists())

    # --------------------------------------
    # 被験者取得
    # --------------------------------------

    pre_subjects, post_subjects = get_subjects()

    print("\n=== Subjects ===")
    print("Pre subjects :", len(pre_subjects))
    print("Post subjects:", len(post_subjects))

    # --------------------------------------
    # ファイル確認
    # --------------------------------------

    results = []

    # pre
    results += check_files(
        pre_subjects,
        "ses-premedita"
    )

    # post
    results += check_files(
        post_subjects,
        "ses-posmedita"
    )

    # DataFrameへ変換
    df = pd.DataFrame(results)

    # --------------------------------------
    # 全結果表示
    # --------------------------------------

    print("\n=== All files ===")
    print(df)

    # --------------------------------------
    # 不足データだけ抽出
    # --------------------------------------

    missing_df = df[
        df["complete"] == False
    ]

    print("\n=== Missing files ===")
    print(missing_df)

    # --------------------------------------
    # 件数確認
    # --------------------------------------

    total_count = len(df)

    complete_count = (
        df["complete"]
        .sum()
    )

    missing_count = (
        total_count
        - complete_count
    )

    print("\n=== Summary ===")
    print("Total    :", total_count)
    print("Complete :", complete_count)
    print("Missing  :", missing_count)

    # --------------------------------------
    # CSV保存
    # --------------------------------------

    # 全データの確認結果
    output_all = (
        SCRIPT_DIR
        / "preica_file_check.csv"
    )

    df.to_csv(
        output_all,
        index=False,
        encoding="utf-8-sig"
    )

    # 不足データだけ
    output_missing = (
        SCRIPT_DIR
        / "missing_preica_files.csv"
    )

    missing_df.to_csv(
        output_missing,
        index=False,
        encoding="utf-8-sig"
    )

    print("\n=== Saved ===")
    print(output_all)
    print(output_missing)


# ==========================================
# このファイルを直接実行した場合だけ動かす
# ==========================================

if __name__ == "__main__":
    main()