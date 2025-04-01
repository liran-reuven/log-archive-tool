# 📜 Log Archive Tool

**A powerful and efficient tool for archiving, managing, and analyzing system logs.**

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Features](#features)
3. [Technologies Used](#technologies-used)
4. [Installation](#installation)
5. [Usage](#usage)
6. [Configuration](#configuration)
7. [Folder Structure](#folder-structure)
8. [Examples](#examples)
9. [Contributing](#contributing)
10. [License](#license)

---

## 🚀 Introduction

The **Log Archive Tool** is a robust and scalable solution for organizing, compressing, and storing system logs securely. Designed for IT professionals, DevOps engineers, and system administrators, this tool helps manage large volumes of logs efficiently, preventing clutter while ensuring easy retrieval and analysis.

---

## 🌟 Features

- 📂 **Automated Archiving**: Compress and store logs periodically to save space.
- 🔍 **Search and Filter**: Quickly find relevant logs using date and keyword filters.
- 🛠 **Customizable Retention Policies**: Set rules for how long logs should be kept before deletion.
- 📈 **Log Analysis**: Generate insights and summaries from log files.
- 🔒 **Secure Storage**: Encrypt and store logs in a safe location.
- 🌐 **Cross-Platform Support**: Works on Windows, macOS, and Linux.

---

## 🛠️ Technologies Used

- **Languages**: Python
- **Libraries**:
  - `os` and `shutil` for file management.
  - `gzip` for log compression.
  - `argparse` for command-line options.
  - `logging` for tracking operations.
  - `cryptography` (optional) for encrypting logs.

---

## 💻 Installation

To install and use **Log Archive Tool**, follow these steps:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/username/log-archive-tool.git
   ```
2. **Navigate to the Project Folder**:
   ```bash
   cd log-archive-tool
   ```
3. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
4. **Run the Application**:
   ```bash
   python archive.py
   ```

---

## 🎮 Usage

### Command-Line Interface (CLI)

1. **Archive Logs**:
   ```bash
   python archive.py --path /var/logs --compress --output /backup/logs
   ```
2. **Search Logs**:
   ```bash
   python archive.py --search "error" --date 2024-04-02
   ```
3. **Set Retention Policy**:
   ```bash
   python archive.py --retention 30  # Deletes logs older than 30 days
   ```

---

## ⚙️ Configuration

Modify the `config.json` file to set up custom archiving rules, retention periods, and storage locations.

Example `config.json`:
```json
{
  "log_directory": "/var/logs",
  "archive_directory": "/backup/logs",
  "compression": true,
  "retention_days": 30,
  "encryption": false
}
```

---

## 📂 Folder Structure

```
log-archive-tool/
│── archive.py       # Main script
│── config.json      # Configuration file
│── logs/            # Original logs
│── archived/        # Archived logs
│── backup/          # Backup storage
│── requirements.txt # Dependencies
└── README.md        # Project documentation
```

---

## 📊 Examples

- **Automatically archive logs every day using cron** (Linux):
  ```bash
  crontab -e
  ```
  Add the following line:
  ```bash
  0 0 * * * python /path/to/archive.py --path /var/logs --compress --output /backup/logs
  ```

- **Windows Task Scheduler** (Windows):
  - Create a task to run `python archive.py` at a scheduled time.

---

## 🤝 Contributing

Interested in improving **Log Archive Tool**? Here's how you can contribute:

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-branch
   ```
3. Commit your changes:
   ```bash
   git commit -m "Describe your changes"
   ```
4. Push to your branch:
   ```bash
   git push origin feature-branch
   ```
5. Open a Pull Request.

---

<!-- ## 📝 License

This project is licensed under the **MIT License**. See the `LICENSE` file for more details. -->
