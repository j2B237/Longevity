import serial
import csv
import time
import sys

# --- CONFIGURATION ---
# Remplacez par votre port (ex: 'COM3' sur Windows, '/dev/ttyUSB0' ou '/dev/ttyACM0' sur Linux/Mac)
PORT_SERIE = '/dev/ttyACM0'

# Assurez-vous que cette vitesse correspond exactement à celle de votre Serial.begin() sur Arduino
BAUD_RATE = 115200 
# Nom du fichier de sortie
FICHIER_OUTPUT = 'donnees_ecg_brutes.csv'
# ---------------------

print(f"Connexion au port {PORT_SERIE} à {BAUD_RATE} bauds...")

try:
    # Initialisation de la liaison série
    ser = serial.Serial(PORT_SERIE, BAUD_RATE, timeout=1)
    # Attendre 2 secondes que la liaison se stabilise (évite les premiers caractères corrompus)
    time.sleep(2)
    ser.flushInput()
    print("Connexion établie. Capture en cours... (Appuyez sur Ctrl+C pour arrêter)")
    
    # Ouverture du fichier CSV en mode écriture
    with open(FICHIER_OUTPUT, mode='w', newline='', encoding='utf-8') as fichier_csv:
        writer = csv.writer(fichier_csv)
        
        # Écriture de l'en-tête du fichier CSV
        # 'Sample_Index' ou 'Time' est crucial pour le traitement du signal (calcul de la fréquence d'échantillonnage)
        writer.writerow(['Index', 'Timestamp_ms', 'ECG_Raw'])
        
        compteur_echantillons = 0
        temps_debut = time.time()
        
        while True:
            # Lecture d'une ligne complète se terminant par '\n'
            if ser.in_waiting > 0:
                ligne = ser.readline().decode('utf-8', errors='ignore').strip()
                
                if ligne:
                    try:
                        # Conversion de la valeur reçue en entier (ou float selon votre code Arduino)
                        valeur_ecg = int(ligne)
                        
                        # Calcul du temps écoulé en millisecondes
                        temps_actuel_ms = int((time.time() - temps_debut) * 1000)
                        
                        # Écriture dans le CSV
                        writer.writerow([compteur_echantillons, temps_actuel_ms, valeur_ecg])
                        
                        compteur_echantillons += 1
                        
                        # Affichage périodique dans la console pour voir que le script tourne
                        if compteur_echantillons % 500 == 0:
                            print(f"{compteur_echantillons} échantillons enregistrés...")
                            
                    except ValueError:
                        # Gestion des lignes incomplètes ou parasites lors de l'initialisation
                        # print(f"Ligne ignorée (bruit) : {ligne}")
                        continue

except KeyboardInterrupt:
    print("\nArrêt de la capture par l'utilisateur.")
    
except serial.SerialException as e:
    print(f"\nErreur d'accès au port série : {e}")
    print("Vérifiez que le moniteur série d'Arduino IDE est bien FERMÉ.")
    sys.exit()

finally:
    # Fermeture propre du port série à la sortie
    if 'ser' in locals() and ser.is_open:
        ser.close()
        print("Port série fermé.")
    print(f"Données sauvegardées avec succès dans '{FICHIER_OUTPUT}'.")
