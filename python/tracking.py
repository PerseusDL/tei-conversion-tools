#python 3.3.5

import json
from pprint import pprint
from lxml import etree as ET
import lxml.html as LH
import urllib
from bs4 import BeautifulSoup
import os
import subprocess
from subprocess import call
from subprocess import Popen, PIPE
import shlex
import codecs

# urns in form urn:cts:greekLit:tlg0028.tlg004.perseus-eng1

def urn2filepath(urn):
	parts = urn.split(":")
	try:
		filepath = "canonical-"+ parts[2] + "/data/"+ parts[3].split(".")[0] + "/" + parts[3].split(".")[1] + "/" + parts[3] +".xml"
		return filepath
	except IndexError:
		pass

def filepath2urn(fpath):
	parts = fpath.split("/")
	try:
		urn = "urn:cts:" + parts[0].split("-")[1] + ":" + parts[4].split(".xml")[0]
		return urn
	except IndexError:
		pass

def check_filepath_urnability(fpath):
	try:
		urn2filepath(filepath2urn(fpath))
		return True
	except AttributeError:
		return False

def check_urn_filepathability(urn):
	try:
		filepath2urn(urn2filepath(urn))
		return True
	except AttributeError:
		return False

def list_files(dirList):
	files = []
	for repo in dirList:
		for root, dirnames, filenames in os.walk(repo):
			for filename in filenames:
				files.append(os.path.join(root,filename))
	return files

#test this
def list_tracking_files(dirList):
	files = []
	tracking_files = []
	for repo in dirList:
		for root, dirnames, filenames in os.walk(repo):
			for filename in filenames:
				files.append(os.path.join(root,filename))
	for f in files:
		if "tracking" in f:
			tracking_files.append(f)
	return tracking_files

# def check_unicode(f):

def check_refsDecl(urn):
	fpath = urn2filepath(urn)
	with open(fpath, "r") as f:
		text = f.read()
		if "<cRefPattern" in text:
			return True
		else:
			return False

#Thanks to Tom Elliot for this function: http://horothesia.blogspot.com/2014/04/batch-xml-validation-at-command-line.html

#requires Jing RelaxNG Validator and GNU Parallel installed to run

#run this before using: call("curl -O http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng", shell=True)

def check_epidoc(urn):
	fpath = urn2filepath(urn)
	if os.path.exists(fpath):
		command = "find " + fpath + " -print | parallel --tag --will-cite jing tei-epidoc.rng"
		args = shlex.split(command)
		p = subprocess.Popen(command, stdin=PIPE, stdout=PIPE, shell=True)
		try:
			outs, errs = p.communicate(timeout=15)
		except subprocess.TimeoutExpired:
			p.kill()
			outs, errs = p.communicate()
		if str(outs) == "b''":
			return True
		else:
			return False
	else:
		return "File does not exist"

def check_unicode(urn):
	fpath = urn2filepath(urn)
	try:
		f = codecs.open(fpath, encoding='utf-8', errors='strict')
		for line in f:
			pass
		return True
		f.close()
	except UnicodeDecodeError:
		return False

def check_xml_validity(urn):
	fpath = urn2filepath(urn)
	if os.path.exists(fpath):
		try:
			ET.parse(fpath)
			return True
			fpath.close()
		except ET.XMLSyntaxError:
			return False

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
			f.close()
	else:
		return False

#add field for catalog data link?

def build_new_json(
    data,
    urn,
    ):
        data[urn]['status'] = 'migrated'
        data[urn]['has_cts_metadata'] = check_cts_metadata(urn)
        data[urn]['has_cts_refsDecl'] = check_refsDecl(urn)
        data[urn]['epidoc_compliant'] = check_epidoc(urn)
        data[urn]['valid_xml'] = check_xml_validity(urn)
        data[urn]['fully_unicode'] = check_unicode(urn)


#change editor to last listed in revisionDesc?
#add in a timer? to see what's taking so long?
#add in JSON formatting?

def build_tracking_json_fromfiles(editor, repoList):
	files = list_files(repoList)
	data = {}
	urns = []
	valid_urns = []
	for f in files:
		if (check_filepath_urnability(f) == True):
			urns.append(filepath2urn(f))
	for urn in urns:
		if (check_urn_filepathability(urn)== True):
			if "pack" not in urn:
				valid_urns.append(urn)
	for urn in valid_urns:
		data[urn] = {}
		data[urn]["last_editor"] = editor
		data[urn]["git_repo"] = (urn2filepath(urn)).split("/")[0]
		data[urn]["target"] = (urn2filepath(urn))
		build_new_json(data, urn)
		print("updated " + urn)
		tracking_fpath = urn2filepath(urn).split(".xml")[0] + ".tracking.json"
		with open(tracking_fpath,"w") as outfile:
			json.dump(data[urn], outfile)
		outfile.close()
	print("Completed successfully!")

#build_tracking_json_fromfiles("Stella Dee", ["canonical-greekLit"])

#MAKE JSON PRETTY!!!
#test!!!
def gather_tracking_json_fromrepo(repoList):
	files = list_tracking_files(repoList)
	data = {}
	for fpath in files:
		with open(fpath, "r") as f:
			text = f.read()
			filepath = ("/").join(fpath.split("/")[:4]) + "/"+ fpath.split("/")[4].split(".tracking.json")[0] + ".xml"
			urn = filepath2urn(filepath)
			data[urn] = text
			print("adding"+ urn)
		f.close()
	with open("-".join(repoList) + ".tracking.json", "w") as outfile:
			json.dump(data, outfile)
			print("completed successfully! resulting file is " + "-".join(repoList) + ".tracking.json")
	outfile.close()

#make "note" optional?
#test!!!!
def update_singlefile_trackingjson(editor, urn, note):
	if (check_urn_filepathability(urn)== True):
		data = {}
		data[urn] = {}
		data[urn]["last_editor"] = editor
		data[urn]["git_repo"] = (urn2filepath(urn)).split("/")[0]
		data[urn]["target"] = (urn2filepath(urn))
		data[urn]["note"] = note
		build_new_json(data, urn)
		print("updated " + urn)
		tracking_fpath = urn2filepath(urn).split(".xml")[0] + ".tracking.json"
		with open(tracking_fpath,"w") as outfile:
			json.dump(data[urn], outfile)
		outfile.close()
		print("Completed successfully!")
	else:
		print("filepath does not exist")


"""	

#def update_tracking_json_singlefile(editor, urn, note):

def edit_premade_json(
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
        data[key]['has_cts_metadata'] = check_cts_metadata(str(data[key]['urn']))
        data[key]['has_cts_refsDecl'] = check_refsDecl(str(data[key]['urn']))
        data[key]['epidoc_compliant'] = check_epidoc(str(data[key]['urn']))
        data[key]['valid_xml'] = check_xml_validity(str(data[key]['urn']))
    else:
        data[key]['status'] = 'not-migrated'
        data[key]['git_repo'] = ''
        data[key]['has_cts_metadata'] = False
        data[key]['has_cts_refsDecl'] = False
        data[key]['epidoc_compliant'] = False	

def port_p4top5(editor, repoList):
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

"""

			