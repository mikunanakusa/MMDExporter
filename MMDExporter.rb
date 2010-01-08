#-----------------------------------------------------------------------------
#
# MMD accessory(DirectX .X) File Exporter for Google SketchUp
#	  
# Based on ZbylsXExporter by Zbigniew Skowron, zbychs@gmail.com
#
#-----------------------------------------------------------------------------

configure_filename = "#{File.expand_path(File.dirname(__FILE__))}/MMDExporter_config.rb"
load configure_filename if File.exist?(configure_filename)

class File
	def File::cp(src, dst)
		open(src, 'rb'){|f_src|
			open(dst, 'wb'){|f_dst|
				f_dst.write(f_src.read)
			}
		}
	end
end

module MMDExporter
	
	module_function

	Meter_to_inch = 39.3700787
	Inch_to_meter = 1.0 / Meter_to_inch
	Specular = 0.1
	Emissive = 0.2

	def directx_header()
	"xof 0303txt 0032\n"
	end

	def directx_def_material()
		
	"Material Default_Material { 
1.0000;1.0000;1.0000;1.0;;
5.0;
#{Specular};#{Specular};#{Specular};;
#{Emissive};#{Emissive};#{Emissive};;
} 
"
	end

	def directx_material(name, color, textureFile, alpha)
		max_col = 255.0
		if textureFile && @@alpha_texturefile[textureFile] && alpha == 1.0
			alpha = 0.9999
		end
		
		col = format("%.4f;%.4f;%.4f;%8.4f;", 1.0, 1.0, 1.0, alpha)
		spe = format("%.4f;%.4f;%.4f;", Specular, Specular, Specular)
		emi = format("%.4f;%.4f;%.4f;", Emissive, Emissive, Emissive)
		
		if !textureFile
			col = format("%.4f;%.4f;%.4f;%.4f;", color.red / max_col, color.green / max_col, color.blue / max_col, alpha)
			spe = format("%.4f;%.4f;%.4f;",       color.red / max_col * Specular, color.green / max_col * Specular, color.blue / max_col * Specular)
			emi = format("%.4f;%.4f;%.4f;",       color.red / max_col * Emissive, color.green / max_col * Emissive, color.blue / max_col * Emissive)
		end
		power = format("%.4f", 5)
		tex = ""
		textureFile = @@rename_list[textureFile] if textureFile && ($smartInfo["renameTextureFile"] || $smartInfo["renameJpegFile"]) && @@rename_list[textureFile]
		tex = "   TextureFilename { \"#{textureFile}\"; }\n" if textureFile
		
	"Material #{name} {
