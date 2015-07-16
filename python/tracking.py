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

#this needs modification--doesn't give valid results right now
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

def build_new_json(data, urn):
	data[urn]['status'] = 'migrated'
	data[urn]['has_cts_metadata'] = check_cts_metadata(urn)
	data[urn]['has_cts_refsDecl'] = check_refsDecl(urn)
	data[urn]['valid_xml'] = check_xml_validity(urn)
	data[urn]['fully_unicode'] = check_unicode(urn)
    # can't be unicode without being valid xml--this saves time
	if check_xml_validity(urn) == True:
		data[urn]['epidoc_compliant'] = check_epidoc(urn)
	else:
		data[urn]['epidoc_compliant'] =False


#test!!!
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

#gather_tracking_json_fromrepo(["canonical-greekLit"])

#change editor to last listed in revisionDesc? bring in info from classics.xml?
#should this also mess with the massive file and update that if possible? resolving discrepencies (or noting them?)
#better error handling if filepath can't be created?
def update_singlefile_trackingjson(urn, editor="unknown", note="", ident="", src=""):
	if (check_urn_filepathability(urn)== True):
		data = {}
		data[urn] = {}
		#make the editor checking dynamic by checking file?
		data[urn]["last_editor"] = editor
		data[urn]["target"] = (urn2filepath(urn))
		data[urn]["note"] = note
		data[urn]["id"] = ident
		data[urn]["src"] = src
		data[urn]["git_repo"] = (urn2filepath(urn)).split("/")[0]
		if os.path.exists((urn2filepath(urn))):
			data[urn]["git_repo"] = (urn2filepath(urn)).split("/")[0]
			build_new_json(data, urn)
			data[urn]["status"] = "migrated"
		else:
			data[urn]["status"] = "not migrated"
		tracking_fpath = urn2filepath(urn).split(".xml")[0] + ".tracking.json"
		# make this an edit not a complete rewrite?
		if os.path.exists(tracking_fpath):
			try:
				with open(tracking_fpath, "r") as f:
					oldJson = json.loads(f.read())
					data[urn]["id"] = oldJson["id"]
					data[urn]["src"] = oldJson["src"]
				#ADD IN TRACKING FOR ADDITIONS OR DELETIONS, NOT JUST CHANGES?
					for key in oldJson:
						if oldJson[key] != data[urn][key]:
							print(key+ " changed from " + oldJson[key] + " to " + data[urn][key] + " for " + urn)
						if key not in data[urn]:
							print(key + " lost " + "--old value of " + oldJson[key] + " for " + urn)
					for key in data[urn]:
						if key not in oldJson:
							print(key + " added " + " with a value of " + data[urn][key] + " for " + urn)
				f.close()
				with open(tracking_fpath,"w") as outfile:
					json.dump(data[urn], outfile,sort_keys=True, indent=4)
				print("Updated tracking file for " + urn)
				outfile.close()
			except IsADirectoryError:
				os.rmdir(tracking_fpath)
				with open(tracking_fpath,"w") as outfile:
					json.dump(data[urn], outfile,sort_keys=True, indent=4)
				outfile.close()
				print("Created new tracking file for " + urn)
		elif os.path.exists(("/").join(tracking_fpath.split("/")[0:4])):
			with open(tracking_fpath,"w") as outfile:
				json.dump(data[urn], outfile,sort_keys=True, indent=4)
			outfile.close()
			print("Created new tracking file for " + urn)
		else:
			os.makedirs(("/").join(tracking_fpath.split("/")[0:4]))
			with open(tracking_fpath,"w") as outfile:
				json.dump(data[urn], outfile,sort_keys=True, indent=4)
			outfile.close()
			print("Created new tracking file for " + urn)
		print("Completed successfully!")
	else:
		print("Filepath cannot be created from URN " + urn)

#Probably don't need the functions below for awhile (or ever again):

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
				if "tracking" not in urn:
					valid_urns.append(urn)
	for urn in valid_urns:
		data[urn] = {}
		data[urn]["last_editor"] = editor
		data[urn]["git_repo"] = (urn2filepath(urn)).split("/")[0]
		data[urn]["target"] = (urn2filepath(urn))
		build_new_json(data, urn)
		print("Updated tracking file for " + urn)
		tracking_fpath = urn2filepath(urn).split(".xml")[0] + ".tracking.json"
		with open(tracking_fpath,"w") as outfile:
			json.dump(data[urn], outfile, sort_keys=True, indent=4)
		outfile.close()
	print("Completed successfully!")

#build_tracking_json_fromfiles("Stella Dee", ["canonical-greekLit"])


