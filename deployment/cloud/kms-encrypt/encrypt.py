import os
from google.cloud import kms_v1
import base64
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Set required configuration variables from environment variables
project_id = os.getenv("PROJECT_ID")
location_id = os.getenv("LOCATION_ID")
key_ring_id = os.getenv("KEY_RING_ID")
crypto_key_id = os.getenv("CRYPTO_KEY_ID")

# Client initialization
client = kms_v1.KeyManagementServiceClient()
key_name = client.crypto_key_path(project_id, location_id, key_ring_id, crypto_key_id)

def encrypt(plaintext):
    # Encrypt the plaintext
    response = client.encrypt(
        request={"name": key_name, "plaintext": plaintext.encode("utf-8")}
    )

    # Encode the ciphertext in base64
    ciphertext = base64.b64encode(response.ciphertext).decode("utf-8")
    return ciphertext

def decrypt(ciphertext):
    # Decode the base64 ciphertext
    ciphertext = base64.b64decode(ciphertext.encode("utf-8"))
    # Decrypt the ciphertext
    response = client.decrypt(request={"name": key_name, "ciphertext": ciphertext})
    plaintext = response.plaintext.decode("utf-8")
    return plaintext

if __name__ == "__main__":
    option = ""
    # Loop until user inputs '1' or '2'
    while option not in ["1", "2"]:
        # Prompt user to choose encryption or decryption
        option = input("Input your choice:\n1. Encryption\n2. Decryption\nChoice: ")
        if option == "1":
            # Prompt user to enter plaintext
            plaintext = input("Enter the plaintext: ")
            # Encrypt the plaintext
            encrypted_text = encrypt(plaintext)
            # Print the encrypted text
            print(f"Ciphertext: {encrypted_text}")
        elif option == "2":
            # Prompt user to enter encrypted text
            encrypted_text = input("Enter the encrypted text: ")
            # Decrypt the encrypted text
            decrypted_text = decrypt(encrypted_text)
            # Print the plaintext
            print(f"Plaintext: {decrypted_text}")
        else:
            # Invalid input
            print("Invalid input. Please enter 1 or 2.")