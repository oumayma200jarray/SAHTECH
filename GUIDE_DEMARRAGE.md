# 🚀 Guide de démarrage — SAHTEK

## Prérequis
- Téléphone branché en USB avec **Débogage USB activé**
- Docker Desktop lancé

---

## Étape 1 : Démarrer le backend (Docker)

```powershell
cd c:\Users\PCS\sahtek\SAHTHECK-bacend
docker-compose up --build -d backend
```

Attendez que tous les conteneurs soient `Healthy` / `Started`.

Vérifiez que le backend répond :
```powershell
Invoke-WebRequest -Uri http://127.0.0.1:4000 -UseBasicParsing
```
Vous devez voir `Hello World!`.

---

## Étape 2 : Créer les tunnels USB (adb reverse)

Ces commandes permettent au téléphone d'accéder au PC via `127.0.0.1` à travers le câble USB :

```powershell
C:\Users\PCS\AppData\Local\Android\sdk\platform-tools\adb.exe reverse tcp:4000 tcp:4000
C:\Users\PCS\AppData\Local\Android\sdk\platform-tools\adb.exe reverse tcp:9000 tcp:9000
```

Vérifiez que les tunnels sont actifs :
```powershell
C:\Users\PCS\AppData\Local\Android\sdk\platform-tools\adb.exe reverse --list
```
Vous devez voir :
```
UsbFfs tcp:4000 tcp:4000
UsbFfs tcp:9000 tcp:9000
```

---

## Étape 3 : Lancer l'application Flutter

```powershell
cd c:\Users\PCS\sahtek
flutter run
```

---

## ⚠️ Points importants à retenir

| Élément | Valeur correcte |
|---|---|
| `.env` Flutter (`c:\Users\PCS\sahtek\.env`) | `HOST=127.0.0.1` |
| Port backend (dans `app_config.dart`) | `4000` (pas 3000) |
| Port backend Docker (`docker-compose.yaml`) | `4000:4000` |
| Port MinIO | `9000` |

### Pourquoi `adb reverse` ?
- Le téléphone ne peut pas accéder à `127.0.0.1` du PC directement
- `adb reverse` crée un tunnel via le câble USB
- **⚡ Les tunnels se perdent** si le téléphone est débranché → il faut refaire l'étape 2

### Si l'APK ne s'installe pas ?
1. Désinstaller l'app SAHTEK manuellement depuis le téléphone
2. Relancer `flutter run`

### Si le build est corrompu ?
```powershell
cd c:\Users\PCS\sahtek
flutter clean
flutter run
```

---

## 🔄 Commande tout-en-un (copier-coller)

```powershell
# 1. Backend
cd c:\Users\PCS\sahtek\SAHTHECK-bacend
docker-compose up -d backend

# 2. Tunnels ADB
C:\Users\PCS\AppData\Local\Android\sdk\platform-tools\adb.exe reverse tcp:4000 tcp:4000
C:\Users\PCS\AppData\Local\Android\sdk\platform-tools\adb.exe reverse tcp:9000 tcp:9000

# 3. Flutter
cd c:\Users\PCS\sahtek
flutter run
```
