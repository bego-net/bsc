#!/usr/bin/env python3
"""
Admin Creation / Promotion Tool for Bible Study app.
Creates or promotes an admin user in Firebase Auth and Cloud Firestore.
"""

import os
import sys
from datetime import datetime, timezone

DOMAIN = "biblestudy.invalid"


def main():
    if len(sys.argv) < 3:
        print("Usage: python tools/create_admin.py <username> <password> [display_name]")
        print("Example: python tools/create_admin.py testadmin admin123 \"Test Admin\"")
        sys.exit(1)

    username = sys.argv[1].strip().lower()
    password = sys.argv[2]
    display_name = sys.argv[3].strip() if len(sys.argv) > 3 else username.capitalize()

    if not username:
        print("Error: Username cannot be empty.")
        sys.exit(1)

    cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if not cred_path:
        print(
            "Error: GOOGLE_APPLICATION_CREDENTIALS environment variable is not set.\n"
            "Please point it to your Firebase service account JSON key file.\n"
            "Example (PowerShell): $env:GOOGLE_APPLICATION_CREDENTIALS=\"C:\\path\\to\\key.json\"\n"
            "Example (CMD):        set GOOGLE_APPLICATION_CREDENTIALS=C:\\path\\to\\key.json"
        )
        sys.exit(1)

    if not os.path.isfile(cred_path):
        print(f"Error: Service account file not found at: {cred_path}")
        sys.exit(1)

    try:
        import firebase_admin
        from firebase_admin import auth, credentials, firestore
    except ImportError:
        print(
            "Error: firebase-admin package is not installed.\n"
            "Install it via: pip install -r tools/requirements.txt"
        )
        sys.exit(1)

    # Initialize Firebase Admin SDK
    cred = credentials.Certificate(cred_path)
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)

    hidden_email = f"{username}@{DOMAIN}"
    db = firestore.client()

    # Create or fetch user in Firebase Auth
    try:
        user = auth.get_user_by_email(hidden_email)
        print(f"User '{username}' already exists in Firebase Auth. Updating password and role...")
        auth.update_user(user.uid, password=password, display_name=display_name)
    except auth.UserNotFoundError:
        print(f"Creating user '{username}' in Firebase Auth...")
        user = auth.create_user(
            email=hidden_email,
            password=password,
            display_name=display_name,
        )
    except Exception as e:
        print(f"Error accessing Firebase Auth: {e}")
        sys.exit(1)

    # Update or create Firestore user document
    user_doc_ref = db.collection("users").document(user.uid)
    doc_snapshot = user_doc_ref.get()

    user_data = {
        "name": display_name,
        "email": hidden_email,
        "username": username,
        "role": "admin",
        "mustChangePassword": False,
    }

    if not doc_snapshot.exists:
        user_data.update({
            "createdAt": datetime.now(timezone.utc).isoformat(),
            "currentBook": "John",
            "currentChapter": 1,
            "currentVerse": 1,
            "verseFrom": 1,
            "verseTo": 1,
            "reminderTime": "07:00",
            "language": "am",
        })
        user_doc_ref.set(user_data)
    else:
        user_doc_ref.update(user_data)

    print("==================================================")
    print(f"Admin successfully configured!")
    print(f"Username: {username}")
    print(f"Email:    {hidden_email}")
    print(f"UID:      {user.uid}")
    print(f"Role:     admin")
    print("==================================================")


if __name__ == "__main__":
    main()
