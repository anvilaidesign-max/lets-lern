---
topic: tech
position: 4
title: Cybersecurity and cryptography
summary: How attackers really get in, how encryption, hashing and public keys protect data, and the habits that keep you and your systems safe.
difficulty: 2
sources:
- Wikipedia: Computer security | https://en.wikipedia.org/wiki/Computer_security
- Wikipedia: Public-key cryptography | https://en.wikipedia.org/wiki/Public-key_cryptography
- Wikipedia: Cryptographic hash function | https://en.wikipedia.org/wiki/Cryptographic_hash_function
- Wikipedia: Multi-factor authentication | https://en.wikipedia.org/wiki/Multi-factor_authentication
---
## The three goals

Security professionals often describe their goals as the **CIA triad**:

- **Confidentiality:** only the right people can read the data.
- **Integrity:** data cannot be changed without detection.
- **Availability:** systems work when needed.

A data leak breaks confidentiality, a tampered bank transfer breaks integrity, and a ransomware attack that locks a hospital's files breaks availability.

## How attackers get in

Movies show hackers typing furiously, but most real attacks are simpler:

- **Phishing:** fake messages that trick people into clicking a link, entering a password or sending money. This is the most common way in. Check the sender and the real web address before you trust a message.
- **Weak or reused passwords:** when one site is breached, attackers try the same email and password everywhere else (credential stuffing).
- **Unpatched software:** attackers exploit known bugs that the victim never updated. A **zero-day** is a flaw unknown to the vendor, with no fix yet.
- **Malware:** harmful software, including **ransomware**, which encrypts files and demands payment.
- **Social engineering:** phone calls or visits pretending to be IT support, the bank or a boss.

## Encryption

**Encryption** scrambles data so only someone with the right **key** can read it.

- **Symmetric encryption** uses one shared key to lock and unlock. **AES** is the standard and is very fast; it protects your phone's storage and bulk data on the internet.
- **Public-key (asymmetric) encryption** uses a key pair: a **public key** that anyone may have and a **private key** kept secret. Data locked with the public key can only be unlocked with the private key. RSA and elliptic-curve cryptography are common examples.

Public-key cryptography solves a big problem: how two strangers on the internet agree on a shared secret without meeting. In HTTPS, public-key methods set up the connection and agree a symmetric key, then fast AES encrypts the actual traffic.

![Anyone can lock a message with Rudo's public key, but only her private key can unlock it.](public_key)

## Digital signatures and certificates

Reversed, key pairs create **digital signatures**: something signed with a private key can be verified by anyone with the public key, proving who signed it and that it was not altered. **Certificates** are signed statements from trusted authorities that bind a public key to a website's name. Software updates are signed too, so your phone can refuse fake updates.

## Hashing

A **cryptographic hash function** (such as SHA-256) turns any input into a fixed-length fingerprint. Change one letter and the hash changes completely, and you cannot work backwards from the hash to the input.

Well-run services never store your actual password. They store a salted, deliberately slow hash of it (algorithms such as bcrypt or Argon2), then hash what you type at login and compare. If the database leaks, the passwords are not directly exposed.

## Protecting yourself

- **Use long, unique passwords**, ideally generated and stored by a password manager.
- **Turn on multi-factor authentication (MFA)**: something you know (password) plus something you have (an authenticator app or security key). Codes by SMS are better than nothing but can be stolen by SIM-swap fraud.
- **Update** your phone, apps and computer promptly.
- **Back up** important files, including an offline copy, so ransomware cannot hold them hostage.
- **Be suspicious of urgency:** "your account will be closed in 1 hour" is a classic pressure tactic.

## Protecting systems

Organisations add layers: firewalls, network segmentation (keep industrial control systems away from office networks), the **principle of least privilege** (give each account only the access it needs), logging and monitoring, and regular security testing. No single defence is perfect, so security relies on **defence in depth**.

# Key points
- Security aims for confidentiality, integrity and availability (the CIA triad).
- Phishing, reused passwords and unpatched software cause most breaches.
- Symmetric encryption (AES) is fast; public-key encryption lets strangers agree keys securely.
- Digital signatures and certificates prove who sent something and that it was not altered.
- Store password hashes, never passwords; use a password manager and MFA.
- Defence in depth: layers of protection, least privilege and backups.

# Quiz
Q: What is the most common way attackers get into accounts and systems?
- Breaking AES encryption
* Phishing messages that trick people
- Guessing 30-character random passwords
- Hacking satellites
> Tricking a person is usually much easier than breaking strong technology.

Q: In public-key encryption, which key must be kept secret?
- The public key
* The private key
- Both keys
- Neither key
> The public key can be shared freely; only the private key must stay secret.

Q: Why do well-run services store password hashes instead of passwords?
- Hashes are shorter
* If the database leaks, the actual passwords are not directly revealed
- Hashes can be turned back into passwords easily
- It makes logging in faster
> A hash cannot be reversed. At login the typed password is hashed and compared.

Q: Which is the strongest second factor for multi-factor authentication?
- A password hint
- A code sent by SMS
* A hardware security key or authenticator app
- Your date of birth
> SMS codes can be stolen through SIM-swap fraud; app codes and hardware keys are stronger.

Q: What does ransomware do?
- Speeds up your computer
* Encrypts your files and demands payment to unlock them
- Deletes spam email
- Updates your software
> Offline backups are the best protection, because you can restore without paying.
