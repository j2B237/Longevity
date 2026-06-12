%% First section

data = readtable("donnees_holter_ecg.csv");

% Extraction de l'index
index = data.Index;

% Extraction du timestamp
timestamp = data.Timestamp_ms;

% Extraction des donnees brutes
raw = data.ECG_Raw;

fc = 50;    % 50 Hz
fs = 250;   % 250 Hz

% Conversion du timestamp en sec
tps_sec = timestamp / 1000;

filtered_ecg = lowpass(raw, fc, fs);

%%

plot(tps_sec, raw, "r")
hold on
plot(tps_sec, filtered_ecg, "b")
title('Signal ECG brut importé');
xlabel('Temps (secondes)');
ylabel('Amplitude');
grid on
%%

