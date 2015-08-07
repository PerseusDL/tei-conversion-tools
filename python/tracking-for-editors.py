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
import time

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
			if len(f.split("/")) > 2:
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
			outs, errs = p.communicate(timeout=4)
			if str(outs) == "b''":
				return True
			else:
				return False
		except subprocess.TimeoutExpired:
			p.kill()
			p.communicate()
			return False
	else:
		pass

#this needs modification--doesn't give very helpful results right now

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

def gather_tracking_json_fromrepo(repoList):
	data = {}
	for repo in repoList:
		files = list_tracking_files([repo])
		repoData = {}
		for fpath in files:
			with open(fpath, "r") as f:
				text = f.read()
				filepath = ("/").join(fpath.split("/")[:4]) + "/"+ fpath.split("/")[4].split(".tracking.json")[0] + ".xml"
				urn = filepath2urn(filepath)
				repoData[urn] = json.loads(text)
				print("Adding "+ urn)
				f.close()
		with open(repo + "/" + repo+".tracking.json", "w") as outfile:
				json.dump(repoData, outfile,sort_keys=True, indent=4)
				print("Completed successfully! The resulting file can be found at " + repo + "/" + repo+".tracking.json")
		outfile.close()
		data[repo] = repoData
	return data

def update_tracking_files_singleUrn(urn, editor, note):
	#determine repository name
	repo_name = urn.split(":")[2]
	# run new checks
	has_cts_metadata = check_cts_metadata(urn)
	has_cts_refsDecl = check_refsDecl(urn)
	valid_xml = check_xml_validity(urn)
	fully_unicode = check_unicode(urn)
	if check_xml_validity(urn) == True:
		epidoc_compliant = check_epidoc(urn)
	else:
		epidoc_compliant = False
	tracking_fpath = urn2filepath(urn).split(".xml")[0] + ".tracking.json"
	#if there's already a tracking file
	if os.path.exists(tracking_fpath):
		with open(tracking_fpath, "r") as f:
			data = json.loads(f.read())	
		data['has_cts_metadata'] = has_cts_metadata
		data['has_cts_refsDecl'] = has_cts_refsDecl
		data['valid_xml'] = valid_xml
		data['fully_unicode'] = fully_unicode
		data['note'] = data['note'] + "|" + note
		data['last_editor'] = editor
		data['epidoc_compliant'] = epidoc_compliant
		#update individual file
		with open(tracking_fpath,"w") as f:
			json.dump(data, f ,sort_keys=True, indent=4)
		#update composite data file
		with open("canonical-" + repo_name + "/canonical-" + repo_name + ".tracking.json", "r") as f:
			comp_data = json.loads(f.read())
		comp_data[urn] = data
		with open("canonical-" + repo_name + "/canonical-" + repo_name + ".tracking.json", "w") as f:
			json.dump(comp_data, f ,sort_keys=True, indent=4)
		print("Tracking data for " + urn + " updated successfully!")
		print("Individual file can be found at " + tracking_fpath)
		print("Composite file can be found at " + "canonical-" + repo_name + "/canonical-" + repo_name + ".tracking.json")
	#if there's not already a tracking file	
	else:
	#Create individual file
		data = {}
		data['git_repo'] = repo_name
		data['has_cts_metadata'] = has_cts_metadata
		data['fully_unicode'] = fully_unicode
		data['target'] = urn2filepath(urn)
		data['status'] = 'migrated'
		data['epidoc_compliant'] = epidoc_compliant
		data['has_cts_refsDecl'] = has_cts_refsDecl
		data['last_editor'] = editor
		data['valid_xml'] = valid_xml
		data['note'] = note
		with open(tracking_fpath,"w") as f:
			json.dump(data, f ,sort_keys=True, indent=4)
		#Add to composite data file
		with open("canonical-" + repo_name + "/canonical-" + repo_name + ".tracking.json", "r") as f:
			comp_data = json.loads(f.read())
		comp_data[urn] = data
		with open("canonical-" + repo_name + "/canonical-" + repo_name + ".tracking.json", "w") as f:
			json.dump(comp_data, f ,sort_keys=True, indent=4)
		print("Tracking data for " + urn + " updated successfully!")
		print("Individual file can be found at " + tracking_fpath)
		print("Composite file can be found at " + "canonical-" + repo_name + "/canonical-" + repo_name + ".tracking.json")

print("Before using this script for the first time, copy, paste, and run this in your command line: call('curl -O http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng', shell=True) ")

print("URN should be in form urn:cts:greekLit:tlg0028.tlg004.perseus-eng1")

print("Run this script from the root repository where you keep the canonical repositories, e.g. if your structure is Development/canonical-greekLit, run from inside Development")

#update_tracking_files_singleUrn(urn, editor, note)



