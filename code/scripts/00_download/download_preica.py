from pathlib import Path
import shutil

import pandas as pd
from huggingface_hub import list_repo_files, hf_hub_download


# ==========================================
# 設定
# ==========================================

# Hugging Face のデータセット
REPO_ID = "L-FAME-Dataset-Benchmark/L-FAME"

# プロジェクトのルート
ROOT_DIR = Path(
    r"C:\MATLAB\focused-attention-meditation-eeg-analysis"
)

# 被験者情報
PARTICIPANTS_TSV = ROOT_DIR / "participants.tsv"

# 保存先
# data/preprocessed/sub-001/pre/restCE01/...
DATA_DIR = ROOT_DIR / "data" / "preprocessed"

# 使用する4条件
# restOE（開眼安静）は使わない
TASKS = [
    "restCE01",
    "Medita",
    "restCE02",
    "slMedita",
]


# ==========================================
# 被験者IDを3桁に統一
# ==========================================

def normalize_subject_id(subject):
    """
    被験者IDを3桁表記に統一する。

    例
    ----
    sub-01  -> sub-001
    sub-1   -> sub-001
    sub-001 -> sub-001
    """

    number = int(subject.replace("sub-", ""))

    return f"sub-{number:03d}"


# ==========================================
# pre / post の被験者を取得
# ==========================================

def get_subjects():
    """
    participants.tsv から、
    pre と post のデータがある被験者を取得する。
    """

    df = pd.read_csv(
        PARTICIPANTS_TSV,
        sep="\t"
    )

    # preあり
    pre_subjects = df.loc[
        df["pre_test"] == "done",
        "participant_id"
    ].tolist()

    # postあり
    post_subjects = df.loc[
        df["post_test"] == "done",
        "participant_id"
    ].tolist()

    return pre_subjects, post_subjects


# ==========================================
# 必要なファイル名を作る
# ==========================================

def make_targets(subjects, session):
    """
    各被験者 × 4条件について、
    必要な .set / .fdt ファイル名を作る。
    """

    targets = []

    for subject in subjects:

        subject_id = normalize_subject_id(subject)

        for task in TASKS:

            base_name = (
                f"{subject_id}_"
                f"{session}_"
                f"task-{task}_"
                f"eeg_preproc_preica"
            )
            
            # 命名規則より
            targets.append({
                "subject": subject_id,
                "session": session,
                "task": task,
                "set_filename": base_name + ".set",
                "fdt_filename": base_name + ".fdt",
            })

    return targets


# ==========================================
# Hugging Face上のファイルを探す
# ==========================================

def find_remote_path(repo_files, filename):
    """
    指定したファイル名が
    Hugging Face上のどこにあるか探す。
    """

    matches = [
        path
        for path in repo_files
        if path.endswith(filename)
    ]

    if len(matches) == 0:
        return None

    return matches[0]


# ==========================================
# 1ファイルをダウンロード
# ==========================================

def download_file(remote_path, output_dir):
    """
    Hugging Faceからファイルを取得し、
    指定した研究用フォルダへコピーする。
    """

    # 保存先フォルダを作る
    output_dir.mkdir(
        parents=True,
        exist_ok=True
    )

    filename = Path(remote_path).name

    output_path = (
        output_dir
        / filename
    )

    # すでに研究フォルダにあれば再ダウンロードしない
    if output_path.exists():

        print(
            "Skip:",
            output_path
        )

        return False

    # Hugging Face のキャッシュにダウンロード
    cached_path = hf_hub_download(
        repo_id=REPO_ID,
        filename=remote_path,
        repo_type="dataset"
    )

    # キャッシュから研究フォルダへコピー
    shutil.copy2(
        cached_path,
        output_path
    )

    print(
        "Saved:",
        output_path
    )

    return True


# ==========================================
# session名を保存用の pre / post に変換
# ==========================================

