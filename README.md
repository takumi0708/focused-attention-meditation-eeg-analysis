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
