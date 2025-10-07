#!/bin/sh

cleanup(){
	echo "Удаляем временные файлы"
	rm -rf "$TEMP_DIR"
}

#Exit-выход, INT-прерывание, TERM-завершение, HUP-разрыв соединение(закрытие терминала).
trap cleanup EXIT INT TERM HUP

if [ $# -eq 0 ];
then
	echo "Ошибка: Не указан файл для компиляции"
	exit 1
fi

c_file="$1"

if [ ! -f "$c_file" ];
then
	echo "Ошибка: Файл $c_file не найден"
	exit 1
fi

output_name=$(grep "&Output:" "$c_file" | cut -d ' ' -f2)

if [ -z "$output_name" ];
then
	echo "Ошибка: Не найден входной комментарий"
	exit 1
fi


TEMP_DIR=$(mktemp -d)
echo "Временная папка: $TEMP_DIR"

cp "$c_file" "$TEMP_DIR/" || {
	echo "Ошибка: не удалось скопировать файл"
	exit 1
}

cd "$TEMP_DIR" || {
	echo "Ошибка: не удалось перейти в $TEMP_DIR"
	exit 1
}

case "$c_file" in
	*.c)
		if ! cc "$(basename "$c_file")" -o "$output_name";
		then
			echo "Ошибка: компиляции С файла не удалось"
			exit 1
		fi
		;;
	*)
		echo "Неподдерживаемый тип файла: $c_file"
		exit
esac

cp "$output_name" "$OLDPWD/" || {
	echo "Ошибка при копирование" 
	exit 1
}
