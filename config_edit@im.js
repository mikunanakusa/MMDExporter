file = new ActiveXObject("Scripting.FileSystemObject");
current_dir = file.GetParentFolderName(WScript.ScriptFullName);

var args = WScript.Arguments;

if(args.length != 1) {
		WScript.Echo("convert.exe�t�@�C����������identify.exe�t�@�C�����h���b�v���Ă��������B");
	WScript.Quit();
}

convert_filepath = args(0);
if(file.FileExists(convert_filepath) != true) {
		WScript.Echo("convert.exe�t�@�C����������identify.exe�t�@�C�����h���b�v���Ă��������B");
	WScript.Quit();
}

if((file.getFileName(convert_filepath) != "convert.exe") &&
	(file.getFileName(convert_filepath) != "identify.exe")) {
		WScript.Echo("convert.exe�t�@�C����������identify.exe�t�@�C�����h���b�v���Ă��������B");
		WScript.Quit();
}

if(file.FileExists(current_dir + "\\MMDExporter_config.rb") != true) {
	WScript.Echo("�J�����g�t�H���_��MMDExporter_config.rb�t�@�C��������܂���B");
	WScript.Quit();
}

var config_filename, f, ruby_file, re, dst;
config_filename = (current_dir + "\\MMDExporter_config.rb");
f = file.OpenTextFile(config_filename, 1);
ruby_file = f.ReadAll();
f.Close();

dst = "@@imageMagickDir = \"" + file.GetParentFolderName(convert_filepath) + "\"\n";
dst = dst.replace(/\\/g, "\\\\");
if (/@@imageMagickDir.+\n/.test(ruby_file) == true) {
	ruby_file = ruby_file.replace(/@@imageMagickDir.+\n/, dst)
} else {
	if (/end/.test(ruby_file) == true) {
		ruby_file = ruby_file.replace(/end/, dst + "end\n");
	} else {
		WScript.Echo("MMDExporter_config.rb�t�@�C������convert.exe�t�@�C�������identify.exe�t�@�C���̏ꏊ��\n�L�q����ꏊ��������܂���ł����B�������������𒆎~���܂��B\nMMDExporter_config.rb�t�@�C���̓��e���m�F���Ă��������B");
		WScript.Quit();
	}
}

f = file.OpenTextFile(config_filename, 2);
f.Write(ruby_file);
f.Close();

WScript.Echo("MMDExporter_config.rb�t�@�C���̏����������������܂����B");
WScript.Quit();