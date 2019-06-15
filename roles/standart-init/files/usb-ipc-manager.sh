#! /bin/sh
#------------------------------------------------------------------------------------------------------------------------
# USB Information Protection and Control MANAGER Shell-script
# Скрипт учета и избирательного использования USВ-носителей
# только для ОС CentOS 7
# Разработчик: Павел Савков, Военная академия, 2018
#------------------------------------------------------------------------------------------------------------------------
[ $(uname -r | /bin/grep -c 'el7') == "0" ] && /usr/bin/zenity --error --text "Скрипт предназначен только для ОС CentOS 7" 2>/dev/null && exit 1
[ $(/usr/bin/systemctl status usbguard.service | /bin/grep -c 'active') == "0" ] && /usr/bin/zenity --error --text "Требуется установить пакет usbguard и настроить его автозагрузку" 2>/dev/null && exit 1

# Настройка загрузки usbguard
/usr/bin/usbguard generate-policy -X -P > /etc/usbguard/rules.conf
/bin/systemctl enable usbguard.service
[ $(/bin/systemctl status usbguard.service | /bin/grep -c 'running') == "0" ] && /bin/systemctl start usbguard.service 

# ОБЪЯВЛЕНИЕ ПУТЕЙ К КАТАЛОГАМ И ФАЙЛАМ В /ETC
IPCDIR="/root/usb-ipc"
JURLOG="${IPCDIR}/usb-ipc-jurnal.log" # журнал учета USB-носителей
USBGUARD_RULES="/etc/usbguard/rules.conf"
[ ! -e ${JURLOG} ] && touch ${JURLOG} && chown root.root ${JURLOG}
# Создание заголовка для журнала учета подключений USB-носителей
if [ "$(/bin/sed -n '1p' ${JURLOG} | /usr/bin/wc -m)" == "0" ]
then
# Создание заголовка в журнале учета подключений USB-носителей
/bin/cat > ${JURLOG} <<EOF
ЖУРНАЛ УЧЕТА USB-НОСИТЕЛЕЙ:$(date +%B):$(date +%Y)
Дата      Cерийный номер МНИ      Объем     Уровень доступа   Уч.№ МНИ          Пользователь          Подразделение     Статус  
*********************************************************************************************************************************
EOF

# Удаление из USBGUARD_RULES всех неизвестных съемных МНИ
/bin/sed -i '/with-interface 08:..:../d' ${USBGUARD_RULES}
fi


# Статус выполнения программы 0-норма, 1-ошибка
RETVAL=0

##################################################################################################################
#Функция проверка прав на запуск скипта
check_root() {
	# Проверка, что вы - привилегированный пользователь
	[ "$(/usr/bin/id -u)" != "0" ] && /usr/bin/zenity --error --text "Требуются права root" 2>/dev/null && exit 1
}

