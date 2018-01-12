# TODO: Add more retry and error check

# Add heuristic for TakeANap, TakeACatNap, and Lunchbreak to speed up the process.

import logging
logging.basicConfig(level=logging.DEBUG)

import re
import datetime
import pytz
import json

import pycurl
from StringIO import StringIO

from random import randint
from time import sleep

try:
    from urllib.parse import urlparse, urlencode
    from urllib.request import urlopen, Request
    from urllib.error import HTTPError
except ImportError:
    from urlparse import urlparse
    from urllib import urlencode
    from urllib2 import urlopen, Request, HTTPError

import requests

testStr = """{"acceptedResourceRoles": ["slave_public"], "backoffFactor": 1.15, "backoffSeconds": 1, "labels": {}, "cpus": 2, "requirePorts": false, "instances": 1, "healthChecks": [], "disk": 0, "id": "/mon-sso-proxy1", "maxLaunchDelaySeconds": 3600, "container": {"docker": {"image": "10.161.33.1:9000/montana/mon-sso-proxy:2.3", "forcePullImage": true, "network": "BRIDGE", "parameters": [], "privileged": false}, "type": "DOCKER", "volumes": [{"hostPath": "/etc/etcd_client.crt", "containerPath": "/etc/etcd_client.crt", "mode": "RO"}, {"hostPath": "/etc/etcd_client.key", "containerPath": "/etc/etcd_client.key", "mode": "RO"}, {"hostPath": "/etc/ca.crt", "containerPath": "/etc/ca.crt", "mode": "RO"}, {"hostPath": "/etc", "containerPath": "/dcte", "mode": "RO"}]}, "env": {"EXTADDR": "199.219.42.216/24", "SERVICENAME": "MontstDEVNET", "ETCDSSLCRT": "/etc/etcd_client.crt", "CLUSTERNAME": "DIT", "ETCDSSLCA": "/etc/ca.crt", "ETCDSSLKEY": "/etc/etcd_client.key", "ETCDPORT": "2379", "SERVERPORT": ":18080", "HTTPSPORT": "443", "MANAGEMENT": "", "framework-id": "marathon", "EXTNETNAME": "DEVNET"}, "uris": ["file:///docker.tar.gz"], "mem": 4096, "args": null, "dependencies": [], "user": null, "storeUrls": [], "upgradeStrategy": {"maximumOverCapacity": 1, "minimumHealthCapacity": 1}, "cmd": null, "executor": "", "ports": [], "constraints": [["EXTNETNAME", "LIKE", "DEVNET"], ["hostname", "UNIQUE"]]}"""

MARATHON = 'http://leader.mesos:8080/v2/apps'
QUEUE = 'http://leader.mesos:8080/v2/queue'
TEST = 'http://www.yahoo.com'

RESETCOUNT = 5

defaultFeContainers = ["frontend-dynamicfw", "frontend-pipework", "frontend-quagga", "frontend-monitor", "frontend-poller"]

def genTimeStamp():
	return datetime.datetime.now(pytz.timezone("America/New_York")).strftime('%Y-%m-%d-%H-%M-%S%z')

def generateJSON(template):
	result = re.sub(r'TIMESTAMP', genTimeStamp(), template)
	envs = getEnvs()
	result = re.sub(r'{PROVISION_SERVER_IP}', envs["provision_server_ip"], result)
	result = re.sub(r'{QUAGGA_VERSION}', envs["quagga_version"], result)
	result = re.sub(r'{MONITOR_VERSION}', envs["monitor_version"], result)
	result = re.sub(r'{DYNAMICFW_VERSION}', envs["dynamicfw_version"], result)
	result = re.sub(r'{POLLER_VERSION}', envs["poller_version"], result)
	result = re.sub(r'{PIPEWORK_VERSION}', envs["pipework_version"], result)
	return result

def getAppIDFromTemplate(template):
	return json.loads(template)["id"]

def getEnvs(filename="envs.json"):
	with open(filename) as f:
		envs = json.loads(f.read())
	return envs

def marathonPOST(jsonStr):
	print jsonStr
	return urlopen(Request(MARATHON, urlencode(jsonStr), {"Content-Type": "application/json"})).read()

