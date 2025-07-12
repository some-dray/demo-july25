
#!/bin/bash

set -e

# --- Prerequisites Check ---
if ! command -v docker &> /dev/null
then
    echo "Docker could not be found. Please install Docker to run this demo."
    exit 1
fi

if ! command -v grype &> /dev/null
then
    echo "Grype could not be found. Please install Grype to run this demo."
    echo "Installation instructions: https://github.com/anchore/grype"
    exit 1
fi

echo "--- Prerequisites met ---"

# --- Image Names ---
DEBIAN_IMAGE="python-debian-demo"
DEBIAN_FULL_IMAGE="python-debian-full-demo"
CHAINGUARD_IMAGE="python-chainguard-demo"

# --- Build Debian Image ---
echo "
Building Debian-based image: $DEBIAN_IMAGE..."
docker build -t $DEBIAN_IMAGE -f Dockerfile.debian .

# --- Scan Debian Image ---
echo "
Scanning $DEBIAN_IMAGE with Grype..."
# Create a temporary directory for the report
mkdir -p reports
grype $DEBIAN_IMAGE -o json > ./reports/grype-report-debian.json

# --- Build Debian Full Image ---
echo "
Building Debian-based image: $DEBIAN_FULL_IMAGE..."
docker build -t $DEBIAN_FULL_IMAGE -f Dockerfile.debian-full .

# --- Scan Debian Full Image ---
echo "
Scanning $DEBIAN_FULL_IMAGE with Grype..."
# Create a temporary directory for the report
mkdir -p reports
grype $DEBIAN_FULL_IMAGE -o json > ./reports/grype-report-debian-full.json

# --- Build Chainguard Image ---
echo "
Building Chainguard-based image: $CHAINGUARD_IMAGE..."
docker build -t $CHAINGUARD_IMAGE -f Dockerfile.chainguard .

# --- Scan Chainguard Image ---
echo "
Scanning $CHAINGUARD_IMAGE with Grype..."
grype $CHAINGUARD_IMAGE -o json > ./reports/grype-report-chainguard.json

# --- Final Instructions ---
echo "
--- Starting Containers! ---
"
echo "--- Debian Container (Slim Image) ---"
docker run -d -p 8080:8080 --rm -v $(pwd)/reports/grype-report-debian.json:/app/grype-report.json:ro --name $DEBIAN_IMAGE $DEBIAN_IMAGE

echo "--- Chainguard Container (Secure Image) ---"
docker run -d -p 8081:8080 --rm -v $(pwd)/reports/grype-report-chainguard.json:/app/grype-report.json:ro --name $CHAINGUARD_IMAGE $CHAINGUARD_IMAGE

echo "--- Debian Container (Full Image) ---"
docker run -d -p 8082:8080 --rm -v $(pwd)/reports/grype-report-debian-full.json:/app/grype-report.json:ro --name $DEBIAN_FULL_IMAGE $DEBIAN_FULL_IMAGE

# --- Final Instructions ---
echo "
--- Demo Ready! ---
"
echo "Three Docker images have been built and scanned for vulnerabilities."
echo "The vulnerability reports have been saved in the 'reports' directory."
echo "
To run the containers and view the reports, use the following commands:
"
echo "--- Debian Container (Slim Image) ---"
echo "Then open ${bold}http://localhost:8080${normal} in your browser."
echo "To stop the container, run: ${bold}docker stop $DEBIAN_IMAGE${normal}"


echo "--- Chainguard Container (Secure Image) ---"
echo "Then open ${bold}http://localhost:8081${normal} in your browser."
echo "To stop the container, run: ${bold}docker stop $CHAINGUARD_IMAGE${normal}"


echo "--- Debian Container (Full Image) ---"
echo "Then open ${bold}http://localhost:8082${normal} in your browser."
echo "To stop the container, run: ${bold}docker stop $DEBIAN_FULL_IMAGE${normal}"

echo "
${bold}Notice the significant difference in the number of vulnerabilities!${normal}"
