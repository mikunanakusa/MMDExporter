== MMD accessory(DirectX .X) File Exporter for Google SketchUp
Google SketchUp(http://sketchup.google.com)から
サイト「VPVP」(http://www.geocities.jp/higuchuu4/index.htm)で公開されている
VOCALOID 3DPV製作用ツール「MikuMikuDance」（通称MMD）のアクセサリを
出力するプラグインです。

== 概要
http://www.scriptspot.com/sketchup/script/zbylsxexporter
を元に改造しています。

2ch/Youtube板「【MMD】MikuMikuDance動画制作/鑑賞スレ【初音ミク】 partミク」スレ 793を
元に2ch/Youtube板「【MMD】MikuMikuDance動画制作/鑑賞スレ【初音ミク】 part40」スレ 409氏が
配布しているテクスチャファイルをTGAへ自動変換する機能を追加する改造版を元に修正を行いました。

== 動作環境
WindowsXP SP3 + Google SketchUp 6で動作確認を行っています。

== ImageMagickについて
画像の変換時に使用するImageMagickのコマンドを以下の順番で探索します。
１．"MMDExporter_config.rb"ファイル内の@@imageMagickDirに設定されたフォルダ
２．"MMDExporter.rb"があるフォルダ(Google SketchUpの"Plugins"フォルダ)
３．システムのパスが通っているフォルダ
見つからなかった場合は画像の変換は行いません。

== インストール
=== プラグインのダウンロード
http://github.com/mikunanakusa/MMDExporter のページからdownload -> ZIP をクリックして
ファイルをダウンロードします。

もし、うまくいかなかった場合は http://github.com/mikunanakusa/MMDExporter/zipball/master
から落としてください。

=== Google SketchUp のセットアップ
Google SketchUp ですが、http://sketchup.google.com のページからインストールを行います。
このプラグインは Google SketchUp 6 (無料版)  で使用可能です。

=== ImageMagick のセットアップ
ImageMagickのインストールはim_setup.htmlを参考にしてインストールしてください。

=== プラグインのインストール
使い方は落としたファイルを解凍して.rbファイルをSketchUPのpluginsフォルダに放り込めば
メニューから使えるようになります。詳細は install.html を参考にしてください。

=== プラグインの設定
ImageMagickをインストールしたパスの設定は最低限行う必要があります。config_edit.htmlを
参考に設定してください。

== ファイル
* img <dir>              手順書で使用している画像ファイルが入っているフォルダ
* MMDExporter.rb         exporter本体 / Rubyスクリプト
* MMDExporter_config.rb  exporterの設定ファイル / Rubyスクリプト
* README.txt             このファイル
* install.html           インストール簡易手順書のトップ
* im_setup.html          ImageMagickのセットアップ簡易手順書
* config_edit.html       設定ファイルの編集簡易手順書
* config_edit@im.js      設定ファイルの簡易設定スクリプト

== 使い方
メニューのPluginsのMMD Exporterから起動できます。
* Export .X File:
 ファイルを出力します。
* Output directory:
 ファイルの出力ディレクトリを設定します。
* Output file:
 出力ファイル名を入れます。分割時は_1、_2をファイル名に追加して出力します。
* Export Size: 
 出力サイズを入れます。3を入れるとモデルのサイズが3倍になります。
 取ってきたファイルの大きさがあわないときはここで調整します。
* Export selected only:
 選択した部分のみ出力します
* Rename Texture filename: 
 テクスチャファイルのjpg、pngの拡張子をbmp、tgaに変更して出力します。
* Auto Split:
 自動分割を行います

== 免責事項
* 本プラグインの利用は自己責任でお願いします。
* 本プラグインを使用したことによる一切の損害（一次的、二次的に関わらず）に対し、作成者は
責任を負いません。

== 開発履歴
* 2009-10-08 @ 407
 MMDExporter_config.rb内変数の見直し
 MMDExporter_config.rb内変数のチェック強化
 コマンドの探索時にファイルが見つかったときだけ実行して確認するように変更
 簡易セットアップのスクリプトを追加
 HTMLの手順書を改定

* 2009-10-06
 2ch/Youtube板「【MMD】MikuMikuDance動画制作/鑑賞スレ【初音ミク】 part40」スレ 409氏の
ドキュメントを同封しました

* 2009-10-04
 ImageMagick のconvertコマンドがtgaファイルの生成に失敗しているのでデフォルトの
テクスチャファイルのフォーマットをbmpに変更。透過設定をしているもののみtgaで出力
 透過設定しているテクスチャがの修正
 アクセサリ分割を分割数の手動設定から自動分割に変更
 テクスチャのUVマッピングの修正

* 2009-10-01
* 2009-09-25
 2ch/Youtube板「【MMD】MikuMikuDance動画制作/鑑賞スレ【初音ミク】 part40」スレ 409氏に
よる機能追加
 http://bytatsu.net/uploader/mikumikudance/src/up0320.zip

* 2009-09-23
 テクスチャ、ポリゴンの裏表がおかしくなっている部分の修正
 .Xファイルの分割出力
 透過設定をしている or していないポリゴンの出力
 jpg、png拡張子をtga拡張子に変更して出力（ファイルの形式は変更していないのでIrfanViewなどで
変換してください）
 出力アクセサリのサイズ変更機能