def update_singlefile_trackingjson_fromp4top5file(editor, urn, note, ident, src):
	if (check_urn_filepathability(urn)== True):
		data = {}
		data[urn] = {}
		data[urn]["last_editor"] = editor
		data[urn]["target"] = (urn2filepath(urn))
		data[urn]["note"] = note
		data[urn]["id"] = ident
		data[urn]["src"] = src
		data[urn]["git_repo"] = (urn2filepath(urn)).split("/")[0]
		if os.path.exists((urn2filepath(urn))):
			data[urn]["git_repo"] = (urn2filepath(urn)).split("/")[0]
			build_new_json(data, urn)
			data[urn]["status"] = "migrated"
		else:
			data[urn]["status"] = "not migrated"
		tracking_fpath = urn2filepath(urn).split(".xml")[0] + ".tracking.json"
		# make this an edit not a complete rewrite?
		if os.path.exists(tracking_fpath):
			try:
				with open(tracking_fpath, "r") as f:
					oldJson = json.loads(f.read())
				#ADD IN TRACKING FOR ADDITIONS OR DELETIONS, NOT JUST CHANGES?
					for key in oldJson:
						if oldJson[key] != data[urn][key]:
							print(key+ " changed from " + oldJson[key] + " to " + data[urn][key] + " for " + urn)
						if key not in data[urn]:
							print(key + " lost " + "--old value of " + oldJson[key] + " for " + urn)
					for key in data[urn]:
						if key not in oldJson:
							print(key + " added " + " with a value of " + data[urn][key] + " for " + urn)
				f.close()
				with open(tracking_fpath,"w") as outfile:
					json.dump(data[urn], outfile,sort_keys=True, indent=4)
				print("Updated tracking file for " + urn)
				outfile.close()
			except IsADirectoryError:
				os.rmdir(tracking_fpath)
				with open(tracking_fpath,"w") as outfile:
					json.dump(data[urn], outfile,sort_keys=True, indent=4)
				outfile.close()
				print("Created new tracking file for " + urn)
		elif os.path.exists(("/").join(tracking_fpath.split("/")[0:4])):
			with open(tracking_fpath,"w") as outfile:
				json.dump(data[urn], outfile,sort_keys=True, indent=4)
			outfile.close()
			print("Created new tracking file for " + urn)
		else:
			os.makedirs(("/").join(tracking_fpath.split("/")[0:4]))
			with open(tracking_fpath,"w") as outfile:
				json.dump(data[urn], outfile,sort_keys=True, indent=4)
			outfile.close()
			print("Created new tracking file for " + urn)
		print("Completed successfully!")
	else:
		print("Filepath cannot be created from URN " + urn)

#update_singlefile_trackingjson("Stella Dee", "urn:cts:greekLit:tlg0003.tlg001.opp-ger3")

#the function below is not yet finished--will probably only need to be run once

def port_p4top5(repoList):
	with open("tei-conversion-tools/summary_data/p4top5.json", "r") as old_data:
		oldJson = old_data.read()
		oldData = json.loads(oldJson)
		urnLessEntries = {}
		for key, value in oldData.items():
			if len(oldData[key]["sub"]) == 0:
				if len(oldData[key]["urn"]) > 0:
					update_singlefile_trackingjson_fromp4top5file("", oldData[key]["urn"], oldData[key]["note"], oldData[key]["id"], oldData[key]["src"])
					print("Updated " + oldData[key]["urn"])
				else:
					oldData[key]["status"] = "not migrated - NO URN"
					urnLessEntries[key] = oldData[key] 
					print("Added " + oldData[key]["id"] + " to urnLessEntries")
			else:
				for l in oldData[key]["sub"]:
					if len(l["urn"]) > 0:
						update_singlefile_trackingjson_fromp4top5file("", l["urn"], l["note"], l["id"], ("---").join([oldData[key]["src"], l["src"],"-".join(l["sub"])]))
						print("Updated " + l["urn"])
					else:
						l["src"] = [oldData[key]["src"], l["src"],l["sub"]]
						l["status"] = "not migrated - NO URN"
						urnLessEntries[l["id"] + ":" + "-".join(l["sub"])] = l
						print("Added " + l["id"] + ":" + "-".join(l["sub"]) + " to urnLessEntries")
		with open("tei-conversion-tools/summary_data/urnLessEntries.json", "w") as f:
			json.dump(urnLessEntries, f,sort_keys=True, indent=4)
		#this updates the big file
		gather_tracking_json_fromrepo(repoList)

#port_p4top5(["canonical-greekLit", "canonical-latinLit"])


