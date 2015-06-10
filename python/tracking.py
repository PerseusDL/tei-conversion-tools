import json
from pprint import pprint
import os

def urn2filepath(urn):
	parts = urn.split(":")
	filepath = "canonical-"+ parts[2] + "/data/"+ parts[3].split(".")[0] + "/" + parts[3].split(".")[1] + "/" + parts[3] +".xml"
	return filepath

def list_files(dirList):
	files = []
	for repo in dirList:
		for root, dirnames, filenames in os.walk(repo):
			for filename in filenames:
				files.append(os.path.join(root,filename))
	return files

# def check_unicode(f):

def check_refsDecl(urn):
	fpath = urn2filepath(urn)
	with open(fpath, "r") as f:
		text = f.read()
		if "<cRefPattern" in text:
			return True
		else:
			return False

#def check_epidoc(f):

#def check_breathmarks(f):
	#Is there a way to actually do this? need to ask Frederik and Giuseppe

#doesn't check the validity of metadata file
def check_cts_metadata(urn):
	parts = urn.split(":")
	path = "canonical-"+ parts[2] + "/data/"+ parts[3].split(".")[0] + "/" + parts[3].split(".")[1] 
	fList = list_files([path])
	if path + "/__cts__.xml" in fList:
		with open(path + "/__cts__.xml", "r") as f:
			text = f.read()
			if parts[2] + ":" + parts[3].split(".")[2] in text:
				return True
			else:
				return False
	else:
		return False

#need to add tests for unicode etc

def edit_json(
    data,
    key,
    filepath,
    files,
    editor,
    ):
    if filepath in files:
        data[key]['target'] = filepath
        data[key]['status'] = 'migrated'
        data[key]['git_repo'] = filepath.split(':')[0]
        data[key]['last_editor'] = editor
        data[key]['has_cts_metadata'] = \
            check_cts_metadata(str(data[key]['urn']))
        data[key]['has_cts_refsDecl'] = \
            check_refsDecl(str(data[key]['urn']))
    else:
        data[key]['status'] = 'not-migrated'
        data[key]['git_repo'] = ''
        data[key]['has_cts_metadata'] = False
        data[key]['has_cts_refsDecl'] = False		

def update_tracking_json(editor, repoList, trackingFile):
	files = list_files(repoList)
	with open(trackingFile, "r+") as data_file:    
    	data = json.load(data_file)
    	for key, value in data.items():
    		if len(data[key]["sub"]) == 0:
    			if len(data[key]["urn"]) > 0:
    				filepath = urn2filepath(str(data[key]["urn"]))
    				#CHANGE KEY TO CTS NAME BEFORE EDITING JSON --WRITE WHOLE NEW JSON FILE???
    				edit_json(data, key, filepath, editor)
    		else:
    			data[key]["status"] = "composite doc"
    			for l in data[key]["sub"]:
    				data[str(l["urn"])] = l
    				filepath = urn2filepath(str(l["urn"]))
    				edit_json(data,str(l["urn"]), filepath, files, editor)
    			


#e.g. update_tracking_json("Dee", ["canonical-greekLit","canonical-latinLit"], "tei-conversion-tools/summary_data/p4top5.json" )

			
			
			
			