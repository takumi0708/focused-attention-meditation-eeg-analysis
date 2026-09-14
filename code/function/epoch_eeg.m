function epochs = epoch_eeg(EEG, epoch_sec)
%EPOCH_EEG 連続EEGを指定秒数ごとに分割する
%
%   入力:
%       EEG - EEGLABのEEG構造体
%       epoch_sec - 1エポックの長さ（秒）
%   出力:
%       epochs    - channel × sample × epoch の3次元配列
%   
    arguments
        EEG struct
        epoch_sec (1, 1) double {mustBePositive}
    end

% ここに処理を書く
%{
処理のイメージ
ーやりたいこと
・１つの脳波を入れる
・エポックごとの３次元配列にする
ー処理
・１エポックあたりのサンプル数の計算
・総エポック数の計算
・３次元データに変換
%}

    % サンプリング周波数
    fs = EEG.srate;

    % 1エポックあたりのサンプル数
    epoch_samples = round(epoch_sec * fs);

    % EEG全体のサンプル数
    total_samples = size(EEG.data, 2);

    % 作れるエポック数
    n_epoches = floor(total_samples / epoch_samples);

    % 必要な範囲を切り出す
    usable_samples = n_epoches * epoch_samples;
    data = EEG.data(: , 1:usable_samples);

    % channel × sample × epoch に変形
    epochs = reshape( ...
        data, ...
        size(data, 1), ...
        epoch_samples, ...
        n_epoches ...
        );
end