#####################################################################################
#
#  Функция проверки подключенного USB-носителя перед форматированием шифрованной ФС
#
#####################################################################################
allow_new_usb() {
_USB_DISK=$(/usr/bin/usbguard list-devices | /bin/grep -c '08:..:..')
[ ${_USB_DISK} == "0" ] && /usr/bin/zenity --error --text="Нет подключенных USB-носителей" 2>/dev/null && exit 1
[ ${_USB_DISK} -gt "1" ] && /usr/bin/zenity --error --text="Должен быть подключен только один USB-носитель" 2>/dev/null && exit 1
USB_SERIAL=$(/usr/bin/usbguard list-devices | /bin/grep '08:..:..' | /usr/bin/awk '{ print $6 }' | /usr/bin/tr -d '"')
[ -z ${USB_SERIAL} ] && /usr/bin/zenity --error --text "USB-диск не имеет серийного номера" 2>/dev/null && exit 1

# Временно разрешить новый диск (отсутствующий в белом списке)
_USB_ID=$(/usr/bin/usbguard list-devices -b | /bin/grep '08:..:..' | /bin/sed -n '1p' | /usr/bin/awk '{ print $1 }' | /bin/tr -d ':')
if [ ! -z ${_USB_ID} ];
then
/usr/bin/usbguard allow-device ${_USB_ID}
/usr/bin/zenity --info --title="Правила USBguard" --title="Временно разрешено подключение USB-диска" --text="Временно разрешено подключение USB-диска ${USB_SERIAL}" --width=300 2>/dev/null
fi

#Определение имени устройства USB-диска	
for _disk in $(/sbin/blkid -o device | /bin/sed -n '/mapper/!p' | /usr/bin/tr -d [:digit:] | /usr/bin/uniq)
    do
    if [ $(/sbin/udevadm info -q env -n ${_disk} | /bin/grep -c "usb-storage") == "1" ]
    then
	USBDEV=$(/sbin/blkid -o device | /bin/sed -n '/mapper/!p' | /bin/grep ${_disk}) # наименование USB-устройства (раздел или весь диск без разделов)
    fi 
done

# Определение атрибутов нового USB-диска, отсутствующего в журнале учета
if [ "$(/bin/grep -c ${USB_SERIAL} ${JURLOG})" == "0" ];
then


# Гриф секретности диска
USB_LEVEL=$( /usr/bin/zenity --list --radiolist --text="Какой тип USB-носителя подключен?" --column "Ключ" --column "Тип USB-носителя" TRUE "Секретный" FALSE "Несекретный" 2>/dev/null )
[ $? == "1" ] && /usr/bin/zenity --error --text="Требуются указать гриф секретности МНИ" --width=300 2>/dev/null && exit 1

# Установка учетного номера МНИ
_USB_REG=$( /usr/bin/zenity --entry --title='Введите учетный номер МНИ' --text='Пример учета МНИ: 1234/К207/НС' --width=300  2>/dev/null )
USB_REG=$(echo ${_USB_REG} | /usr/bin/tr -d ' ')
[ -z "${USB_REG}" ] && /usr/bin/zenity --error --text "Требуются ввести учетный номер МНИ" --width=300 2>/dev/null && exit 1

# Ввод ответственного за МНИ
_USB_USER=$( /usr/bin/zenity --entry --title="Ответственный" --text="Введите фамилию ответственного за МНИ" --width=300 2>/dev/null )
USB_USER=$(echo ${_USB_USER} | /usr/bin/tr -d ' ')
[ -z "${USB_USER}" ] && /usr/bin/zenity --error --text "Требуются указать ответственного за МНИ" --width=300 2>/dev/null && exit 1

# Ввод структурного подразделения
_USB_UNIT=$( /usr/bin/zenity --entry --title="Подразделение, в котором учтен МНИ" --text="Введите без пробелов. Например: 8-отдел" --width=300 2>/dev/null )
USB_UNIT=$(echo ${_USB_UNIT} | /usr/bin/tr -d ' ')
[ -z "${USB_UNIT}" ] && /usr/bin/zenity --error --text "Требуются указать стр.подразделение, в котором учтен МНИ" --width=300 2>/dev/null && exit 1

# Объем USB-диска
USB_SIZE=$(/bin/df -h | /bin/grep ${USBDEV} | /usr/bin/awk '{ print $2 }')

# Учет USB-дисков
echo -e "$(date +%D)" "${USB_SERIAL}" "${USB_SIZE}" "${USB_LEVEL}" "${USB_REG}" "${USB_USER}" "${USB_UNIT}" "allow" | /usr/bin/awk '{ printf "%-10s%-24s%-10s%-18s%-18s%-22s%-18s%-6s\n", $1, $2, $3, $4, $5, $6, $7, $8 }' >> ${JURLOG}

# Добавить новый USB-диск в правила /etc/usbguard/rules.conf
if [ $(/bin/grep -c ${USB_SERIAL} ${USBGUARD_RULES}) == "0" ];
then
/usr/bin/usbguard generate-policy -P -X | grep 'with-interface 08:..:..' >> ${USBGUARD_RULES}
/usr/bin/systemctl restart usbguard.service
fi
/usr/bin/zenity --info --title="USB-диск зарегистрирован" --text="USB-диск учтен и разрешен для использования" --width=300 2>/dev/null

else
/usr/bin/zenity --error --title="USB-диск уже учтен" --text="USB-носитель ${USB_SERIAL} был учтен ранее" --width=300 2>/dev/null
fi

}

#####################################################################################
#  Функция блокировки разрешенных USB-носителей, зарегистрированных в журнале учета
#####################################################################################
block_usb() {
[ $(/bin/sed -n '3,$p' ${JURLOG} | /bin/grep '^[0-9]' | /bin/grep -c 'allow') == "0" ] && /usr/bin/zenity --error --text="Нет съемных МНИ для разблокировки" --width=300 2>/dev/null && exit 1
BAD_USB=$(/bin/sed -n '3,$p' ${JURLOG} | /bin/grep '^[0-9]' | /bin/grep 'allow' | /usr/bin/awk '{print $2":"$3":"$4}' | /usr/bin/zenity --list --title="Блокировка USB-диска" --text="Какой USB-диск заблокировать?" --column "Журнал учета USB-дисков" 2>/dev/null )
[ $? == "1" ] && /usr/bin/zenity --error --text="Съемный МНИ для блокировки не выбран" --width=300 2>/dev/null && exit 1

SERIAL_BAD_USB=$(echo ${BAD_USB} | /usr/bin/awk -F: '{ print $1 }')
if [ $(/bin/grep -c ${SERIAL_BAD_USB} ${USBGUARD_RULES}) != "0" ];
then
/bin/sed -i "/${SERIAL_BAD_USB}/s/allow/block/g" ${USBGUARD_RULES}
/usr/bin/systemctl restart usbguard.service
/bin/sed -i "/${SERIAL_BAD_USB}/s/allow/block/g" ${JURLOG}
fi
/usr/bin/zenity --info --title="USB-диск заблокирован" --text="Учтенный USB-диск ${USB_SERIAL} заблокирован" --width=300 2>/dev/null
}

