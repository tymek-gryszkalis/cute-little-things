import sys
import os
import shutil
from collections import defaultdict

typeDict = {
    "exe" : "Executable",
    "zip" : "Archives",
    "rar" : "Archives",
    "7z" : "Archives",
    "tgz" : "Archives",
    "jar" : "Jars",
    "mp3" : "Audio",
    "ogg" : "Audio",
    "wav" : "Audio",
    "flac" : "Audio",
    "mp4" : "Videos",
    "wmv" : "Videos",
    "avi" : "Videos",
    "m4a" : "Videos",
    "jpg" : "Pictures",
    "png" : "Pictures",
    "jpeg" : "Pictures",
    "gif" : "Pictures",
    "jfif" : "Pictures",
    "bmp" : "Pictures",
    "docx" : "Documents",
    "doc" : "Documents",
    "pptx" : "Documents",
    "xlsx" : "Documents",
    "pdf" : "PDFs",
    "sfk" : "Vegas dummies",
    "sfl" : "Vegas dummies",
    "txt" : "Text files",
    "c" : "Programming",
    "py" : "Programming",
    "html" : "Web",
    "htm" : "Web",
    "webp" : "Web",
    "torrent" : "Torrents",
    "msi" : "Installers",
    "unknown" : ""
}

def validateInput():
    if len(sys.argv) < 2:
        inp = os.getcwd()
    else:
        inp = sys.argv[1]

    if inp == "-h" or inp == "-?":
        print("TODO help")
        exit()
    
    if not os.path.isdir(inp):
        print("Invalid directory.")
        exit()
    
    if input("Do you want to sort the " + inp + " directory? [y/n]\n") != "y":
        print("Sorting cancelled.")
        exit()

    return inp

path = validateInput()

print("\nScanning directory...")
fdlist = os.scandir(path)

print("Matching filetypes...")
filesToSort = {}
subdirs = []
foldersToMake = set()
for i in fdlist:
    if i.is_dir():
        subdirs.append(i.name)
    else:
        spl = i.name.split(".")
        curtype = "unknown"
        if len(spl) > 1 and spl[len(spl) - 1] in typeDict.keys():
            foldersToMake.add(typeDict[spl[len(spl) - 1]])
            curtype = spl[len(spl) - 1]
        filesToSort[i.name] = curtype
print("Assessing new directories...\n")
foldersToDelete = []
for i in foldersToMake:
    if i in subdirs:
        foldersToDelete.append(i)
for i in foldersToDelete:
    foldersToMake.remove(i)

print("About to sort " + str(len(filesToSort)) + " files")
if input("\nProceed? [y/n]\n") != "y":
    print("Sorting cancelled.")
    exit()

print("\nCreating directories...")
for i in foldersToMake:
    os.mkdir(path + "\\" + i)

unknownFiles = 0
movedFiles = defaultdict(lambda : 0)
print("Moving files...")
for i in filesToSort:
    if filesToSort[i] == "unknown":
        unknownFiles += 1
        continue
    shutil.move(path + "\\" + i, path + "\\" + typeDict[filesToSort[i]])
    movedFiles[typeDict[filesToSort[i]]] += 1

print("Success!\n")
print("Files were assessed to categories:")
for i in movedFiles:
    print(i + ": " + str(movedFiles[i]))
print("Left uncategorized: " + str(unknownFiles))