#!/bin/bash

#checking prerequisites sabbai ko lagi

set -e 

echo "Checking prerequisites for the project..."

ERRORS=0

#colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 

# Function to check if a command exists
check_command(){
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}[✔] $1 is installed.${NC}"
        if [ ! -z "$2" ]; then 
            VERSION=$($1 $2 2>&1 | head -n 1)
            echo -e "${YELLOW}    Version: $VERSION${NC}"
        fi
        return 0
    else
        echo -e "${RED}[✘] $1 is not installed.${NC}"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}
echo "-------------------------------------"

#npm
echo "Checking for npm..."
check_command "npm" "--version"
echo "-------------------------------------"

#curl
echo "Checking for curl..."
check_command "curl" "--version"
echo "-------------------------------------"

#jq for json parsing
echo "Checking for jq..."
check_command "jq" "--version"
echo "-------------------------------------"

#docker
echo "Checking for Docker..."
check_command "docker" "--version"
echo "-------------------------------------"

#yaci devkit runnig ?
echo "Checking for Yaci Devkit..."
if curl -s http://localhost:8080/api/v1/epochs/latest > /dev/null 2>&1; then
    echo -e "${GREEN}[✔] Yaci Devkit is running.${NC}"
    EPOCH=$(curl -s http://localhost:8080/api/v1/epochs/latest | jq -r '.epoch')
    echo " Current Epocjh: $EPOCH"
else
    echo -e "${RED}✗${NC} Yaci DevKit is NOT running"
    echo -e " ${YELLOW}Please start the Yaci Devkit before proceeding.${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo "-------------------------------------"

#ports
echo "Checking required ports..."
PORTS=(4001 4002 4003 5001 5002 5003 6001 6002 6003)
for port in "${PORTS[@]}"; do 
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${RED}[✘] Port $port is already in use.${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}[✔] Port $port is available.${NC}"
    fi
done
echo "-------------------------------------"

    
#disk space
echo "Checking disk space..."
AVILABLE_SPACE=$(df -h . | tail -1 | awk '{print $4}')
echo " Abailable disk space: $AVILABLE_SPACE"
echo -e " ${YELLOW} Recommended: 5GB hunuparxa.${NC}"
echo "-------------------------------------"

if [ $ERRORS -eq 0]; then 
     echo -e "${GREEN}✓ All prerequisites met!${NC}"
     echo ""
     echo "Aru steps: "
     echo "  1. npm install"
     echo "  2. npm run setup"
     echo "  3. cp .env.example .env"
     echo "  4. npm run keys:generate"
     exit 0
else     
    echo -e "${RED}✗ Found $ERRORS issue(s)${NC}"
    echo ""
    echo "Please install missing dependencies and try again."
    exit 1
fi

  
