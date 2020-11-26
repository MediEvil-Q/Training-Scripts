TASK:
1. Создать Env Variables, которые будут указывать на место забора файла (inputFolder) и папку вывода (outputFolder).
2. Используя Env Variables, создать скрипт, который:
	-	С папки inputFolder будет забирать последний созданый файл;
	-	Доставать EAN товаров и по ним узнавать новую цену товаров;
	-	Создавать в outputFolder файлы для каждого товара в формате .txt.

	Структура внутренностей файла:
		Name: {НАЗВАНИЕ_ТОВАРА}
		EAN: {EAN}
		OldPrice: {ЦЕНА_В_INPUTFILE}
		NewPrice: {ПОСЛЕДНЯЯ_ЦЕНА_ИЗ_API}
		InStock: {НАЛИЧИЕ}

	Название файла должно соответствовать EAN'у. (Пример: 04820142438464.txt)

	Также, у скрипта должен быть GUI, который должен параллельно логироваться в {ДАТАВРЕМЯ}.log в папке outputFolder. Пример экрана:

	--- BEGIN ---
	Date/Time: {ДАТАВРЕМЯ}.log
	Checking latest file in {ПОЛНОЕ НАЗВАНИЕ ДИРЕКТОРИИ inputFile}....
	Done! Filename: {НАЗВАНИЕ ПОСЛЕДНЕГО СОЗДАННОГО ФАЙЛА}
	Found {КОЛСТВО ТОВАРОВ} items.
	Fetching new prices...

	~~~~~
	Getting EAN {НОМЕР EAN}...
	Fetched:
		Name: {НАЗВАНИЕ_ТОВАРА}
		EAN: {НОМЕР EAN}
		OldPrice: {ЦЕНА_В_INPUTFILE}
		NewPrice: {ПОСЛЕДНЯЯ_ЦЕНА_ИЗ_API}
		InStock: {НАЛИЧИЕ}
	Saving to {ПОЛНОЕ НАЗВАНИЕ ДИРЕКТОРИИ outputFolder}/{НОМЕР EAN}.txt... Done!
	~~~~~
	Getting EAN {НОМЕР EAN}...
	Fetched:
		Name: {НАЗВАНИЕ_ТОВАРА}
		EAN: {НОМЕР EAN}
		OldPrice: {ЦЕНА_В_INPUTFILE}
		NewPrice: {ПОСЛЕДНЯЯ_ЦЕНА_ИЗ_API}
		InStock: {НАЛИЧИЕ}
	Saving to {ПОЛНОЕ НАЗВАНИЕ ДИРЕКТОРИИ outputFolder}/{НОМЕР EAN}.txt... Done!
	~~~~

	Fetching complete!
	Script was running for {КОЛИЧЕСТВО СЕКУНД РАБОТЫ} sec.

	--- END ---