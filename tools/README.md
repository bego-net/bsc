# Admin Password Reset Tool

This Python command-line utility resets a member's password and forces them to choose a new password upon their next login.

## Setup Instructions

### 1. Create a Firebase Service Account Key
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Select your project and click **Project Settings** (gear icon) > **Service Accounts**.
3. Under **Firebase Admin SDK**, click **Generate new private key**.
4. Save the downloaded JSON file to a secure location outside your git repository (never commit key files).

### 2. Set the Environment Variable

**Windows PowerShell:**
```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\your-service-account-key.json"
```

**Windows Command Prompt (CMD):**
```cmd
set GOOGLE_APPLICATION_CREDENTIALS=C:\path\to\your-service-account-key.json
```

**macOS / Linux:**
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your-service-account-key.json"
```

### 3. Install Requirements
```bash
pip install -r tools/requirements.txt
```

### 4. Run the Tools

**Create or promote an admin:**
```bash
python tools/create_admin.py <username> <password> [display_name]
# Example:
python tools/create_admin.py testadmin admin123 "Test Admin"
```

**Reset a user's password:**
```bash
python tools/reset_password.py <username>
```

### 5. Notify the Member
Provide the printed temporary password to the member through a private channel. When they log in with this temporary password, the app will immediately prompt them to set a new password before they can access any study features.
