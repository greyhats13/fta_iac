# Google Cloud KMS Encryption and Decryption Script

This Python script provides a simple command-line interface for encrypting and decrypting data using [Google Cloud Key Management Service (KMS)](https://cloud.google.com/kms). It allows you to securely encrypt plaintext and decrypt ciphertext using a specified KMS key.

## Features

- **Encryption**: Encrypt plaintext using a specified KMS key.
- **Decryption**: Decrypt ciphertext encrypted by the KMS key.
- **Environment Configuration**: Reads configuration variables from a `.env` file.
- **Command-Line Interface**: Interactive prompts for user input.

## Prerequisites

- **Google Cloud Account**: You need a Google Cloud project with billing enabled.
- **KMS Key Ring and Crypto Key**: A Key Ring and Crypto Key set up in Google Cloud KMS.
- **Service Account with Proper Permissions**: Ensure your environment has credentials to access the KMS API with the necessary permissions.
- **Python 3.6 or Higher**

## Setup Instructions

### 1. Clone the Repository or Download the Script

```bash
git clone <repository_url>
```

Or simply download the `encrypt.py`, `requirements.txt`, and create the `.env` file in your working directory.

### 2. Install Dependencies

It's recommended to use a virtual environment.

#### Using `venv`:

```bash
python3 -m venv venv
source venv/bin/activate
```

#### Install the required packages:

```bash
pip install -r requirements.txt
```

### 3. Configure Google Cloud Credentials

Ensure that your environment is authenticated with Google Cloud and has access to the KMS resources.

- **Option 1**: Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to point to your service account key file:

  ```bash
  export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-file.json"
  ```

- **Option 2**: If running on a Google Cloud VM or using Cloud Shell, the environment may already be authenticated.

### 4. Set Up the `.env` File

Create a `.env` file in the same directory as `encrypt.py` and add your configuration variables:

```env
PROJECT_ID=your-project-id
LOCATION_ID=your-key-ring-location  # e.g., "global" or "us-central1"
KEY_RING_ID=your-key-ring-name
CRYPTO_KEY_ID=your-crypto-key-name
```

**Example**:

```env
PROJECT_ID=fta-platform
LOCATION_ID=global
KEY_RING_ID=fta-mstr-kms-main-keyring
CRYPTO_KEY_ID=fta-mstr-kms-main-cryptokey
```

### 5. Run the Script

```bash
python encrypt.py
```

## Usage

When you run the script, you will be prompted to choose an action:

```
Input your choice:
1. Encryption
2. Decryption
Choice:
```

### Encryption

1. **Select Encryption**: Enter `1` when prompted.
2. **Enter Plaintext**: Input the text you want to encrypt.
3. **Receive Ciphertext**: The script will output the base64-encoded ciphertext.

**Example**:

```
Input your choice:
1. Encryption
2. Decryption
Choice: 1
Enter the plaintext: Hello, World!
Ciphertext: CiQAR...
```

### Decryption

1. **Select Decryption**: Enter `2` when prompted.
2. **Enter Ciphertext**: Input the base64-encoded ciphertext you wish to decrypt.
3. **Receive Plaintext**: The script will output the decrypted plaintext.

**Example**:

```
Input your choice:
1. Encryption
2. Decryption
Choice: 2
Enter the encrypted text: CiQAR...
Plaintext: Hello, World!
```

## Important Notes

- **Environment Variables**: The script reads configuration variables from the `.env` file using `python-dotenv`.
- **Character Encoding**: The script uses UTF-8 encoding for plaintext and base64 encoding for ciphertext.
- **KMS Limits**: Google Cloud KMS has limits on the size of data you can encrypt directly (up to 64 KiB). For larger data, consider using envelope encryption.
- **Permissions**: The service account or user must have the `cloudkms.cryptoKeyEncrypterDecrypter` role for the specified Crypto Key.
- **Security**: Keep your `.env` file secure and do not commit it to version control systems like Git. Add `.env` to your `.gitignore` file.

## Troubleshooting

- **Authentication Errors**: Ensure that your Google Cloud credentials are correctly set up and that you have access to the KMS resources.
- **Permission Denied**: Check if the service account has the necessary permissions (`cloudkms.cryptoKeyEncrypterDecrypter` role).
- **Invalid Argument**: Verify that the `PROJECT_ID`, `LOCATION_ID`, `KEY_RING_ID`, and `CRYPTO_KEY_ID` in your `.env` file are correct and that the key exists.

## References

- [Google Cloud KMS Documentation](https://cloud.google.com/kms/docs/)
- [Google Cloud Python Client for KMS](https://googleapis.dev/python/cloudkms/latest/index.html)
- [python-dotenv Documentation](https://saurabh-kumar.com/python-dotenv/)
ed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

- **Imam Arief Rahman* - [greyhats13](https://github.com/greyhats13)