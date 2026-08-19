# focused-attention-meditation-eeg-analysis

L-FAME（Longitudinal Focused Attention Meditation EEG）データを用いた
瞑想時EEGの解析メモ・解析コードを管理するリポジトリ。

## 目的

Focused Attention Meditation におけるEEGの個人差を調べる。

まずは公開データの構造を理解し、

- EEGデータの読み込み
- 前処理済みデータの確認
- 瞑想・安静状態の切り出し
- PSD（Power Spectral Density）の計算
- 被験者ごとの特徴の確認

を行う。

最終的には、瞑想状態における個人差を考慮した解析を検討する。

## 使用データ

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
