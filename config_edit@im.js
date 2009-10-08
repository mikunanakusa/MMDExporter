file = new ActiveXObject("Scripting.FileSystemObject");
current_dir = file.GetParentFolderName(WScript.ScriptFullName);

var args = WScript.Arguments;

if(args.length != 1) {
		WScript.Echo("convert.exeファイルもしくはidentify.exeファイルをドロップしてください。");
	WScript.Quit();
}

convert_filepath = args(0);
if(file.FileExists(convert_filepath) != true) {
		WScript.Echo("convert.exeファイルもしくはidentify.exeファイルをドロップしてください。");
	WScript.Quit();
}

if((file.getFileName(convert_filepath) != "convert.exe") &&
	(file.getFileName(convert_filepath) != "identify.exe")) {
		WScript.Echo("convert.exeファイルもしくはidentify.exeファイルをドロップしてください。");
		WScript.Quit();
}

if(file.FileExists(current_dir + "\\MMDExporter_config.rb") != true) {
	WScript.Echo("カレントフォルダにMMDExporter_config.rbファイルがありません。");
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
		WScript.Echo("MMDExporter_config.rbファイル内にconvert.exeファイルおよびidentify.exeファイルの場所を\n記述する場所が見つかりませんでした。書き換え処理を中止します。\nMMDExporter_config.rbファイルの内容を確認してください。");
		WScript.Quit();
	}
}

f = file.OpenTextFile(config_filename, 2);
f.Write(ruby_file);
f.Close();

WScript.Echo("MMDExporter_config.rbファイルの書き換えが完了しました。");
WScript.Quit();
