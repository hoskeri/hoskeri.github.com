AbhijitHoskeri.pdf: resume.txt
	expand -t2 resume.txt > resume.tmp
	mv resume.tmp resume.txt
	pandoc -s -c resume.css resume.txt > resume.html
	wkhtmltopdf resume.html AbhijitHoskeri.pdf
