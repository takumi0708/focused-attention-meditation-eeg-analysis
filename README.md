# focused-attention-meditation-eeg-analysis

L-FAME（Longitudinal Focused Attention Meditation EEG）データを用いた
瞑想時EEGの解析メモ・解析コードを管理するリポジトリ。

## 1. 目的

Focused Attention Meditation におけるEEGの個人差を調べる。

まずは公開データの構造を理解し、

- EEGデータの読み込み
- 前処理済みデータの確認
- 瞑想・安静状態の切り出し
- PSD（Power Spectral Density）の計算
- 被験者ごとの特徴の確認

を行う。

最終的には、瞑想状態における個人差を考慮した解析を検討する。

## 2. 使用データ

Dataset: L-FAME  
Longitudinal Focused Attention Meditation EEG Dataset

https://arxiv.org/abs/2605.22893

参加者：74名  
年齢：平均約22歳  
EEG：64 channel  
研究デザイン：6週間の縦断研究

瞑想グループ：

- BF : Breath Focus
- HK : Hare Krishna
- SA : SA-TA-NA-MA

測定：

- Pre-intervention
- Post-intervention

Postまで参加した被験者は44名。

## 3. EEG課題

1回のEEG測定では以下の順番で実施。

1. restOE
   - 2分
   - 開眼安静

2. restCE01
   - 4分
   - 閉眼
   - mind wandering

3. Medita
   - 8分
   - active meditation

4. restCE02
   - 4分
   - 閉眼安静

5. slMedita
   - 8分
   - silent meditation

主に

restCE01 = mind wandering / resting

slMedita = focused attention meditation

として比較できそう。

## 4. データ形式

Raw EEG：

- BrainVision形式
- .eeg
- .vhdr
- .vmrk

前処理済みEEG：

- EEGLAB .set
- .fdt

Machine Learning用：

- .npy

今回はまず前処理済みEEGLABデータを使用する予定。

## 5. 前処理

論文で提供されている前処理済みEEGでは、

- 1 Hz high-pass filter
- Zapline-plus
- ASR
- bad channel interpolation
- common average reference
- ICA
- ICLabel

などが実施されている。

まずは提供されているcleaned EEGを利用する。

## 6. 最初にやること

1. データセット全体のディレクトリ構造を確認
2. participants.tsvを確認
3. 1人分の `.set` をEEGLABで読み込む
4. channel数・sampling rate・データ長を確認
5. restCE01 と slMedita を確認
6. EEG波形を表示
7. PSDを計算
8. 1人 → 複数人へ解析を拡張

## 7. ディレクトリ構造

```text
focused-attention-meditation-eeg-analysis/
│
├── README.md                 # 研究目的・使用データ・解析方針・進捗をまとめる
├── .gitignore                # GitHubにアップロードしないファイルを指定する
├── LICENSE                   # リポジトリのライセンス
│
├── code/                     # MATLAB / EEGLABの解析コード
│   ├── 01_load_data.m        # EEGデータを読み込む
│   ├── 02_check_data.m       # ch数・サンプリング周波数・データ長などを確認
│   ├── 03_psd.m              # PSD・周波数解析を行う
│   └── 04_batch_analysis.m   # 複数被験者をまとめて解析する
│
├── data/                     # 解析に使用するEEGデータ（GitHubには上げない）
│   ├── raw/                  # 生データ（.eeg / .vhdr / .vmrk）
│   └── preprocessed/         # 前処理済みEEG（.set / .fdt）
│
├── results/                  # 解析によって得られた結果
│   ├── figures/              # EEG波形・PSD・比較グラフなどの画像
│   └── csv/                  # PSD・帯域パワーなどの数値データ
│
└── notes/                    # 解析中のメモ・判断・エラー記録
    └── analysis_log.md       # 日付ごとの解析ログ

```

## 8. 解析メモ

### 2026-08-13

- L-FAME解析開始
- MATLAB / EEGLABを使用
- GitHubリポジトリ作成
- まずREADMEを作成
