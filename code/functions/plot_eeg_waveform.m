function plot_eeg_waveform(signal, fs)
% plot_eeg_waveform
% EEGの原波形を描画する
%
% Inputs:
%   signal : 1チャネル分のEEGデータ
%   fs     : サンプリング周波数 [Hz]

    % 横軸の時間を作る
    t = (0:length(signal)-1) / fs;

    % 原波形を描画
    plot(t, signal);

    xlabel('Time [s]');
    ylabel('Amplitude [\muV]');
    title('EEG Waveform');

    xlim([0 t(end)]);
    grid on;

end