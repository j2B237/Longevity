import serial
import csv
import time
import sys

# --- CONFIGURATION MATÉRIELLE ---
PORT_SERIE = '/dev/ttyUSB0'  # À adapter selon ton module Bluetooth (ex: /dev/rfcomm0)
BAUD_RATE = 115200             

FICHIER_CSV = 'donnees_holter_ecg.csv'
SAMPLES_PER_PACKET = 25
# --------------------------------

print(f"Connexion au Holter sur {PORT_SERIE} à {BAUD_RATE} bauds...")

try:
    ser = serial.Serial(PORT_SERIE, BAUD_RATE, timeout=1)
    time.sleep(2)  
    ser.flushInput()
    print("Capture active (Header: 0xAA55, 25 Samples, Footer: 0xFF99, BPM). (Ctrl+C pour arrêter)")

    with open(FICHIER_CSV, mode='w', newline='', encoding='utf-8') as fichier_csv:
        writer = csv.writer(fichier_csv)
        # Ajout du BPM et du numéro de paquet pour faciliter l'analyse dans Matlab
        writer.writerow(['Index_Global', 'Paquet_ID', 'Timestamp_ms', 'ECG_Raw', 'BPM'])

        compteur_samples_global = 0
        compteur_paquets = 0
        temps_debut = time.time()

        while True:
            if ser.in_waiting >= 56: # Attendre qu'une trame complète de 56 octets soit disponible
                
                # Étape 1 : Recherche et validation du HEADER (0xAA55)
                # En Python, si on lit les octets un par un : LSB puis MSB (0x55 puis 0xAA)
                if ord(ser.read(1)) == 0x55:
                    if ord(ser.read(1)) == 0xAA:
                        
                        # Étape 2 : Lecture du corps de la trame (25 échantillons x 2 octets = 50 octets)
                        corps_brut = ser.read(SAMPLES_PER_PACKET * 2)
                        
                        # Étape 3 : Lecture du FOOTER (2 octets : 0x99 puis 0xFF)
                        footer_brut = ser.read(2)
                        
                        # Étape 4 : Lecture de la valeur du BPM (2 octets)
                        bpm_brut = ser.read(2)
                        
                        # Validation de l'intégrité de la trame via le FOOTER
                        if len(footer_brut) == 2 and footer_brut[0] == 0x99 and footer_brut[1] == 0xFF:
                            
                            # Reconstitution du BPM (16 bits)
                            bpm_val = (bpm_brut[1] << 8) | bpm_brut[0]
                            print(f"[Paquet {compteur_paquets}] Trame valide | Fréquence Cardiaque = {bpm_val} BPM")
                            
                            # Horodatage du paquet
                            temps_ms = int((time.time() - temps_debut) * 1000)
                            
                            # Étape 5 : Extraction et écriture des 25 échantillons ECG
                            for i in range(SAMPLES_PER_PACKET):
                                lsb = corps_brut[i * 2]
                                msb = corps_brut[i * 2 + 1]
                                
                                # Reconstitution du mot de 16 bits de l'échantillon
                                mot_16bits = (msb << 8) | lsb
                                valeur_ecg = mot_16bits & 0x7FFF # Préservation des 15 bits utiles
                                
                                # Sauvegarde de chaque échantillon dans le CSV
                                writer.writerow([compteur_samples_global, compteur_paquets, temps_ms, valeur_ecg, bpm_val])
                                compteur_samples_global += 1
                            
                            compteur_paquets += 1
                        else:
                            # Désynchronisation détectée (mauvais FOOTER) -> On purge pour retrouver le prochain HEADER
                            print("Avertissement : Mauvais Footer détecté, resynchronisation...")
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
