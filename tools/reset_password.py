#!/usr/bin/env python3
"""
Admin Password Reset Tool for Bible Study app.
Generates a temporary password, updates Firebase Auth, and marks
users/{uid}.mustChangePassword = True in Firestore.
"""

import os
import secrets
import string
import sys

DOMAIN = "biblestudy.invalid"


def main():
    if len(sys.argv) != 2:
        print("Usage: python tools/reset_password.py <username>")
        sys.exit(1)

    username = sys.argv[1].strip().lower()
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

    # Lookup user by hidden email
    try:
        user = auth.get_user_by_email(hidden_email)
    except auth.UserNotFoundError:
        print(f"Error: User with username '{username}' was not found.")
        sys.exit(1)
    except Exception as e:
        print(f"Error looking up user: {e}")
        sys.exit(1)

    # Generate 12-character random temporary password using secrets
    alphabet = string.ascii_letters + string.digits
    temp_password = "".join(secrets.choice(alphabet) for _ in range(12))

    # Update password in Firebase Auth
    try:
        auth.update_user(user.uid, password=temp_password)
    except Exception as e:
        print(f"Error updating Auth password: {e}")
        sys.exit(1)

    # Mark mustChangePassword = True in Firestore
    try:
        db = firestore.client()
        db.collection("users").document(user.uid).update(
            {"mustChangePassword": True}
        )
    except Exception as e:
        print(f"Error updating Firestore document: {e}")
        sys.exit(1)

    print("==================================================")
    print(f"Password reset successfully for user: {username}")
    print(f"Temporary password: {temp_password}")
    print("==================================================")
    print("Please share this temporary password with the member privately.")
    print("They will be forced to choose a new password upon logging in.")


if __name__ == "__main__":
    main()
