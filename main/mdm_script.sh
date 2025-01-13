#!/bin/bash

# Colores para mensajes
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
NC='\033[0m'

# URL del script remoto
REMOTE_SCRIPT_URL="https://raw.githubusercontent.com/hectoraparici0/bypass-mdm-mac/main/mdm_script.sh"
TEMP_SCRIPT="/tmp/mdm_temp.sh"

# Función para descargar el script
download_latest_script() {
    echo -e "${BLU}Descargando la última versión del script desde $REMOTE_SCRIPT_URL...${NC}"
    curl -fsSL "$REMOTE_SCRIPT_URL" -o "$TEMP_SCRIPT"
    if [ $? -eq 0 ]; then
        echo -e "${GRN}Descarga completada exitosamente.${NC}"
        chmod +x "$TEMP_SCRIPT"
        echo -e "${YEL}Ejecutando la última versión del script...${NC}"
        bash "$TEMP_SCRIPT"
        exit 0
    else
        echo -e "${RED}Error al descargar el script remoto. Continuando con la versión local.${NC}"
    fi
}

# Inicia descargando el script remoto
download_latest_script

# Función para obtener el nombre del volumen del sistema
get_system_volume() {
    system_volume=$(diskutil info / | grep "Device Node" | awk -F': ' '{print $2}' | xargs diskutil info | grep "Volume Name" | awk -F': ' '{print $2}' | tr -d ' ')
    echo "$system_volume"
}

# Obtén el nombre del volumen del sistema
system_volume=$(get_system_volume)

# Mostrar encabezado
echo -e "${CYAN}Eliminar MDM por AparicioEdgeTech${NC}"
echo ""

# Opciones de menú
PS3='Por favor, ingrese su elección: '
options=("Remover MDM desde Recuperación" "Reiniciar y Salir")
select opt in "${options[@]}"; do
    case $opt in
        "Remover MDM desde Recuperación")
            echo -e "${YEL}Remover MDM desde Recuperación${NC}"
            
            if [ -d "/Volumes/$system_volume - Data" ]; then
                diskutil rename "$system_volume - Data" "Data"
            fi

            # Crear usuario temporal
            echo -e "${NC}Crear un Usuario Temporal"
            read -p "Ingrese el Nombre Completo Temporal (Predeterminado es 'Apple'): " realName
            realName="${realName:=Apple}"
            read -p "Ingrese el Nombre de Usuario Temporal (Predeterminado es 'Apple'): " username
            username="${username:=Apple}"
            read -p "Ingrese la Contraseña Temporal (Predeterminado es '1234'): " passw
            passw="${passw:=1234}"

            # Crear el usuario
            dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
            echo -e "${GRN}Creando Usuario Temporal${NC}"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
            mkdir "/Volumes/Data/Users/$username"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
            dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
            dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"

            # Bloquear dominios MDM
            echo "0.0.0.0 deviceenrollment.apple.com" >>/Volumes/"$system_volume"/etc/hosts
            echo "0.0.0.0 mdmenrollment.apple.com" >>/Volumes/"$system_volume"/etc/hosts
            echo "0.0.0.0 iprofiles.apple.com" >>/Volumes/"$system_volume"/etc/hosts
            echo -e "${GRN}Dominios de MDM y Perfil reconfigurados exitosamente.${NC}"

            # Remover perfiles de configuración
            touch /Volumes/Data/private/var/db/.AppleSetupDone
            rm -rf /Volumes/"$system_volume"/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
            rm -rf /Volumes/"$system_volume"/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
            touch /Volumes/"$system_volume"/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/"$system_volume"/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound

            echo -e "${GRN}La inscripción en MDM ha sido configurada.${NC}"
            echo -e "${NC}Salga del terminal y reinicie su Mac.${NC}"
            break
            ;;
        "Reiniciar y Salir")
            echo "Reiniciando..."
            reboot
            break
            ;;
        *) echo "Opción inválida $REPLY" ;;
    esac
done
