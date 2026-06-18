%% ========================================================================
%  PROJET : ANALYSE ET FILTRAGE DU SIGNAL HOLTER ECG
%  ========================================================================

%% ÉTAPE 1 : IMPORTATION DES DONNÉES ET PARAMÉTRAGE
clc; clear; close all;

% Configuration de la fréquence
fs = 250;   % Fréquence d'échantillonnage (250 Hz)

% Chargement des données issues du script Python
data = readtable("donnees_holter_ecg.csv");

% Extraction des colonnes utiles
index     = data.Index_Global;
timestamp = data.Timestamp_ms;
raw       = double(data.ECG_Raw); % Conversion en double pour les calculs de filtrage

% Conversion du timestamp en secondes pour les graphiques
tps_sec = timestamp / 1000;


%% ÉTAPE 2 : TRACÉ STATIQUE DU SIGNAL BRUT IMPORTÉ
figure('Name', 'Visualisation ECG Brut', 'NumberTitle', 'off');
plot(tps_sec, raw, 'r');
grid on;
title('Signal ECG brut importé (Données Holter)');
xlabel('Temps (secondes)');
ylabel('Amplitude (Valeur ADC)');


%% ÉTAPE 3 : CONFIGURATION DES FILTRES FIR (PASSE-BAS & PASSE-HAUT)

% --- A. Configuration du Filtre Passe-Bas (Filtre anti-bruit musculaire)
Fpass_LP = 35;      % Fin de la bande passante (Hz)
Fstop_LP = 50;      % Début de la bande coupée (Hz)
Dpass_LP = 0.05;    % Ondulation maximale en bande passante
Dstop_LP = 0.0001;  % Atténuation minimale en bande coupée (-80 dB)

F_LP  = [0 Fpass_LP Fstop_LP fs/2]/(fs/2); % Fréquences normalisées
A_LP  = [1 1 0 0];
D_LP  = [Dpass_LP Dstop_LP];

b_LP  = firgr('minorder', F_LP, A_LP, D_LP);
LP    = dsp.FIRFilter('Numerator', b_LP);

% --- B. Configuration du Filtre Passe-Haut (Suppression de la dérive respiratoire)
Fstop_HP = 0.1;     % Fin de la bande coupée (Hz)
Fpass_HP = 0.5;     % Début de la bande passante (Hz)
Dstop_HP = 0.0001;  % Atténuation minimale (-80 dB)
Dpass_HP = 0.05;    % Ondulation maximale

F_HP  = [0 Fstop_HP Fpass_HP fs/2]/(fs/2); % Fréquences normalisées
A_HP  = [0 0 1 1];
D_HP  = [Dstop_HP Dpass_HP];

%b_HP  = firgr('minorder', F_HP, A_HP, D_HP);
%HP    = dsp.FIRFilter('Numerator', b_HP);
b_LP = firgr('minorder', [0 35 45 fs/2]/(fs/2), [1 1 0 0], [0.05 0.0001]);
b_HP = firgr('minorder', [0 0.1 0.5 fs/2]/(fs/2), [0 0 1 1], [0.0001 0.05]);

% ÉTAPE 4 : CONFIGURATION DE L'OSCILLOSCOPE VIRTUEL (TIMESCOPE)
% TS = timescope('SampleRate', fs, ...
%     'TimeSpanSource', 'Property', ...
%     'TimeSpan', 1.5, ...
%     'ShowGrid', true, ...
%     'NumInputPorts', 2, ...
%     'LayoutDimensions', [2 1]);
% 
% % Canal 1 : Signal Bruité
% TS.ActiveDisplay = 1;
% TS.YLimits = [min(raw) max(raw)]; % Ajustement automatique à la dynamique de ton ADC
% TS.Title = 'Signal ECG Réel Bruité (AD8232)';
% 
% % Canal 2 : Signal Filtré
% TS.ActiveDisplay = 2;
% TS.YLimits = [min(raw)-50 max(raw)+50]; 
% TS.Title = 'Signal ECG Réel Filtré (Cascade HP + LP)';


% ÉTAPE 5 : EXÉCUTION DU FILTRAGE ET VISUALISATION EN TEMPS RÉEL
% disp('Début de la simulation du flux ECG en temps réel...');
% 
% N = length(raw);
% 
% % Si tu voulais utiliser uniquement SGOLAY au lieu de HP + LP :
% %y_smooth = sgolayfilt(raw, 2, 25); 
% 
% 
% for i = 1:N
%     % 1. Lecture de l'échantillon brut actuel
%     sample_brut = raw(i);
% 
%     % 2. Filtrage en cascade
%     sans_derive   = HP(sample_brut);  % Passe-haut d'abord
%     sample_filtre = LP(sans_derive);   % Passe-bas ensuite
% 
% 
%     % Et dans ta boucle temps réel, tu afficherais directement :
%     %TS(raw(i), y_smooth(i));
% 
%     % On rajoute un offset pour que le signal flotte à mi-hauteur (ex: 500 ou 512)
%     sample_filtre_visible = sample_filtre + 512;
% 
%     % 3. Envoi simultané au scope pour affichage dynamique
%     TS(sample_brut, sample_filtre_visible);
% 
%     % 4. Pause cadencée à 250 Hz (4 ms entre chaque échantillon)
%     pause(1/fs);
% end
% 
% % Libération propre du composant graphique à la fin du traitement
% release(TS);
% disp('Traitement terminé avec succès.');

%% ÉTAPE 4 : APPLICATION DU FILTRAGE GLOBAL (La correction)
% On utilise les coefficients directs 'b_HP' et 'b_LP' avec la fonction filter standard
raw_sans_derive = filter(b_HP, 1, raw);          % Passe-haut
raw_pure_filtre = filter(b_LP, 1, raw_sans_derive); % Passe-bas

% Application de l'offset pour la visualisation (milieu d'échelle)
signal_filtre_affiche = raw_pure_filtre + 512; 

%% ÉTAPE 5 : CONFIGURATION DU TIMESCOPE
TS = timescope('SampleRate', fs, 'TimeSpan', 1.5, 'ShowGrid', true, ...
    'NumInputPorts', 2, 'LayoutDimensions', [2 1]);

TS.ActiveDisplay = 1; TS.YLimits = [min(raw) max(raw)];
TS.Title = 'Signal ECG Réel Bruité (AD8232)';

TS.ActiveDisplay = 2; TS.YLimits = [0 1024]; % Plage ADC 10 bits standard
TS.Title = 'Signal ECG Réel Filtré (Cascade HP + LP + Offset)';

%% ÉTAPE 6 : BOUCLE D'ANIMATION TEMPS RÉEL
disp('Affichage du flux ECG filtré...');
for i = 1:length(raw)
    % On envoie les points déjà calculés au scope
    TS(raw(i), signal_filtre_affiche(i));
    pause(1/fs);
end
release(TS);

%%
% Extraction du filtre Passe-Haut (HP)
disp('--- Coefficients PASSE-HAUT (b_HP) ---');
fprintf('%.10f,\n', b_HP);
fprintf("Length b_HP is %d", size(b_HP));

% Extraction du filtre Passe-Bas (LP)
disp('--- Coefficients PASSE-BAS (b_LP) ---');
fprintf('%.10f,\n', b_LP);
fprintf("Length b_LP is %d", size(b_LP));