#{col};
#{power};
#{spe};	
#{emi};	
#{tex}}
"
	end

	def out_tab(f, points, del = ",", extra = "")		
		ff = open(points[2])
		cnt = points[0]
		return if cnt < 1
		f.puts("#{cnt};")
		f.print ff.read[0..-3]
		f.puts ";"
		ff.close
		return

		for i in 0..(cnt - 2)
			p = ff.gets.chomp
			f.puts("#{p}#{del}")
		end
		p = ff.gets.chomp
		f.puts("#{p}#{extra};")
		ff.close
	end

	def out_point(p)
		return "nil" if (!p)
		px = p.x * Inch_to_meter * $smartInfo["export_size"]
		py = p.z * Inch_to_meter * $smartInfo["export_size"]
		pz = p.y * Inch_to_meter * $smartInfo["export_size"]
		format("%.4f;%.4f;%.4f;", px, py, pz)
	end

	def out_normal(p)
		return "nil" if (!p)
		px = p.x
		py = p.z
		pz = p.y
		format("%.4f;%.4f;%.4f;", px, py, pz)
	end

	def out_uv(u, v)
		format("%.4f,%.4f;", u, v)
	end

	def out_face(f, face)
		cnt = face.size
		f.printf("#{cnt};")
		for i in 0..(cnt - 2)
			p = face[i][0]
			f.printf("#{p[0]},")
		end
		p = face[cnt - 1][0]
		f.printf("#{p[0]}")
	end

	def out_faces(f, faces)
		ff = open(@@face_points[2])
		cnt = faces.size
		return if cnt < 1
		f.puts("#{cnt};")
		f.print ff.read[0..-3]
		f.puts ";;"
		ff.close
		return
		
		for i in 0..(cnt - 2)
			fc = faces[i]
			out_face(f, fc[0]);
			f.puts(",")
		end
		fc = faces[cnt - 1]
		out_face(f, fc[0]);
		f.puts(";;")
	end
	
	
	def out_face_ns(f, face)
		cnt = face.size
		f.printf("#{cnt};")
		for i in 0..(cnt - 2)
			p = face[i][0]
			f.printf("#{p[2]},")
		end
		p = face[cnt - 1][0]
		f.printf("#{p[2]}")
	end
	
	def out_normals(f, faces)
		ff = open(@@face_normals[2])
		cnt = faces.size
		return if cnt < 1
		f.puts("#{cnt};")
		f.print ff.read[0..-2]
		f.puts ";"
		ff.close
		return

		cnt = faces.size
		return if cnt < 1
		f.puts("#{cnt};")
		for i in 0..(cnt - 2)
			fc = faces[i]
			out_face_ns(f, fc[0]);
			f.puts(";")
		end
		fc = faces[cnt - 1]
		out_face_ns(f, fc[0]);
		f.puts(";;")
	end

	def out_face_materials(f, faces, materials)
		#mats = materials.keys #is this ok?
		mats = []
		for n, in materials
			mats.push(n)
		end
		f.puts("#{mats.size};")
		cnt = faces.size
		return if cnt < 1
		f.puts("#{cnt};")
		for i in 0..(cnt - 2)
			fc = faces[i]
			m = fc[1]
			midx = mats.index(m)
			f.puts("#{midx},")
		end
		
		fc = faces[cnt - 1]
		m = fc[1]
		midx = mats.index(m)
		f.puts("#{midx};")
		
		mats.each {|mmm|
			f.puts("{ #{mmm} }")
		}
	end
	
	def out_materials(f, materials)
		for n, mat in materials
			if n == "Default_Material"
				f.puts(directx_def_material())
			else
				f.puts(directx_material(mat[0], mat[1], mat[2], mat[3]));
			end
		end
	end
	
	def processFileName(fname)
		slash = "\\"
		dir = "c:\\temp"
		sidx = fname.rindex(slash)
		if (!sidx)
			slash = "/"
			dir = "/tmp"
			sidx = fname.rindex(slash)
		end
		name = "Untitled.x"
		if (sidx)
			dir = fname[0..(sidx-1)]
			name = fname[(sidx+1)..-1]
			didx = name.rindex('.')
			name += ".x" if !didx
			name[didx..-1] = ".x" if didx
		end
		
		return [name, dir, slash]
	end
	
	def config_pram_check
		begin
			raise if !Range.new(1, 16).include?(@@max_proc)
			@@max_proc = @@max_proc.to_i
		rescue
			@@max_proc = 1
		end
		begin
			raise if !((@@rename_tga == true) || (@@rename_tga == false))
		rescue
			@@rename_tga = false
		end
		begin
			raise if !((@@rename_tex == true) || (@@rename_tex == false))
		rescue
			@@rename_tex = false
		end
		begin
			raise if !((@@rename_jpg == true) || (@@rename_jpg == false))
		rescue
			@@rename_jpg = false
		end
	
		begin
			raise if @@imageMagickDir.class != String
		rescue
			@@imageMagickDir = ''
		end
		begin
			raise if @@export_point_size < 1
			@@export_point_size = @@export_point_size.to_i
		rescue
			@@export_point_size = 65535
		end
	end

	def exportXFileUI
		# Create the WebDialog instance
		
		config_pram_check

		fname = Sketchup.active_model.path
		name, dir, slash = processFileName(fname)
		
		my_dialog = UI::WebDialog.new("MMD accessory (.X File) Exporter", true, "MMD .X File Exporter", 	600, 600, 200, 200, true)
		
		# Attach an action callback
		my_dialog.add_action_callback("browse") { |web_dialog, params|
			#puts params
			a = params.split(',');
			outDir = a[0]
			outFile = a[1]
			outDir += slash if outDir[-1] != slash[0]
			#puts(outDir, outFile)
			fname = UI.savepanel("Export to...", outDir, outFile)
			fname = UI.savepanel("Export to...") if !fname
			if fname
				name, dir, slash = processFileName(fname)
				dir = dir.gsub(/['"\\]/) { '\\'+$& }
				my_dialog.execute_script(
				"document.getElementById('outDir').value = '#{dir}'");
				my_dialog.execute_script(
				"document.getElementById('outFile').value = '#{name}'");
			end
		}
		
		my_dialog.add_action_callback("ruby") { |web_dialog, params|
			#puts params
			# display ruby panel for messages
			Sketchup.send_action "showRubyPanel:"
		}
		
		# Attach an action callback
		my_dialog.add_action_callback("export") { |web_dialog, params|
#			puts params
			option = {}
			for param in params.split(',')
				k,v = param.split('=')
				if v == "true" || v == "false"
					option[k] = v == "true"
				else
					option[k] = v
				end
			end
			option['outName'] = option['outDir'] + slash + option['outFile']
			
			my_dialog.execute_script(
			"document.getElementById('console').innerHTML = ''");
			my_dialog.execute_script(
			"document.getElementById('progress').innerHTML = 'Exporting...'");
			
			res = exportXFile(option, 
			lambda {|forward, text|
				if forward
					puts text
					text = text.gsub(/['"\\]/) { '\\'+$& }
					text = text.gsub(/[\n]/) { '<br>' }
					text += '<br>'
					my_dialog.execute_script(
  					"document.getElementById('console').innerHTML += '\\n#{text}'");
				else
					print text
					#my_dialog.execute_script(
					#	"document.getElementById('progress').innerHTML += '#{text}'");
				end
			})
			my_dialog.execute_script(
			"document.getElementById('progress').innerHTML = '#{res ? 'Exported' : 'Not exported!'}'");
		}
		
		html="
<html>
<head>
	<title>MMD accessory Exporter</title>
	<script>
	function callRuby(actionName, params) {
		query = 'skp:'+ actionName + '@' + params;
		window.location.href = query;
	}
	function rubyFunc() {
		callRuby('ruby', '')
	}
	function browseFunc() {
		outputDir = document.getElementById('outDir').value
		outputFile = document.getElementById('outFile').value
		callRuby('browse', outputDir + ',' + outputFile)
	}
	function exportFunc() {
		option = ''
		option += 'outDir=' + document.getElementById('outDir').value
		option += ',outFile=' + document.getElementById('outFile').value
		option += ',exportSize=' + document.getElementById('exportSize').value
		option += ',exportSelected=' + document.getElementById('exportSelected').checked
		option += ',exportFace=' + document.getElementById('exportFace').value
		option += ',renameTEX=' + document.getElementById('renameTEX').checked
		option += ',renameJPG=' + document.getElementById('renameJPG').checked
		option += ',autoSplit=' + document.getElementById('autoSplit').checked
		callRuby('export', option)
	}
	</script>
</head>
<body>
	<input type='button' onclick='exportFunc()' value='Export .X File'> 
	<input type='button' onclick='rubyFunc()' value='Show Console'><br>
	<div>
	<div id='progress' style='color: red'>
	</div>
	Output directory:<br>
	<input id='outDir' type='text' value='#{dir}' size='60'><br>
	Output file: 
	<input type='button' onclick='browseFunc()' value='Browse'><br>
	<input id='outFile' type='text' value='#{name}' size='60'><br>
	Export Size:
	<input id='exportSize' type='text' value='1' size='10'><br>
	<input id='exportSelected' type='checkbox' value='Export Selected'> Export selected object<br>
	Export face 
	<select id='exportFace'>
	<option value='1'>Export front/back face
	<option value='2'>Export front face
	<option value='3'>Export back face
	</select><br>                
	<input id='renameTEX' type='checkbox' value='Rename TEX file'> Rename and Convert Texture file (exclude jpeg format) <br>
	<input id='renameJPG' type='checkbox' value='Rename JPG file'> Rename and Convert Texture file (jpeg format)<br>
	<input id='autoSplit' type='checkbox' value='auto split file' checked> Auto Split<br>
	<hr>
	<div id='console' style='color: grey; font-family: monospace; font-size: smaller'>
	</div>
	</div>
</body>
</html>
"

		#print html
		html.gsub!(/value='Rename TEX file'/, "value='Rename TEX file' checked") if @@rename_tga || @@rename_tex
		html.gsub!(/value='Rename JPG file'/, "value='Rename JPG file' checked") if @@rename_jpg
		my_dialog.set_html(html)
		
		my_dialog.show {
			#my_dialog.execute_script(
			#	"document.getElementById('ala').innerHTML = '<b>Hi There!</b>'");
		}
	end
	
	#-----------------------------------------------------------------------------

	def export_facedata(face, mat_fb, tex_fb, texFile_fb, texFace, trans, tw,	materials, points, uvs, normals, faces, print_callback)
		[true, false].each do |front|
			next if front == false && $smartInfo["exportFaceSide"] == "2"
			next if front == true && $smartInfo["exportFaceSide"] == "3"
			mat = mat_fb[front][0]
			tex = tex_fb[front][0]
			texFile = texFile_fb[front]

			mname = "Default_Material"
			if mat
				mname = "_" + mat.name
				mname = mname + "-" + texFile if texFile
				mname = mname.gsub(/[^a-zA-Z0-9]/, "_")
				alpha = 1.0000
				alpha = mat.alpha if mat.use_alpha?
				materials[mname] = [mname, mat.color, texFile, alpha]
				#puts(materials[mname])
			else
				materials[mname] = [mname, nil, nil, 1.0000]
			end
			
			if tex
				uvHelp = face.get_UVHelper(true, true, tw)					
			end
			
			mesh = face.mesh 7

			point_list = {}
			normal_list = {}
			for i in (1..mesh.count_points)
				pos = mesh.point_at(i)
				uq = 0.0
				vq = 0.0
				if tex
					if front
						uvq = uvHelp.get_front_UVQ(pos).to_a
					else
						uvq = uvHelp.get_back_UVQ(pos).to_a
					end
					if texFace > 0
						if texFace == 2
							uvq = uvHelp.get_front_UVQ(pos).to_a
						else
							uvq = uvHelp.get_back_UVQ(pos).to_a
						end							
					end

					if tex_fb[front][1][2]
						uq = uvq.x / tex.width
						vq = -uvq.y / tex.height
					else
						uq = uvq.x
						vq = -uvq.y
					end
				end
				uv = out_uv(uq, vq)
				pt = out_point(trans * pos)
				ptuv = pt + uv

				unless @@points_index[ptuv]
					@@points_index[ptuv] = @@points_index.length
					points[0] += 1
					points[1].puts pt + ","
					uvs[0] += 1
					uvs[1].puts uv
				end
#				point_list[i] = points.length-1
				point_list[i] = @@points_index[ptuv]

				n = mesh.normal_at(i)
				n = Geom::Vector3d.new(-n[0],-n[1],-n[2]) if !front
				n = out_normal((trans * n).normalize)
				unless @@normals_index[n]
					@@normals_index[n] = @@normals_index.length
					normals[0] += 1
					normals[1].puts n + ","
				end
#				normal_list[i] = normals.length-1
				normal_list[i] = @@normals_index[n]
			end

			for poly in mesh.polygons
				v1 = trans * mesh.point_at(poly[1].abs) - trans * mesh.point_at(poly[0].abs)
				v2 = trans * mesh.point_at(poly[2].abs) - trans * mesh.point_at(poly[1].abs)
				no = mesh.normal_at(poly[0].abs) + mesh.normal_at(poly[1].abs) + mesh.normal_at(poly[2].abs)
				no = trans * no
				ang = no.angle_between v2*v1

				if (front && ang > 1.57) || (!front && ang < 1.57)
 					poly = poly.reverse
 				end

				theFace = []
				pl = []
				nl = []
				for p in poly
					pidx = point_list[p.abs]
					nidx = normal_list[p.abs]
#					theFace.push([[pidx, pidx, nidx], front])
					pl << pidx
					nl << nidx
				end

				@@face_points[1].puts "#{pl.length};#{pl * ","},"
				@@face_normals[1].puts "#{nl.length};#{nl * ","};"
				
				faces.push([theFace, mname])
			end
		end
	end

	def exportXFileEngine(entities, trans, tw,	materials, points, uvs, normals, faces, parent_material, print_callback)
		entities.each do |ent|
			next if ent.hidden? or not ent.layer.visible?
			
			case ent.typename
			when "ComponentInstance"
				if ent.material && ent.material.texture
					tw.load(ent, true)
				end
				exportXFileEngine(ent.definition.entities, trans*ent.transformation, tw, materials, points, uvs, normals, faces, ent.material ? ent : parent_material, print_callback)
			when "Group"
				if ent.material && ent.material.texture
					tw.load(ent, true)
				end
				exportXFileEngine(ent.entities, trans*ent.transformation, tw, materials, points, uvs, normals, faces, ent.material ? ent : parent_material , print_callback)
			end
		end

		ss = entities
		ss = ss.select do |ent| 
		 (ent.kind_of? Sketchup::Face) && !ent.hidden? && ent.layer.visible?
		end
		
		if ss.empty?
			#		print_callback.call(true, "Nothing to export.")
			return false
		end
		
		if $smartInfo["textureWritePass"]
			for face in ss
				if face.material && face.material.texture
					tw.load(face, true)
				end
				if face.back_material && face.back_material.texture
					tw.load(face, false)
				end
			end

			return true
		end

		if $smartInfo["faceCollectPass"]
			for face in ss
				mat = {true => [face.material , [face, true, false]], false => [face.back_material , [face, false, false]]}
				#parent material check
				if parent_material && parent_material.material
					mat[true] = [parent_material.material , [parent_material, true, true]] if !face.material
					mat[false] = [parent_material.material , [parent_material, true, true]] if !face.back_material
				end

				# alpha material check
				alpha_flag = (face.material && face.material.use_alpha? ) || (face.back_material && face.back_material.use_alpha?)
				mat[false] = [face.material , [face, true, false]] if face.material && face.material.use_alpha?
				mat[true] = [face.back_material , [face, true, false]] if face.back_material && face.back_material.use_alpha?
			
				# alpha texture file check
				tex = {true => [mat[true][0] && mat[true][0].texture, mat[true][1], mat[true][2]] ,
							false => [mat[false][0] && mat[false][0].texture, mat[false][1], mat[false][2]] }
				texFile = {}
				tex_alpha_flag = false
				texFace = 0
				for front in [true , false]
					next unless tex[front][0]
					handle = tw.handle(tex[front][1][0], tex[front][1][1])
					texFile[front] = tw.filename(handle).to_s
					texFile[front] = File.basename(tex[front][0].filename) if texFile[front] == ""

					if @@alpha_texturefile[texFile[front]]
						tex_alpha_flag = true 
						mat[front ? false : true] = mat[front]
						tex[front ? false : true] = tex[front]
						texFile[front ? false : true] = texFile[front]
						texFace = front ? 1 : 2
					end	
				end
				
				sort_param = 0
				sort_param = 1 if tex_alpha_flag 
				sort_param = 2 if alpha_flag 
				export_face = $smartInfo["exportFaceSide"] == "1" ? 2 : 1

				mesh = face.mesh 7
				@@data_counter[:face] += 1
				@@data_counter[:texalphaface] += 1 if tex_alpha_flag
				@@data_counter[:alphaface] += 1 if alpha_flag
				@@face_collect[sort_param] << [face, mat, tex, texFile, texFace, trans, export_face]
				@@data_counter[:point] += mesh.count_points * export_face
				@@data_counter[:polygon] += mesh.count_polygons * export_face
			end
			
			return true
		end

	end
		
	#-----------------------------------------------------------------------------
	
	def search_imagemagick_path()
	#-------------------------------------------------------------------------------
	#  ImageMagick "convert.exe" , "identify" serch
	#-------------------------------------------------------------------------------
		@@imageMagickDir.concat '/' if @@imageMagickDir[/.*(\/|\\)$/, 1].nil?
		cmds_all = Hash.new

		for cm in ["convert.exe" , "identify.exe"]
			cmds = Array.new
			cmds.concat ["#{@@imageMagickDir}convert.exe"] if cm == "convert.exe"
			cmds.concat ["#{@@imageMagickDir}identify.exe"] if cm == "identify.exe"
			cmds.concat ["#{File.expand_path(File.dirname(__FILE__))}/#{cm}"]		# plugin Dir
			cmds.concat [cm]		# system PATH
		
			cmd = cmds.each{|cmd|
				if File.exist?(cmd)
					break cmd if !`"#{cmd}" -version 2>&1`["ImageMagick"].nil?
				end
			}
		
			if cmd.class == String
				cmds_all[cm] = cmd		# command found!
			else
				cmds_all[cm] = nil		# command not found!
			end
		end
		
		return cmds_all
	end

	def createXFile(part , fname , materials, faces, uvs, points, normals , finish, print_callback)		
		print_callback.call(true, "Export: #{part} Start")				
		dir = File.dirname(fname)
		ext = File.extname(fname)			
		name = File.basename(fname , ext)
		if finish && part == 1
			fname_part = fname
		else
			fname_part = dir + "/" + name + "_#{part}" + ext
		end
		print_callback.call(true, "Export to: " + File.basename(fname_part))

		f = File.new(fname_part, "w")
		f.puts(directx_header())
		out_materials(f, materials)
		f.puts "Mesh mesh_0{"
		out_tab(f, points)
		out_faces(f, faces)
		f.puts "  MeshMaterialList {"
		out_face_materials(f, faces, materials)
		f.puts "  }"
		f.puts "  MeshTextureCoords {"
		out_tab(f, uvs, "", "")
		f.puts "  }"
		f.puts "  MeshNormals {"
		out_tab(f, normals)
		out_normals(f, faces)
		f.puts "  }"
		f.puts "}"
	
		f.close	

		print_callback.call(true, "Export Point: #{points[0]}")
		print_callback.call(true, "Export: #{part} Done.")

	end

	def exportXFile(option, print_callback)
		fname = option['outName']
		outDir = option['outDir']
		export_size = option['exportSize']
		selectedOnly = option['exportSelected']
		export_face = option['exportFace']
		renameTextureFile = option['renameTEX']
		renameJpegFile = option['renameJPG']
		auto_split = option['autoSplit']
		if !fname || !outDir
			print_callback.call(true, "Empty file or directory name.")
			return false
		end

#		p (fname, outDir, export_size, selectedOnly, export_face, renameTextureFile, auto_split)
		model = Sketchup.active_model
		ss = model.active_entities
		ss = model.selection if selectedOnly
		
		$smartInfo = {}
		$smartInfo["selectedOnly"] = selectedOnly
		$smartInfo["exportFaceSide"] = export_face
		$smartInfo["renameTextureFile"] = renameTextureFile
		$smartInfo["renameJpegFile"] = renameJpegFile
		$smartInfo["autoSplit"] = auto_split
		if export_size.to_f > 0
			$smartInfo["export_size"] = export_size.to_f
		else
			$smartInfo["export_size"] = 1.0
		end

		print_callback.call(true, "Exporting textures to: " + outDir)
		tw = Sketchup.create_texture_writer

		$smartInfo["textureWritePass"] = true	
		exportXFileEngine(ss, Geom::Transformation.new, tw,
											nil, nil, nil, nil, nil,
											nil, print_callback)
		
		result = tw.write_all(outDir, false)
		print_callback.call(true, "Writing textures failed!") if !result
		
		@@alpha_texturefile = {}
		#-------------------------------------------------------------------------------
		#  Converting textures to TGA for multi process version
		#-------------------------------------------------------------------------------
		if !tw.count.zero? && (renameTextureFile || renameJpegFile)
			print_callback.call(true, "ImageMagick \"convert.exe\" and \"identify.exe\" serching...")
			im_command = search_imagemagick_path()
			im_convert = im_command["convert.exe"]
			im_identify = im_command["identify.exe"]
			if !im_convert.nil? && !im_identify.nil?
				@@rename_list = {}
				Dir.chdir(outDir)
				convert_filelist = Array.new
				Range.new(1, tw.count).each{|handle|
					fn = tw.filename(handle)
					if File.extname(fn).downcase =~ /jpg|jpeg/
						next if !renameJpegFile
					else
						next if !renameTextureFile
					end
					hash = Hash.new
					hash[:SRC] = File.basename(fn)
					hash[:DST] = "#{File.basename(fn, '.*')}.bmp"
					hash[:REN_SRC] = "#{[File.basename(fn, '.*')].pack('m')}#{File.extname(fn)}"
					hash[:REN_SRC].gsub!('/', '!')
					hash[:REN_SRC].gsub!(/\n/, '@')
					hash[:REN_DST] = "#{File.basename(hash[:REN_SRC], '.*')}.bmp"
					convert_filelist.concat [hash]
				}

				convert_filelist.each{|convert_file|
					Thread.new(convert_file){|convert_file|
					  convert_flag = "BMP3:"
						if im_identify && `"#{im_identify}" -verbose "#{convert_file[:SRC]}"` =~ /Alpha:.+\(\d+,\d+,\d+,\d+\)/
							@@alpha_texturefile[convert_file[:SRC]] = true
							convert_file[:DST].gsub!(/bmp$/ , "tga")
							convert_file[:REN_DST].gsub!(/bmp$/ , "tga")
						  convert_flag = ""
						end
						print_callback.call(true, "convert start #{convert_file[:SRC]} to #{convert_file[:DST]}")
						File.cp(convert_file[:SRC], convert_file[:REN_SRC])						
						`"#{im_convert}" "#{convert_file[:REN_SRC]}"  #{convert_flag}"#{convert_file[:REN_DST]}"`
						begin
							File.delete(convert_file[:REN_SRC])
						rescue
							sleep(0.1)
							retry
						end				
						if File.exist?(convert_file[:REN_DST])
							print_callback.call(true, "convert success #{convert_file[:SRC]} to #{convert_file[:DST]}")
							File.rename(convert_file[:REN_DST], convert_file[:DST])
							File.delete(convert_file[:SRC])
							@@rename_list[convert_file[:SRC]] = convert_file[:DST]
						else
							print_callback.call(true, "convert fault #{convert_file[:SRC]} to #{convert_file[:DST]}")
						end
					}
					sleep(0.1) while ThreadGroup::Default.list.size > @@max_proc
				}
				sleep(0.1) while ThreadGroup::Default.list.size > 1
			else
				print_callback.call(true, "ImageMagick \"convert.exe\" or \"identify.exe\" not found!")
			end
		end

		$smartInfo["textureWritePass"] = false
		$smartInfo["faceCollectPass"] = true
		@@data_counter = {:face => 0 , :point => 0 , :polygon => 0, :texalphaface => 0, :alphaface => 0}
		@@face_collect = {0 => [] , 1 => [] , 2 => []}

		exportXFileEngine(ss, Geom::Transformation.new, tw,
											nil, nil, nil, nil, nil,
											nil, print_callback)
											
		point_num = 0
		part = 1
		materials = {}			
		faces = []			
		uvs = [0,open(outDir + "/uvs.tmp" , "w") , outDir + "/uvs.tmp"]
		points = [0,open(outDir + "/points.tmp" , "w") , outDir + "/points.tmp"]
		@@points_index = {}
		normals = [0,open(outDir + "/normals.tmp" , "w") , outDir + "/normals.tmp"]
		@@normals_index = {}
		@@face_points = [0,open(outDir + "/face_points.tmp" , "w") , outDir + "/face_points.tmp"]
		@@face_normals = [0,open(outDir + "/face_normals.tmp" , "w") , outDir + "/face_normals.tmp"]

		print_callback.call(true, "Analyzing geometry")
		all_points = 0

		for sort_param in [0,1,2]
			for face , mat , tex , texFile , texFace, trans, export_face in @@face_collect[sort_param]
				mesh = face.mesh 7
				p_n = mesh.count_points * export_face
				
				if point_num + p_n > @@export_point_size && $smartInfo["autoSplit"]

					# export to file 
					all_points += points[0]
					uvs[1].close
					points[1].close
					normals[1].close
					@@face_points[1].close
					@@face_normals[1].close
					createXFile(part , fname , materials, faces, uvs, points, normals , false, print_callback)
					part += 1
					point_num = 0
					materials = {}			
					faces = []
					uvs = [0,open(outDir + "/uvs.tmp" , "w") , outDir + "/uvs.tmp"]
					points = [0,open(outDir + "/points.tmp" , "w") , outDir + "/points.tmp"]
					@@points_index = {}
					normals = [0,open(outDir + "/normals.tmp" , "w") , outDir + "/normals.tmp"]
					@@normals_index = {}
					@@face_points = [0,open(outDir + "/face_points.tmp" , "w") , outDir + "/face_points.tmp"]
					@@face_normals = [0,open(outDir + "/face_normals.tmp" , "w") , outDir + "/face_normals.tmp"]
#					exit
				end

				export_facedata(face, mat, tex, texFile, texFace, trans, tw,	materials, points, uvs, normals, faces, print_callback)
				point_num = points[0]
			
			end

			if faces.length > 0 && $smartInfo["autoSplit"]
				all_points += points[0]
				uvs[1].close
				points[1].close
				normals[1].close
				@@face_points[1].close
				@@face_normals[1].close
				createXFile(part , fname , materials, faces, uvs, points, normals , false, print_callback)
				part += 1
				point_num = 0
				materials = {}			
				faces = []
				uvs = [0,open(outDir + "/uvs.tmp" , "w") , outDir + "/uvs.tmp"]
				points = [0,open(outDir + "/points.tmp" , "w") , outDir + "/points.tmp"]
				@@points_index = {}
				normals = [0,open(outDir + "/normals.tmp" , "w") , outDir + "/normals.tmp"]
				@@normals_index = {}
				@@face_points = [0,open(outDir + "/face_points.tmp" , "w") , outDir + "/face_points.tmp"]
				@@face_normals = [0,open(outDir + "/face_normals.tmp" , "w") , outDir + "/face_normals.tmp"]
			end		
		end

		if faces.length > 0
			all_points += points[0]
			uvs[1].close
			points[1].close
			normals[1].close
			@@face_points[1].close
			@@face_normals[1].close
			createXFile(part , fname , materials, faces, uvs, points, normals , true, print_callback)
		end
		
		print_callback.call(true, "Export Face: #{@@data_counter[:face]}")
		print_callback.call(true, "Export Polygon: #{@@data_counter[:polygon]}")
		print_callback.call(true, "Export Point: #{all_points}")
		
		print_callback.call(true, "Export finish.")
		
		begin
			uvs[1].close unless uvs[1].closed?
			points[1].close unless points[1].closed?
			normals[1].close unless normals[1].closed?
			@@face_points[1].close unless @@face_points[1].closed? 
			@@face_normals[1].close unless @@face_normals[1].closed?
			File.delete(outDir + "/uvs.tmp")
			File.delete(outDir + "/points.tmp")
			File.delete(outDir + "/normals.tmp")		
			File.delete(outDir + "/face_points.tmp")		
			File.delete(outDir + "/face_normals.tmp")		
		rescue
		end
	
		return true
	end
	
	#-----------------------------------------------------------------------------
	
end


if( not file_loaded?("MMDExporter.rb") )
	#add_separator_to_menu("Plugins")
	plugins_menu = UI.menu("Plugins")
	plugins_menu.add_item("MMD accessory (.X file) Exporter...") { MMDExporter.exportXFileUI }
end

file_loaded("MMDExporter.rb")

#-----------------------------------------------------------------------------

