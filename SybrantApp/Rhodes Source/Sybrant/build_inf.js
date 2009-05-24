var fso,output_file;

//TBD need to move sources and settings to a separate config files

var sources = new Object();
sources['db'] = ["db","bin\\RhoBundle\\db"];
//sources['sqlite3']= ["sqlite3","..\\..\\shared\\sqlite3"];
sources['lib']= ["lib","bin\\RhoBundle\\lib"];
sources['apps']= ["apps","bin\\RhoBundle\\apps"];

var settings = new Object();
settings['wm6'] = ['Windows Mobile 6 Professional SDK (ARMV4I)','VersionMin=5.02','VersionMax=6.99'];

main();

function p(str) {
	output_file.WriteLine(str);
}

function expand_source(es,name,path,section,destination) {
	var s = new Object();
	s.name = name;
	s.path = path;
	s.section = ""+section+"_"+name.replace(/ /g,"_");
	s.destination = destination+"\\"+name;
	s.folder = fso.GetFolder(path);
	es.push(s);

	var fc = new Enumerator(s.folder.SubFolders);
   	for (; !fc.atEnd(); fc.moveNext()) {
		expand_source(es,fc.item().Name,fc.item().Path,s.section,s.destination);
   	}
}

function expand_sources() {
	var es = new Array();
	for (var i in sources) {
		expand_source(es,sources[i][0],sources[i][1],"copyfiles","rho");
	}
	return es;
}

function get_copyfiles_sections(es) {
	var str = "";
	for (var i in es) {
		str = str+","+es[i].section;
	}
	return str;
}

function get_source_disks_names(es) {
	var disk = 2;

	for (var i in es) {
		es[i].disk = disk;
		p(""+disk+"=,\"\",,\""+es[i].path+"\\\"");
		disk++;
	}
}

function get_file_list(es) {
	var file_list = new Array();
	for (var i in es) {
   		var fc = new Enumerator(es[i].folder.files);
   		for (; !fc.atEnd(); fc.moveNext()) {
			var f = new Object();
			f.name = fc.item().Name;
			f.fullname = es[i].folder.Path+"\\"+f.name;
			f.section = es[i].section;
			f.disk = es[i].disk;
			file_list.push(f);
   		}
	}
	return file_list;
}

function is_dublicate(flist,file) {
	for(var i in flist) {
		if ( (flist[i].name == file.name) &&
			(flist[i].fullname != file.fullname) ) {
			return true;
		}
	}
	return false;
}

function resolve_dublicates(es) {
	var dups = new Array();
	var flist = get_file_list(es);
	var n = 1;
	for(var i in flist) {
		if ( is_dublicate(flist,flist[i]) ) {
			flist[i].localname = flist[i].name+".copy"+n;
			flist[i].copy = flist[i].fullname+".copy"+n;

			var f = fso.GetFile(flist[i].fullname);
			f.Copy(flist[i].copy);

			dups.push(flist[i]);
			n++;
		} else {
			flist[i].localname = flist[i].name;
		}
	}

	var cleanup_file = fso.CreateTextFile("cleanup.js");

	cleanup_file.WriteLine("var f;");
	cleanup_file.WriteLine("var fso = new ActiveXObject(\"Scripting.FileSystemObject\");");
	for(var i in dups) {
		var copy = dups[i].copy.replace(/\\/g,"\\\\");
		cleanup_file.WriteLine("f = fso.GetFile(\""+copy+"\");");
		cleanup_file.WriteLine("f.Delete();");
	}

	cleanup_file.Close();

	return flist;
}

function get_source_disks_files(es) {

	var f = resolve_dublicates(es);

	for (var i in f) {
		p("\""+f[i].localname+"\"="+f[i].disk);
	}

	return f;
}

function get_destination_dirs(es) {
	for (var i in es) {
		p(es[i].section+"=0,\"%InstallDir%"+"\\"+es[i].destination+"\"");
	}
}

function get_files_for_section(section,f) {
	var list = new Array();
	for (var i in f) {
		if (f[i].section == section) {
			list.push(f[i]);
		}
	}
	return list;
}

function fill_copyfiles_sections(es,f) {
	for (var i in es) {
		p("["+es[i].section+"]");
		var sf = get_files_for_section(es[i].section,f);
		for (var i in sf) {
			p("\""+sf[i].name+"\",\""+sf[i].localname+"\",,0");
   		}
   		p("");
	}
}

function pinf(platform,es) {

	p("[Version]");
	p("Signature=\"$Windows NT$\"");
	p("Provider=\"rhomobile\"");
	p("CESignature=\"$Windows CE$\"");
	p("");
	p("[CEStrings]");
	p("AppName=\"rhodes\"");
	p("InstallDir=%CE1%\\%AppName%");
	p("");
	p("[Strings]");
	p("Manufacturer=\"rhomobile\"");
	p("");
	p("[CEDevice]");
	p(settings[platform][1]);
	p(settings[platform][2]);
	p("BuildMax=0xE0000000");
	p("");
	p("[DefaultInstall]");
	p("CEShortcuts=Shortcuts");
	p("AddReg=RegKeys");
	p("CopyFiles=CopyToInstallDir"+get_copyfiles_sections(es));
	p("");
	p("[SourceDisksNames]");
	p("1=,\"\",,\"bin\\"+settings[platform][0]+"\\rhodes\\Release\\\"");
	get_source_disks_names(es);
	p("");
	p("[SourceDisksFiles]");
	p("\"rhodes.exe\"=1");
	var f = get_source_disks_files(es);
	p("");
	p("[DestinationDirs]");
	p("Shortcuts=0,%CE2%\Start Menu");
	p("CopyToInstallDir=0,\"%InstallDir%\"");
	get_destination_dirs(es);
	p("");
	p("[CopyToInstallDir]");
	p("\"rhodes.exe\",\"rhodes.exe\",,0");
	p("");
	fill_copyfiles_sections(es,f);
	p("");
	p("[Shortcuts]");
	p("Rhodes,0,\"rhodes.exe\",%CE11%");
	p("");
	p("[RegKeys]");
	p("");
}

function main() {
	var args = WScript.Arguments;
	fso = new ActiveXObject("Scripting.FileSystemObject");
	output_file = fso.CreateTextFile(args(0));

	var es = expand_sources();
	pinf(args(1),es);

	output_file.Close();
}