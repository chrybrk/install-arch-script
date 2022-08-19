import sys, json, subprocess

global_variables = {
    "user":
    {
        "hostname": "",
        "homeuser": "",
        "region": "",
        "city": ""
    }
}

def loadJson():
    global global_variables
    with open('data.json', 'r') as openfile:
        global_variables = json.load(openfile)

def dumpJson():
    with open("data.json", "w") as outfile:
        json.dump(global_variables, outfile, indent=4)

def jsonManager(first, second, third):
    global global_variables
    loadJson()
    global_variables[first][second] = third
    dumpJson()
    loadJson()

def getValue(first, second):
    loadJson()
    return global_variables[first][second]

n = len(sys.argv)

if n == 4:
    jsonManager(sys.argv[1], sys.argv[2], sys.argv[3])
elif n == 3:
    print(getValue(str(sys.argv[1]), str(sys.argv[2])))