def marathonDELETEapp(appID):
	if appID.startswith("/") == False:	
		return requests.delete(MARATHON + "/" + appID)
	else:
		return requests.delete(MARATHON + appID)

def marathonResetDelay(appID):
	return requests.delete(QUEUE + "/" + appID.strip("/") + "/delay")
	
def marathonDeleteTaskByTaskID(appID, taskID):
	normAppID = appID.lstrip("/")
	normTaskID = taskID.lstrip("/")

	return requests.delete(MARATHON + "/" + normAppID + "/tasks/" + normTaskID)

def marathonScaleUpApp(appID, by=1):
	marathonScaleApp(appID, by)

def marathonScaleDownApp(appID, by=-1):
	marathonScaleApp(appID, by)

def marathonScaleApp(appID, by):
	normAppID = appID.lstrip("/")
	hosts, _ = getTaskHostMap(appID)
	hosts = getKeys23(hosts)
	numOfHosts = str(len(hosts) + by)

	print numOfHosts

	s = '{"id":"' + appID + '","instances":' + str(numOfHosts) + '}'
	print s
	print json.dumps(json.loads(s))
	
	r = StringIO()

	c = pycurl.Curl()
	c.setopt(pycurl.URL, MARATHON + "/" + normAppID + "?force=true")
	c.setopt(pycurl.HTTPHEADER, ['Content-Type:application/json'])
	c.setopt(pycurl.CUSTOMREQUEST, "PUT")
	c.setopt(pycurl.POSTFIELDS, json.dumps(json.loads(s)))
	c.setopt(pycurl.HEADERFUNCTION, r.write)
	c.setopt(pycurl.WRITEFUNCTION, r.write)
	c.perform()

	print c.getinfo(pycurl.HTTP_CODE)
	if c.getinfo(pycurl.HTTP_CODE) != 200:
		takeANap()
		c.perform()

	c.close()

	print r.getvalue()
	
def suspendGlobalWather():
	marathonScaleDownApp("/mon-global-watcher")

def startGlabalWather():
	marathonScaleUpApp("/mon-global-watcher")

def marathonDeleteTaskByHost(appID, host):
	normAppID = appID.lstrip("/")
	return requests.delete(MARATHON + "/" + normAppID + "/tasks?host=" + host)

def marathonScaleDownTaskByHost(appID, host):
	normAppID = appID.lstrip("/")
	#TODO: add retry if 409
	return requests.delete(MARATHON + "/" + normAppID + "/tasks?host=" + host + "&scale=true")

def marathonPOSTFile(filename):
	with open(filename) as f:
		s = f.read()

	response = StringIO()

	c = pycurl.Curl()
	c.setopt(pycurl.URL, MARATHON)
	c.setopt(pycurl.HTTPHEADER, ['Content-Type:application/json'])
	c.setopt(pycurl.POST, 1)
	c.setopt(pycurl.POSTFIELDS, json.dumps(json.loads(s)))
	c.setopt(pycurl.HEADERFUNCTION, response.write)
	c.setopt(pycurl.WRITEFUNCTION, response.write)
	c.perform()
	statusCode = c.getinfo(pycurl.HTTP_CODE)
	if statusCode != 200 and statusCode != 201:
		takeANap()
		c.perform()
		statusCode = c.getinfo(pycurl.HTTP_CODE)
	c.close()

	if statusCode != 200 and statusCode != 201:
		print "FAILED"
		print response.getvalue()
		return "FAILED"
	print response.getvalue()
	
def marathonPOSTJSONStr(s):
	response = StringIO()
	c = pycurl.Curl()
	c.setopt(pycurl.URL, MARATHON)
	c.setopt(pycurl.HTTPHEADER, ['Content-Type:application/json'])
	c.setopt(pycurl.POST, 1)
	c.setopt(pycurl.POSTFIELDS, json.dumps(json.loads(s)))
	c.setopt(pycurl.HEADERFUNCTION, response.write)
	c.setopt(pycurl.WRITEFUNCTION, response.write)
	c.perform()
	statusCode = c.getinfo(pycurl.HTTP_CODE)
	if statusCode != 200 and statusCode != 201:
		takeANap()
		c.perform()
		statusCode = c.getinfo(pycurl.HTTP_CODE)
	c.close()
	if statusCode != 200 and statusCode != 201:
		print "FAILED"
		print response.getvalue()
		return "FAILED"
	print response.getvalue()


