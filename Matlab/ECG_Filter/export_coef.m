%% Script pour exporter les coefs du filtre passe-bas a zero phase
Coef = round(df3_Num * 1024);

fileID = fopen("matlab_ecg_coef.txt", 'w');

fprintf(fileID, '-- Coefficients pour filtre d''ordre %d (Virgule fixe *1024)\n', length(Coef)-1);
fprintf(fileID, 'B : constant array (0 .. %d) of Interfaces.Integer_32 := (\n', length(Coef)-1);

% Ecriture des coefs separes par des virgules
for i=1:length(Coef)
    if i == length(Coef)
        fprintf(fileID, ' %d\n', Coef(i));
    else
        fprintf(fileID, ' %d,\n', Coef(i));
    end
end 

% Ferme la parenthese
fprintf(fileID, ');\n');

% On ferme le descripteur de fichier
fclose(fileID);


disp("Fichier matlab_ecg_coef.txt enregistre avec succes!");