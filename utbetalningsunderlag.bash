#!/bin/bash

echo "Markera Firofox-fönstret med Swedbank öppnat och navigerat till kontoutdraget."


firefox=$(xdotool selectwindow)
echo "Det valda fönstret har titel " $(xdotool getwindowname $firefox)

while true; do
		echo "Börjar ta hem ett nytt underlag."
		# Firefox is really fucking wierd about focus. Keys does different
		# things depending on whether the search window has mouse focus or
		# not.
		xdotool mousemove --sync --window $firefox 619 536
		xdotool click 1
		# Search
		echo "Väljer nästa överföring."
		xdotool key --window $firefox "ctrl+f"
		xdotool type --window $firefox "Överföring via internet"
		sleep 0.5
		xdotool key --window $firefox "Escape" "ctrl+Return" "alt+Next"
		sleep 0.5
		# Here we are relying on the Firefox plugin Vim Vixen because
		# apparently it's in-fucking possible to search for button labels in
		# normal Firefox. How would any blind person ever be able to use this
		# software?
		echo "Initierar utskriften med Vim Vixen."
		xdotool type --window $firefox --delay 100 "fq"
		sleep 1
		printer_dialog=$(xdotool getactivewindow)
		# By now the print dialog should have appeared and we want to elect to
		# print to file.
		echo "Navigerar utskriftsdialogen."
		xdotool key --window $printer_dialog "Down"
		xdotool type --window $printer_dialog "Print to File"
		echo "Skriver ut."
		xdotool key --window $printer_dialog "Return"
		sleep 1
		echo "Stänger firefoxpopuprutan som Swedbank öppnade."
		xdotool key "Super_L+q"
		echo "Stänger tabben med transaktionsuppgifter."
		xdotool key --window $firefox "ctrl+w"

		echo "Tar hand om den nedladdade filen."
		outpath="/home/rovanion/source/spexet/swedbank-underlag/underlag/"
		mv ~/Downloads/great-sleep.pdf $outpath
		meddelande=$(pdfgrep Meddelande $outpath/great-sleep.pdf | awk '{print $4}')
		echo $meddelande
		mv ${outpath}/great-sleep.pdf ${outpath}/${meddelande}.pdf
done