def marathonPOSTFileNOTWorking(filename):
	with open(filename) as f:
		s = f.read()
	#return requests.post(MARATHON, data=json.dumps(s), headers={"Content-Type": "application/json"})	
	#resp = requests.post(MARATHON, json=s, headers={"Content-Type": "application/json"})	
	resp = requests.post(MARATHON, json=testStr, headers={"Content-Type": "application/json"})	
	print resp.text

def marathonGET(appID = "frontend-pipework"):
	return urlopen(MARATHON + "/" + appID).read()

def getAllApps():
	return urlopen(MARATHON).read()
	
def test():
	return urlopen(TEST).read()

def getAppIDs():
	parsedApps = json.loads(getAllApps())
	apps = parsedApps["apps"]
	result = []
	for app in apps:
		result.append(app["id"])	
	return result

def getAppIDsLike(prefix):
	# return a list of app ids that share the same prefix
	appIDs = getAppIDs()
	result = []
	for appID in appIDs:
		if appID.startswith(prefix) or appID.startswith("/" + prefix):
			result.append(appID.lstrip("/")) # normalize appID. No leading "/"
	return result 

def getApp(appID):
	return marathonGET(appID)

def getRunningTasks(appID):
	return json.loads(getApp(appID))["app"]["tasks"]

def getTaskHostMap(appID):
# return two dictionaries, host => taskID and taskID => host
	hostToTask = dict()
	taskToHost = dict()
	for task in getRunningTasks(appID):
		taskID = task["id"]
		host = task["host"]
		hostToTask[host] = taskID
		taskToHost[taskID] = host
	return hostToTask, taskToHost	

def getKeys23(d):
# python 2 and 3 compatible ways to get keys from dicts.
	return list(d)

def containIdenticalElementsD(list1, list2):
	return sorted(list1) == sorted(list2)

def takeANap():
	sleep(randint(15, 30))

def takeACatNap():
	sleep(randint(1, 5))

def lunchBreak():
	sleep(60)

def getFEHosts(reckless = False):
# Heuristic: get hosts running frontend-pipework and frontend-quagga,
# compare if they are identical
# wait random second (1 - 10), try again,
# return if they are all identical.
# if reckless set to true, return list obtained from frontend-quagga tasks, no re-try.
	quaggas = getAppIDsLike("frontend-quagga")
	# TODO: fetch the id with older timestamp
	quagga = quaggas[0]
	pipeworks = getAppIDsLike("frontend-pipework")
	# TODO: fetch the id with older timestamp
	pipework = pipeworks[0]
	hosts1q, _ = getTaskHostMap(quagga)
	hosts1q = getKeys23(hosts1q)
	#print hosts1q
	#print
	if reckless == True:
		return hosts1q
	else:
		hosts1p, _ = getTaskHostMap(pipework)
		hosts1p = getKeys23(hosts1p)
		#print hosts1p
		#print
		if containIdenticalElementsD(hosts1q, hosts1p) == False:
			return []
		else:
			takeANap()
			hosts2q, _ = getTaskHostMap(quagga)
			hosts2q = getKeys23(hosts2q)
			#print hosts2q
			#print
			hosts2p, _ = getTaskHostMap(pipework)
			hosts2p = getKeys23(hosts2p)
			#print hosts2p
			#print
			if containIdenticalElementsD(hosts1q, hosts2p) == False or containIdenticalElementsD(hosts2q, hosts2p) == False:
				return []
			else:
				return hosts1q

def getCurrentFeAppIDs(upgradeList=[]):
	result = {}
	if len(upgradeList) == 0:
		feContainers = defaultFeContainers
	else:
		feContainers = upgradeList
	for c in feContainers:
		ids = getAppIDsLike(c)
		if len(ids) == 1:
			result[c] = ids[0]
		else:
			print "Expected 1 instances of", c, "got: ", ids
			print "something is wrong"
			return {}
	return result