def get_session_dir(session):
    """
    Hugging Face上のsession名を
    ローカル保存用の短い名前に変換する。
    """

    if session == "ses-premedita":
        return "pre"

    if session == "ses-posmedita":
        return "post"

    raise ValueError(
        f"Unknown session: {session}"
    )


# ==========================================
# メイン処理
# ==========================================

def main():

    print("========================================")
    print("L-FAME preica download")
    print("========================================")

    # --------------------------------------
    # Hugging Face上のファイル一覧
    # --------------------------------------

    print("\nGetting repository file list...")

    repo_files = list_repo_files(
        repo_id=REPO_ID,
        repo_type="dataset"
    )

    print(
        "Repository files:",
        len(repo_files)
    )

    # --------------------------------------
    # 被験者取得
    # --------------------------------------

    pre_subjects, post_subjects = get_subjects()

    print("\n=== Subjects ===")
    print("Pre :", len(pre_subjects))
    print("Post:", len(post_subjects))

    # --------------------------------------
    # 必要な条件一覧を作成
    # --------------------------------------

    targets = []

    # pre 74人
    targets += make_targets(
        pre_subjects,
        "ses-premedita"
    )

    # post 44人
    targets += make_targets(
        post_subjects,
        "ses-posmedita"
    )

    print(
        "Conditions:",
        len(targets)
    )

    # --------------------------------------
    # 集計用
    # --------------------------------------

    set_found = 0
    fdt_found = 0

    set_saved = 0
    fdt_saved = 0

    missing_set = []

    # ======================================
    # 各被験者・条件を処理
    # ======================================

    for i, item in enumerate(
        targets,
        start=1
    ):

        subject = item["subject"]
        session = item["session"]
        task = item["task"]

        # ses-premedita → pre
        # ses-posmedita → post
        session_dir = get_session_dir(
            session
        )

        print("\n----------------------------------------")
        print(
            f"[{i}/{len(targets)}] "
            f"{subject} / {session_dir} / {task}"
        )

        # ----------------------------------
        # 保存先
        #
        # data/
        # └─ preprocessed/
        #    └─ sub-001/
        #       └─ pre/
        #          └─ restCE01/
        # ----------------------------------

        output_dir = (
            DATA_DIR
            / subject
            / session_dir
            / task
        )

        # ==================================
        # .set
        # ==================================

        set_remote = find_remote_path(
            repo_files,
            item["set_filename"]
        )

        if set_remote is None:

            print(
                "SET not found:",
                item["set_filename"]
            )

            missing_set.append(
                item["set_filename"]
            )

        else:

            set_found += 1

            downloaded = download_file(
                set_remote,
                output_dir
            )

            if downloaded:
                set_saved += 1

        # ==================================
        # .fdt
        # ==================================

        fdt_remote = find_remote_path(
            repo_files,
            item["fdt_filename"]
        )

        # .fdt は存在する場合だけ取得
        if fdt_remote is not None:

            fdt_found += 1

            downloaded = download_file(
                fdt_remote,
                output_dir
            )

            if downloaded:
                fdt_saved += 1

        else:

            print(
                "FDT not present "
                "-> SET-only format"
            )

    # ======================================
    # 最終結果
    # ======================================

    print("\n========================================")
    print("Download summary")
    print("========================================")

    print(
        "Total conditions :",
        len(targets)
    )

    print(
        "SET found        :",
        set_found
    )

    print(
        "FDT found        :",
        fdt_found
    )

    print(
        "SET newly saved  :",
        set_saved
    )

    print(
        "FDT newly saved  :",
        fdt_saved
    )

    print(
        "Missing SET      :",
        len(missing_set)
    )

    # .set が欠けていた場合だけ表示
    if missing_set:

        print("\n=== Missing SET files ===")

        for filename in missing_set:
            print(filename)

    else:

        print(
            "\nAll required SET files were found."
        )


# ==========================================
# このファイルを直接実行したときだけ動く
# ==========================================

if __name__ == "__main__":
    main()