
## 🛡️ SecureMsg: A Complete Secure Messaging Smart Contract Platform

**SecureMsg** is a Clarity-based smart contract providing a comprehensive, secure, and privacy-focused messaging platform on the Stacks blockchain. It includes features like encrypted messaging, user registration, priority inbox management, and full message lifecycle support.

---

## ✨ Features

* 🔐 **User Registration** with encryption key validation
* ✉️ **Secure Message Sending** (with priority, encryption, and delivery tracking)
* 🗃️ **Inbox Management** (limits, cleanup, analytics)
* 🧾 **Full Message Lifecycle**: create, read, and delete
* 📊 **Platform & User Statistics**
* 🛡️ **Access Control and Auditability**
* 🔑 **Encryption Key Updates**
* 🔄 **Account Status Management**

---

## 🧠 Smart Contract Overview

* Built with Clarity for use on the Stacks blockchain
* Persistent maps for users, messages, and inboxes
* Metadata and audit trail on every message
* Efficient handling of storage via message IDs and inbox lists

---

## ⚙️ Installation & Deployment

1. Clone the repository and enter the directory.
2. Ensure you have [Clarinet](https://docs.stacks.co/docs/clarity/clarinet/) installed.
3. Deploy locally with:

```bash
clarinet test
clarinet console
```

4. To deploy on-chain, set up your `.toml` configuration and run:

```bash
clarinet deploy
```

---

## 🔧 Public Functions

| Function                  | Description                             |
| ------------------------- | --------------------------------------- |
| `register-secure-account` | Registers a user with an encryption key |
| `send-secure-message`     | Sends a secure message with metadata    |
| `read-message`            | Marks a message as read                 |
| `delete-message`          | Deletes a message and cleans up inbox   |
| `update-encryption-key`   | Updates user's encryption key           |
| `update-account-status`   | Updates the user account's status       |

---

## 🧩 Read-Only Functions

| Function                    | Description                                         |
| --------------------------- | --------------------------------------------------- |
| `get-user-profile`          | Returns full user details                           |
| `is-user-registered`        | Checks if a user is registered                      |
| `get-message-details`       | Retrieves full message metadata                     |
| `get-user-inbox`            | Lists all message IDs in user's inbox               |
| `get-platform-statistics`   | Global user and message statistics                  |
| `get-user-activity-summary` | Overview of user's activity and status              |
| `get-inbox-analytics`       | Message count, unread, and priority message metrics |

---

## 🛑 Constants and Error Codes

| Constant            | Description                       |
| ------------------- | --------------------------------- |
| `ACCESS-DENIED`     | Unauthorized access attempt       |
| `USER-EXISTS`       | User already registered           |
| `USER-NOT-FOUND`    | User does not exist               |
| `MESSAGE-NOT-FOUND` | Invalid or missing message ID     |
| `INBOX-FULL`        | Recipient inbox has reached limit |
| `MESSAGE-TOO_LARGE` | Content exceeds max size (1024 B) |
| `INVALID-KEY`       | Encryption key is too short       |

---

## 🔐 Security & Best Practices

* All user actions are authorized via `tx-sender`.
* Encryption key lengths are strictly validated.
* Messages are marked as read and tracked for delivery status.
* Private helper functions handle inbox and analytics logic.
