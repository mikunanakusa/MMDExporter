module MMDExporter
	@@max_proc = 1
	
	@@rename_tga = true

	ImageMagickDir = 'C:\Program Files\ImageMagick-6.5.6-Q16/'
	@@imageMagick_convert = ImageMagickDir + 'convert.exe'
	@@imageMagick_identify = ImageMagickDir + 'identify.exe'
end
