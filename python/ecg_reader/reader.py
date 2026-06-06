import serial
import csv
import time
import sys

# --- CONFIGURATION MATÉRIELLE ---
PORT_SERIE = '/dev/ttyACM0'  
BAUD_RATE = 115200             # Mode 1MHz basse consommation

FICHIER_CSV = 'donnees_holter_ecg.csv'
# --------------------------------

print(f"Connexion au Holter sur {PORT_SERIE} à {BAUD_RATE} bauds...")

try:
    ser = serial.Serial(PORT_SERIE, BAUD_RATE, timeout=1)
    time.sleep(2)  
    ser.flushInput()
    print("Capture active (Header: 0xAA55, Pas de Footer). (Ctrl+C pour arrêter)")

    with open(FICHIER_CSV, mode='w', newline='', encoding='utf-8') as fichier_csv:
        writer = csv.writer(fichier_csv)
        writer.writerow(['Index', 'Timestamp_ms', 'ECG_Raw'])

        compteur_samples = 0
        temps_debut = time.time()

        while True:
            if ser.in_waiting > 0:
                # Étape 1 : Recherche du premier octet de l'en-tête (0x55)
                if ord(ser.read(1)) == 0x55:
                    
                    # On s'assure qu'on a au moins un octet disponible pour le 0xAA
                    if ser.in_waiting > 0:
                        if ord(ser.read(1)) == 0xAA:
                            
                            # Étape 2 : L'en-tête 0xAA55 est validé. On lit les 2 octets de données (LSB, MSB)
                            # On attend que les 2 octets soient arrivés si nécessaire
                            donnees_brutes = ser.read(2)
                            
                            if len(donnees_brutes) == 2:
                                lsb = donnees_brutes[0]
                                msb = donnees_brutes[1]

                                # Reconstitution du mot de 16 bits
                                mot_16bits = (msb << 8) | lsb

                                # Extraction de la valeur ECG utile (Bits 0 à 14)
                                valeur_ecg = mot_16bits & 0x7FFF
                                print(f"ECG Val = {valeur_ecg}")
                                
                                # Calcul du timestamp en millisecondes
                                temps_ms = int((time.time() - temps_debut) * 1000)

                                # Sauvegarde pour Matlab
                                writer.writerow([compteur_samples, temps_ms, valeur_ecg])
                                compteur_samples += 1

                                if compteur_samples % 500 == 0:
                                    print(f"{compteur_samples} échantillons collectés...")
                        else:
                            # Si le deuxième octet n'est pas 0x55, désynchronisation : on vide le buffer récepteur
                            ser.flushInput()

except KeyboardInterrupt:
    print("\nCapture arrêtée par l'utilisateur.")

except serial.SerialException as e:
    print(f"\nErreur port série : {e}")
    sys.exit()

finally:
    if 'ser' in locals() and ser.is_open:
        ser.close()
    print(f"Fichier '{FICHIER_CSV}' enregistré avec succès.")