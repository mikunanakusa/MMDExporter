module MMDExporter
	@@max_proc = 2
	
	@@rename_tga = true

	ImageMagickDir = 'C:\Program Files\ImageMagick-6.5.6-Q16/'
	@@imageMagick_convert = ImageMagickDir + 'convert.exe'
	@@imageMagick_identify = ImageMagickDir + 'identify.exe'
	
	Export_point_size = 65535

end
