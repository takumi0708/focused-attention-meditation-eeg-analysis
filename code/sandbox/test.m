%{
やりたいこと
ー脳波読み込む
ーファイル自動で作成
ー脳波画像を自動で保存するコード

目的
ーコードを１から書く練習
ーコントロール感を得るため　研究において
%}

clear;
clc;
close all;

% EEGLAB 脳波サンプル
eeglab_sample_dir = 'C:\Users\zhang\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\EEGLAB\sample_data';

% テストに必要な2つのファイルを現在の分析フォルダにコピー
copyfile(fullfile(eeglab_sample_dir, 'eeglab_data.set'), '.');
copyfile(fullfile(eeglab_sample_dir, 'eeglab_data.fdt'), '.');

%% ここから練習

%{
9/6作成
脳波読み込んでフォルダ自動作成して
脳波画像を自動で保存するコード練習
%}

clear; clc; close all;

eeglab;
EEG = pop_loadset('filename', 'eeglab_data.set');

% 5s,16chずつ　フォルダに保存
sec = 5;
ch_per_fig = 16;
save_dir = './output';

if ~exist(save_dir, 'dir') % 'dir' に修正
    mkdir(save_dir);
end

% 時間軸　オフセット　写真枚数
fs = EEG.srate;
nSample = round(sec * fs);
t = (0 : nSample-1) / fs;

% 【重要】1点目からnSample点目までの「範囲」を抽出（: から 1:nSample に修正）
data = double(EEG.data(:, 1:nSample));

% 各チャネルの標準偏差の中央値＊６
% yの位置をずらす用
offset = mean(std(data,0,2)) * 6; % コメントに合わせて「* 6」を追加すると見やすくなります
% 写真数 EEG.nbchan(number of bio-channels)
nGroup = ceil(EEG.nbchan / ch_per_fig);

%% 描画と保存
for g = 1 : nGroup
    % start, endを定義
    ch_start = (g -1) * ch_per_fig + 1;
    ch_end = min(g * ch_per_fig, EEG.nbchan);
    % 今回のchの配列
    ch_index = ch_start:ch_end;

    % 'Visible', 'on' に修正（裏で静かにやりたい場合は 'off' にしてください）
    fig = figure('Visible', 'on');
    % 同じ画面に描画
    hold on;

    % 1本ずつずらしながら描画
    for i = 1:length(ch_index)
        ch = ch_index(i);

        % MATLAB は通常は下から上なので、逆にする設定
        % 高い位置からずらしていく(最初が一番大きい)
        y_offset = (length(ch_index) - i)*offset;

        plot(t, data(ch, :) + y_offset, 'blue'); % 'blue' に修正
    end
    %重ね書き終了
    hold off;

    % 見た目変更

    % y軸のメモリ（length のタイポを修正）
    y_positions = (0:length(ch_index)-1)*offset;

    % label
    labels = {EEG.chanlocs(ch_index).labels};

    % y軸にメモリセット(自分で設定)
    yticks(y_positions);

    % メモリの場所にラベル貼る
    yticklabels(flip(labels));

    % 範囲限定
    xlim([0, sec]);
    grid on;

    % 保存名 string print format
    filename = sprintf('wave_%02d.png', g); % 引数をシングルクォーテーションに修正

    % グラフ画面(fig)を保存
    exportgraphics(fig, fullfile(save_dir, filename));

    close(fig);
end

disp('完了！');
