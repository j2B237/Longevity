Fs = 250; % Fréquence d'échantillonnage en Hz

%% 1. Filtre Notch 50 Hz (IIR)
f0 = 50;  % Fréquence à couper
Q  = 35;  % Facteur de qualité (plus il est haut, plus la bande coupée est étroite)
[b_notch, a_notch] = iirnotch(f0/(Fs/2), f0/(Fs/2)/Q);

fprintf('--- Coefficients NOTCH 50 Hz ---\n');
fprintf('b = [%.6f, %.6f, %.6f]\n', b_notch(1), b_notch(2), b_notch(3));
fprintf('a = [%.6f, %.6f, %.6f]\n\n', a_notch(1), a_notch(2), a_notch(3));

%% 2. Filtre Passe-bas 40 Hz (IIR Butterworth ordre 2)
fc = 60; % Fréquence de coupure
[b_low, a_low] = butter(2, fc/(Fs/2), 'low');

fprintf('--- Coefficients PASSE-BAS 40 Hz ---\n');
fprintf('b = [%.6f, %.6f, %.6f]\n', b_low(1), b_low(2), b_low(3));
fprintf('a = [%.6f, %.6f, %.6f]\n', a_low(1), a_low(2), a_low(3));

scale = 16384;              % 2^14 = 16384

B_Notch_Conforme = round(b_notch * scale);
A_Notch_Conforme = round(a_notch * scale);
B_Low_Conforme   = round(b_low * scale);
A_Low_Conforme   = round(a_low * scale);

