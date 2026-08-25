# 🔎 Easy Nmap v2

**Easy Nmap v2** is a beginner-friendly Bash wrapper around [Nmap](https://nmap.org/) designed to make network reconnaissance and service enumeration simple, organized, and effective.

It supports **IP addresses, hostnames, subdomains, and target lists**, with multiple scan profiles and automatically organized timestamped reports.

> **For authorized security testing and educational purposes only.**

---

## ✨ Features

* 🎯 Single target scanning
* 📄 Multiple targets from a text file
* 🌐 Supports:

  * IPv4 addresses
  * Hostnames
  * Subdomains
  * Target lists
* 🔍 Multiple scan profiles
* ⚡ Fast scanning with configurable timing
* 🔌 TCP service discovery
* 📡 UDP scanning
* 🖥️ OS detection
* 🧩 Service/version detection
* 📜 Default Nmap NSE scripts
* 🌐 Web-focused scanning profile
* 🚀 Full-port scanning
* 📝 Normal Nmap output
* 📦 XML output
* 🔎 Grepable output
* 📁 Automatically organized reports
* 🕒 Timestamped scan directories
* 🎨 Clean colored terminal interface
* 🧑‍💻 Beginner-friendly CLI
* ⚙️ Supports command-line arguments

---

# 📋 Requirements

The script requires:

* Linux
* Bash
* Nmap
* Optional: `figlet`

### Install Nmap

Debian / Ubuntu / Kali:

```bash
sudo apt update
sudo apt install nmap
```

### Install Figlet

```bash
sudo apt install figlet
```

---

# 🚀 Installation

Clone the repository:

```bash
git clone https://github.com/r4vindra/Easy-NMAP.git
```

Move into the directory:

```bash
cd Easy-NMAP/
```

Make the script executable:

```bash
chmod +x easy-nmap.sh
```

Run it:

```bash
./easy-nmap.sh
```

---

# 🎯 Basic Usage

## Scan a single IP

```bash
./easy-nmap.sh 192.168.1.10
```

## Scan a hostname

```bash
./easy-nmap.sh example.com
```

## Scan a subdomain

```bash
./easy-nmap.sh dev.example.com
```

## Scan multiple targets

Create a file:

```text
targets.txt
```

Example:

```text
192.168.1.10
192.168.1.20
server.example.com
dev.example.com
```

Run:

```bash
./easy-nmap.sh targets.txt
```

Comments and blank lines are ignored.

---

# 🧭 Scan Profiles

Easy Nmap v2 provides multiple scan profiles.

### 1️⃣ Quick

Fast common-port discovery.

```bash
./easy-nmap.sh example.com --profile quick
```

Uses the most common 1000 TCP ports with service detection.

---

### 2️⃣ Standard

Recommended profile for general enumeration.

```bash
./easy-nmap.sh example.com --profile standard
```

Includes:

* TCP SYN scan
* Service/version detection
* Default NSE scripts

Equivalent core options:

```text
-sS -sV -sC
```

---

### 3️⃣ Full

Scans all TCP ports.

```bash
./easy-nmap.sh example.com --profile full
```

Useful when you don't want to rely only on common-port discovery.

---

### 4️⃣ Aggressive

Performs extensive enumeration.

```bash
./easy-nmap.sh example.com --profile aggressive
```

Uses Nmap's aggressive detection functionality, including:

* OS detection
* Service/version detection
* NSE scripts
* Traceroute

---

### 5️⃣ Web

Focuses on commonly used HTTP/HTTPS ports.

```bash
./easy-nmap.sh example.com --profile web
```

Useful during web application reconnaissance.

---

### 6️⃣ UDP

Scans common UDP ports.

```bash
./easy-nmap.sh example.com --profile udp
```

UDP scanning can be significantly slower than TCP scanning.

---

### 7️⃣ Custom

Specify your own ports.

```bash
./easy-nmap.sh example.com --ports 22,80,443
```

Port ranges are supported:

```bash
./easy-nmap.sh example.com --ports 1-1000
```

Multiple ports and ranges can also be combined:

```bash
./easy-nmap.sh example.com --ports 22,80,443,8000-8100
```

---

# ⚙️ Command-Line Options

| Option                 | Description               |
| ---------------------- | ------------------------- |
| `--profile quick`      | Fast common-port scan     |
| `--profile standard`   | Service + default scripts |
| `--profile full`       | All TCP ports             |
| `--profile aggressive` | Aggressive enumeration    |
| `--profile web`        | Common web ports          |
| `--profile udp`        | Common UDP ports          |
| `--profile custom`     | Custom port scan          |
| `--ports`              | Specify ports             |
| `--all-ports`          | Scan all TCP ports        |
| `--udp`                | UDP profile               |
| `--no-ping`            | Skip host discovery       |
| `--timing`             | Configure Nmap timing     |
| `-h`                   | Show help                 |

---

# 🧪 Examples

### Quick scan

```bash
./easy-nmap.sh 10.10.10.10 --profile quick
```

### Standard enumeration

```bash
./easy-nmap.sh 10.10.10.10 --profile standard
```

### Full TCP scan

```bash
./easy-nmap.sh 10.10.10.10 --all-ports
```

### Web enumeration

```bash
./easy-nmap.sh app.example.com --profile web
```

### UDP scan

```bash
./easy-nmap.sh 10.10.10.10 --udp
```

### Skip host discovery

```bash
./easy-nmap.sh 10.10.10.10 --profile standard --no-ping
```

### Custom timing

```bash
./easy-nmap.sh 10.10.10.10 --profile full --timing 4
```

---

# 📂 Report Structure

Every scan is automatically stored under:

```text
nmap-reports/
```

Example:

```text
nmap-reports/
└── example.com_20260825_171500/
    ├── nmap.txt
    ├── nmap.xml
    ├── nmap.gnmap
    └── summary.txt
```

For a target list:

```text
nmap-reports/
└── target-list_20260825_171500/
    ├── 192.168.1.10_20260825_171501/
    │   ├── nmap.txt
    │   ├── nmap.xml
    │   └── nmap.gnmap
    │
    ├── 192.168.1.20_20260825_171530/
    │   ├── nmap.txt
    │   ├── nmap.xml
    │   └── nmap.gnmap
    │
    └── example.com_20260825_171600/
        ├── nmap.txt
        ├── nmap.xml
        └── nmap.gnmap
```

---

# 📄 Output Formats

### `nmap.txt`

Human-readable Nmap output.

Useful for:

* Manual analysis
* VAPT reports
* Reviewing discovered services

### `nmap.xml`

Structured XML output.

Useful for:

* Importing into other security tools
* Automation
* Parsing scan results

### `nmap.gnmap`

Grepable output.

Useful for:

* Shell scripting
* Filtering results
* Automation pipelines

### `summary.txt`

Contains basic scan information such as:

* Target
* Scan profile
* Date/time
* Duration
* Output files

---

# 🛠️ Recommended Workflow

For a typical authorized penetration-testing engagement:

```text
Target
  │
  ▼
Quick Scan
  │
  ▼
Identify Open Ports
  │
  ▼
Standard Scan
  │
  ▼
Service / Version Enumeration
  │
  ▼
Full TCP Scan
  │
  ▼
UDP Enumeration
  │
  ▼
Manual Analysis
```

For web assets, the **Web** profile can be useful as an initial service-discovery step before performing dedicated web enumeration.

---

# ⚡ Why Easy Nmap?

Running Nmap manually is powerful, but beginners often have to remember multiple options and organize the resulting files themselves.

Easy Nmap provides a simple interface around common Nmap workflows:

```text
Choose Target
      ↓
Choose Profile
      ↓
Run Scan
      ↓
Organized Reports
      ↓
Analyze Results
```

The goal is to make Nmap easier to use without hiding what is actually happening underneath.

---

# 🔐 Authorization & Responsible Use

Easy Nmap is intended for:

* Security professionals
* Penetration testers
* CTF environments
* Security students
* Lab environments
* Authorized network assessments

**Only scan systems and networks that you own or have explicit permission to test.**

Unauthorized scanning may violate organizational policies, terms of service, or applicable laws.

The author is not responsible for misuse of this tool.

---

# 📌 Limitations

Easy Nmap is an automation wrapper around Nmap. It does **not** replace:

* Manual enumeration
* Vulnerability validation
* Web application testing
* API testing
* Active Directory assessment
* Vulnerability scanners
* Manual security analysis

An open port or detected service does not automatically mean that the service is vulnerable.

Always validate findings manually.

---

# 🗺️ Roadmap

Future improvements may include:

* [ ] Automatic vulnerability NSE profile
* [ ] HTML report generation
* [ ] Markdown report generation
* [ ] Service-based enumeration
* [ ] Automatic screenshots for HTTP services
* [ ] Integration with Nuclei
* [ ] Integration with httpx
* [ ] JSON output
* [ ] Better target validation
* [ ] Parallel target scanning
* [ ] Resume interrupted scans
* [ ] Configurable Nmap profiles
* [ ] Custom NSE script selection
* [ ] Interactive results dashboard

---

# 🤝 Contributing

Contributions, suggestions, and improvements are welcome.

If you find a bug or have an idea for a new feature, feel free to open an issue or submit a pull request.

---

# ⭐ Support

If you find **Easy Nmap** useful for your security testing or learning, consider giving the repository a ⭐.

---

## 👨‍💻 Author

**r4vindra**

Security Researcher | Penetration Tester

Built for making reconnaissance simple, organized, and beginner-friendly.

---

## 📜 License

This project is provided for educational and authorized security-testing purposes.

Add your preferred open-source license here, such as **MIT**, if you intend to distribute the project under that license.