#####################################################################################
#  Функция отмены блокировки разрешенных USB-носителей, зарегистрированных в журнале учета
#####################################################################################
allow_usb() {
[ $(/bin/sed -n '3,$p' ${JURLOG} | /bin/grep '^[0-9]' | /bin/grep -c 'block') == "0" ] && /usr/bin/zenity --error --text="Заблокированных съемных МНИ нет" --width=300 2>/dev/null && exit 1
ALLOW_USB=$(/bin/sed -n '3,$p' ${JURLOG} | /bin/grep '^[0-9]' | /bin/grep 'block' | /usr/bin/awk '{print $2":"$3":"$4}' | /usr/bin/zenity --list --title="Снятие блокировки USB-диска" --text="Какой USB-диск разблокировать?" --column "Журнал учета USB-дисков" 2>/dev/null )
[ $? == "1" ] && /usr/bin/zenity --error --text="Съемный МНИ для снятия блокировки не выбран" --width=300 2>/dev/null && exit 1
SERIAL_ALLOW_USB=$(echo ${ALLOW_USB} | /usr/bin/awk -F: '{ print $1 }')
if [ $(/bin/grep -c ${SERIAL_ALLOW_USB} ${USBGUARD_RULES}) != "0" ];
then
/bin/sed -i "/${SERIAL_ALLOW_USB}/s/block/allow/g" ${USBGUARD_RULES}
/usr/bin/systemctl restart usbguard.service
/bin/sed -i "/${SERIAL_ALLOW_USB}/s/block/allow/g" ${JURLOG}
fi
/usr/bin/zenity --info --title="USB-диск разблокирован" --text="Учтенный USB-диск ${USB_SERIAL} разблокирован" --width=300 2>/dev/null
}

##################################################################################################################
case "$1" in
    --new-usb|-n)
	check_root
	allow_new_usb
    ;;
    --block_usb|-b)
        check_root
        block_usb
    ;;
    --allow_usb|-a)
        check_root
        allow_usb
    ;;
    --jurnal|-j)
	/bin/cat "${JURLOG}"	
    ;;
    --help|-h)
    echo -e "\nФОРМАТ:	usb-ipc-manager.sh [--help|-h] [--jurnal|-j] [--new-usb|-n] [--allow-usb|-a] [--block-usb|-b]

ОПИСАНИЕ: 		
    USB Information Protection and Control Manager Shell-script 
    Скрипт регистрации USВ-носителей и настройки их избирательного использования на основе 'белого списка'.
    Он включает 5 основных функций: 
    1) регистрация нового USB-носителя
    2) блокировка учтенного USB-носителя
    3) разблокировка учтенного USB-носителя
    4) вывод журнала учета USB-носителей
    5) вывод справка
Для работы скрипта обязательно требуется установить пакет 'usbguard': 
    yum install usbguard
и настроить автозагрузку службы 'usbguard.service': 
    systemctl enable usbguard.service
    systemctl start usbguard.service

Пример использования: usb-ipc-manager -n 

Разработчик: Павел Иванович Савков, Военная академия, 2018

СПРАВКА ПО КЛЮЧАМ:

    --help | -h		Вывод справки

    --jurnal | -j	Вывод журнала учета съемных USB-носителей из файла /root/usb-ipc/usb-ipc-jurnal.log

    --new-usb | -n	Регистрация нового съемного МНИ с записью в отдельном журнале /root/usb-ipc/usb-ipc-jurnal.log
			Новый МНИ автоматически включается в 'белый список' разрешенных МНИ

    --block-usb | -b	Блокировка учтенного МНИ. Состояние блокировки 'block' записывается в журнал учета 

    --allow-usb | -a	Снятие блокировки учтенного МНИ. Состояние блокировки 'allow' записывается в журнал учета 
"
    ;;
    *)
	echo $"Usage: $0 [--help|-h] [--jurnal|-j] [--new-usb|-n] [--allow-usb|-a] [--block-usb|-b]"
    ;;
esac
exit $RETVAL

