## **Java JDK Installation on a User’s home directory**:
### Overview:
#### This script installs Java JDK 17 in the current user's home directory without requiring sudo, root access, or package managers. With Features:
* No sudo/root required - run as any user.
+ Downloads and installs OpenJDK 17 (Eclipse Temurin). 
* Installs Java in user's home directory (~/java/). 
+ Configures environment variables automatically (JAVA_HOME, PATH). 
* Runnable/Idempotent - safe to run multiple times.  



### Requirements:
-	Java jdk source with wget or curl available.

### Installation

#### Quick Start

```bash
# Download the script
wget 

# Make it executable
chmod +x task

# Run with sudo
sudo bash task
```

#### Manual Download

1. Download the `task` script
2. Make it executable: `chmod +x task`
3. Run: `sudo bash task`

### Usage

#### First Time Setup

```bash
sudo bash task
```

### Verify Installation

```bash
# Switch to pet-clinic user
sudo su - pet-clinic

# Check Java version
java -version

# Check Java home
echo $JAVA_HOME

# Check Java location
which java
```

### Rerun the Script

The script is idempotent and safe to run multiple times:

```bash
sudo bash task
```

#### Output Architecture
/home/pet-clinic/          ← pet-clinic user's home directory  
    └── java/                  ← Java installation directory  
      └── jdk-17.0.9+9/      ← JDK installation  
           ├── bin/           ← Java executables (java, javac, etc.)  
           │   ├── java  
           │   ├── javac  
          │   └── ...  
          ├── lib/  
          ├── conf/  
          └── ...  
