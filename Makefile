resume.pdf: resume.txt
	pandoc -s -c resume.css resume.txt > resume.html
	wkhtmltopdf resume.html resume.pdf
