#!/bin/bash

echo "Det här skriptet antar att du har ställt in firefox så att den skrollar precis en rad i swedbank per scrollhjulssteg som görs. Detta görs i skrivande stund genom att öppna about:config och sätta mousewheel.default.delta_multiplier_y till 30 och mousewheel.min_line_scroll_amount till 1. Se även till att stänga av scrollanimationen."
echo

echo "Markera Firofox-fönstret med Swedbank öppnat och navigerat till kontoutdraget."
firefox=$(xdotool selectwindow)
echo "Det valda fönstret har titel " $(xdotool getwindowname $firefox)

echo "Öppnar en sjuhelvetes massa tabbar. "
xdotool mousemove --sync --window $firefox 619 536

# Av någon jävla anledning visar Swedbank 114 rader per sida. Fråga mig inte varför.
antal_steg=10
echo "Öppnar $antal_steg tabbar med verifikat."
for i in $(seq $antal_steg); do
		xdotool click 2
		xdotool click 5
		sleep 0.05
done

echo "Går igenom $antal_steg tabbar och skriver ut dem."
for i in $(seq $antal_steg); do
	  # Det här kan vara helt jävla onödigt men Firefox är asmuppigt om
	  # musen är inte där man försöker operera.
		xdotool mousemove --window $firefox 2 2
	  sleep 0.1
		xdotool click 1
		sleep 0.1
		# Gå till nästa tabb åt höger.
		xdotool key --window $firefox "alt+Next"
		sleep 0.1
		# Here we are relying on the Firefox plugin Vim Vixen because
		# apparently it's in-fucking possible to search for button labels in
		# normal Firefox. How would any blind person ever be able to use this
		# software?
		echo "Initierar utskriften."
		# Firefox skiter på sig om man inte har musen över
		# fönstret. Fokuset ligger på magiskt vis kvar i den gamla tabben
		# som inte är i fokus.
		xdotool key --window $firefox --delay 100 "shift+Tab" "shift+Tab" "Return"
		sleep 1
		printer_dialog=$(xdotool getactivewindow)
		# By now the print dialog should have appeared and we want to elect to
		# print to file.
		echo "Navigerar utskriftsdialogen."
		xdotool key --window $printer_dialog "Down"
		xdotool type --window $printer_dialog "Print to File"
		echo "Skriver ut."
		xdotool key --window $printer_dialog "Return"
		sleep 1.5
		echo "Stänger firefoxpopuprutan som Swedbank öppnade."
		xdotool key "Super_L+q"
		sleep 0.2
		echo "Stänger tabben med transaktionsuppgifter."
		xdotool key --window $firefox "ctrl+w"

		downloaded_file="/home/rovanion/Downloads/great-sleep.pdf"
		outpath="/home/rovanion/source/spexet/swedbank-underlag/underlag/"
		echo "Tar hand om den nedladdade filen."
		mv $downloaded_file $outpath
		meddelande=$(pdfgrep Meddelande $outpath/great-sleep.pdf | awk '{print $4}')
		echo $meddelande
		mv ${outpath}/great-sleep.pdf ${outpath}/${meddelande}.pdf
done
