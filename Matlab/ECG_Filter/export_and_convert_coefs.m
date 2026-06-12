% Script MATLAB : Exportation des coefficients pour GNAT/Ada AVR
% Détection et extraction des coefficients (Numérateur / SOS)

% 1. Récupération de tes données (Remplace 'df4_Num' ou extrait de ton filtre)
if exist('ada_filter_coefs', 'var')
    coefs_float = ada_filter_coefs;
elseif exist('Hd', 'var') % Si tu as exporté un objet de filtre nommé Hd
    [coefs_float, g] = tf(Hd); % Extraction de la fonction de transfert
else
    % Au cas où tes coefficients sont directement dans la matrice SOS de ta capture
    % Nous reprenons les valeurs exactes de ton image
    coefs_float = [
        0.2167, -0.0586,  0.2167;
        0.5410, -0.0041,  0.5410;
        0.1816,  0.1563,  0.1816;
        0.6046,  0.6046,  0
        ];
end

% Mettre à plat la matrice sous forme de vecteur ligne (si SOS)
coefs_flat = coefs_float';
coefs_flat = coefs_flat(:)';

% Enlever le zéro de padding final si la dernière ligne n'a que 2 coefficients utiles
if coefs_flat(end) == 0
    coefs_flat(end) = [];
end

% 2. Conversion en virgule fixe Q10 (Échelle de 1024 pour ton code Ada)
Gain_Q10 = 1024;
coefs_integer = round(coefs_flat * Gain_Q10);

% Calcul automatique de l'ordre du filtre pour ton package Ada
filter_order = length(coefs_integer) - 1;

% 3. Écriture dans le fichier texte
file_name = 'coefficients_ada.txt';
fileID = fopen(file_name, 'w');

fprintf(fileID, '---------------------------------------------------\n');
fprintf(fileID, '-- Coefficients générés automatiquement par MATLAB --\n');
fprintf(fileID, '---------------------------------------------------\n\n');

fprintf(fileID, 'Filter_Order : constant := %d;\n\n', filter_order);
fprintf(fileID, 'Filter_Coefs : constant array (0 .. Filter_Order) of Interfaces.Integer_32 :=\n   (');

% Écriture des coefficients formatés
for i = 1:length(coefs_integer)
    if i == length(coefs_integer)
        fprintf(fileID, '%d);\n', coefs_integer(i));
    else
        fprintf(fileID, '%d, ', coefs_integer(i));
        % Retour à la ligne tous les 3 coefficients pour garder le style propre de tes matrices SOS
        if mod(i, 3) == 0
            fprintf(fileID, '\n    ');
        end
    end
end

fclose(fileID);
disp(['Succès ! Les coefficients ont été sauvegardés dans : ', file_name]);