# focused-attention-meditation-eeg-analysis

L-FAME（Longitudinal Focused Attention Meditation EEG）データを用いた
瞑想時EEGの解析メモ・解析コードを管理するリポジトリ。

## 感じてる課題

マインドフルネス瞑想を実践していると、できているかどうか分からない、気が付いたら仕事や勉強のことに気が散ってしまっている課題を肌で感じていた。実際に、瞑想研究のアンケートでも多々そういった意見があった。

その対策として、現在は簡易脳波デバイスをつけて、リアルタイムで瞑想状態をフィードバックする仕組み（ニューロフィードバック）というものがある。
具体的な仕組みは、リラックスと関係のある脳波を検出する方法である。しかし、研究ではα波とリラックスの関係には個人差があり、汎用的に適切な瞑想状態の評価はできないとわかっている。

そこで、個人差を考慮した場合、瞑想状態の評価の汎用性が上がるのではないかと考えている。

## 研究目的

本研究では、マインドフルネス瞑想時のEEGに現れる
**個人差を定量的に明らかにすること**を目的とする。

瞑想時のEEGには、周波数特性や空間的な活動パターンなどに
被験者間の大きなばらつきが存在する。
そのため、全被験者に共通する単一の特徴だけでは、
個々の瞑想状態を十分に評価できない可能性がある。

そこで、L-FAMEの縦断EEGデータを用いて、

- 瞑想状態と安静状態におけるEEG特徴の比較
- PSD（Power Spectral Density）を用いた周波数特性の解析
- 被験者ごとのEEG特徴の可視化
- 被験者間に共通する特徴と個人固有の特徴の分析
- 6週間の瞑想訓練前後における個人内変化の分析

を行う。

最終的には、これらの個人差を
**ベイズ階層モデル（Hierarchical Bayesian Model）**
によって表現することを検討する。

ベイズ階層モデルを用いることで、

- 集団全体に共通するEEGの傾向
- 各個人に固有のEEG特性
- 個人ごとの瞑想による変化

を階層的に推定し、
集団から得られる情報を利用しながら
個人に適応した瞑想状態の推定を目指す。

将来的には、この推定結果を利用して、
個人のEEG特性に応じてフィードバックを変化させる
**個人適応型ニューロフィードバックシステム**
への応用を検討する。

## 使用データ

Dataset: L-FAME  
Longitudinal Focused Attention Meditation EEG Dataset

https://arxiv.org/abs/2605.22893

参加者：74名  
年齢：平均約22歳  
EEG：64 channel  
研究デザイン：6週間の縦断研究

瞑想グループ：

- BF : Breath Focus　呼吸瞑想
- HK : Hare Krishna　長めのマントラ瞑想
- SA : SA-TA-NA-MA　短めのマントラ瞑想

測定：

- Pre-intervention　6週間の瞑想トレーニング前　74人
- Post-intervention　6週間の瞑想トレーニング後　44人（6週間のトレーニング中に脱落）


##  データ形式

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

## ディレクトリ構造

変更次第、追加していく

``` plain text
focused-attention-meditation-eeg-analysis/
│
├── data/                         # EEGデータを保存
│   ├── raw/                      # 公開データから取得した元データ（変更しない）
│   ├── preprocessed/             # ICA除去など前処理済みのEEGデータ
│   └── processed/                # PSD・帯域パワーなど解析用に加工したデータ
│
├── code/                         # EEG解析に使用するコード
│   ├── functions/                # 複数の解析で再利用するMATLAB関数
│   │
│   └── scripts/                  # 実際の解析処理を実行するスクリプト
│       ├── 01_data_check/        # データ構造・被験者数・EEG情報などの確認
│       ├── 02_preprocessing/     # ICAなどEEGの前処理
│       ├── 03_psd/               # PSD・相対PSD・帯域パワーの計算
│       ├── 04_qc/                # 波形・PSDなどを用いた品質確認（QC）
│       ├── 05_analysis/          # 条件比較・統計解析など本解析
│       └── sandbox/              # 試行錯誤・動作確認・一時的な解析コード
│
├── download_scripts/             # 公開データをダウンロードするスクリプト
│
├── results/                      # 解析によって得られた数値結果
│   ├── psd/                      # PSDの計算結果
│   ├── band_power/               # 周波数帯域ごとのパワー
│   ├── qc/                       # QCの判定結果・除外対象など
│   └── statistics/               # 統計解析の結果
│
├── figures/                      # 解析で作成した図・グラフ
│   ├── raw_eeg/                  # EEG原波形
│   ├── psd/                      # PSDのグラフ
│   ├── qc/                       # QC確認用の図
│   ├── topoplot/                 # 頭皮上の分布を示すtopoplot
│   └── final/                    # 発表・論文などで使用する最終版の図
│
└── docs/                         # 研究・解析方法に関するドキュメント
                                    # 解析計画、前処理方法、研究メモなど

```

## 前処理

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