def getSeamlessTemplates(upgradeList=[]):
	result = {}
	if len(upgradeList) == 0:
		feContainers = defaultFeContainers
	else:
		feContainers = upgradeList
	for c in feContainers:
		#print re.sub(r'frontend', "seamless", c) + ".json.template"
		with open(re.sub(r'frontend', "seamless", c) + ".json.template") as seamlessF:
			result[c] = generateJSON(seamlessF.read())
	return result


def deploySeamlessTemplates(upgradeList=[]):
	templates = getSeamlessTemplates(upgradeList)
	newAppIDs = []
	for k in templates:
		print "deploying", k
		newAppIDs.append(getAppIDFromTemplate(templates[k]))
		status = marathonPOSTJSONStr(templates[k])
		if status == "FAILED":
			print "Failed to deploy new app", getAppIDFromTemplate(templates[k])
			print "Please manually remove apps from UI:", ",".join(newAppIDs)
			return -1 
		takeANap()
	return newAppIDs

def feUpgrade(upgradeList = [], reckless=False):
	print "Start Upgrade"
	print "Collecting inventory"
	print
	feHosts = getFEHosts(reckless)
	if feHosts == [] :
		print "FE not in a consistent state"
		return -1
	feAppIDs = getCurrentFeAppIDs(upgradeList)
	print "FE hosts"
	print ",".join(feHosts)
	print
	print "Current app IDs"
	for i in feAppIDs:
		print i
	print
	# TODO: Check global watcher status
	# print "Check global watcher status

	print "Deploying new fe containers"
	newAppIDs = deploySeamlessTemplates(upgradeList)
	if newAppIDs == -1:
		return -1
	print "New app IDs"
	for i in newAppIDs:
		print i
	print
	lunchBreak() # This has to be long enough for apps to scale to all FE nodes.
	print "Suspend Global Watcher"
	print
	suspendGlobalWather()
	takeANap()

	count = 0	
	for h in feHosts:
		for app in feAppIDs:
			print "Scale down", feAppIDs[app], "on host:", h
			marathonScaleDownTaskByHost(feAppIDs[app], h)
			takeACatNap()
			#raw_input("proceed?")

		# reset delay of the new app so they fill the gap left out by the old app
		count += 1
		if count % RESETCOUNT == 0:
			for i in newAppIDs:
				print marathonResetDelay(i)
				takeANap()
		takeANap()
		
			
			

	for app in feAppIDs:
		marathonDELETEapp(feAppIDs[app])
		takeACatNap()

	takeANap()
	# reset one last time
	for i in newAppIDs:
		print marathonResetDelay(i)
		takeANap()
	
	takeANap()
	print "Restore Global Watcher"
	startGlabalWather()


if __name__ == "__main__":
	#print genTimeStamp()
	#print marathonGET() 
	#print test()
	#print getAllApps()
	#print getAppIDs()
	#print getAppIDsLike("frontend")
	#print getRunningTasks("frontend-pipework")
	#hosts, tasks = getTaskHostMap("frontend-pipework")
	#print hosts
	#print
	#print tasks
	#print getFEHosts()
	#print getFEHosts(reckless = True)
	#print marathonPOSTFile("test.json")

	#feHosts = getFEHosts(reckless=True)
	#print feHosts
	#if feHosts == [] :
	#	print "FE not in a consistent state"
	#else:
	#	pass	
		#print marathonDeleteTaskByHost("frontend-pipework", feHosts[0])
		#print marathonScaleDownTaskByHost("frontend-pipework", feHosts[0])
		#takeANap()
		#print marathonScaleUpApp("frontend-pipework")
	#print getCurrentFeAppIDs()
	#templates = getSeamlessTemplates()
	#for k in templates:
	#	print k
	#	print json.dumps(json.loads(templates[k]) , indent=4)

	#print deploySeamlessTemplates()
	
	#feUpgrade(["frontend-quagga"])
	feUpgrade()
