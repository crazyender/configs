#!/bin/python
import SocketServer
import watchdog
import watchdog.events
import watchdog.observers
import sys
import os
import json
import base64

ignore_extens = [
        ".o",
        ".obj",
        ".a" ,
        ".bin",
        ".db",
        ".ko",
        ".so",
        ".tmp",
        ".TMP",
        ".d",
        ".mod.d",
        ".mod.c",
        ".cmd"
]

ignore_keywords = [
        ".git",
        "firmware"
]

def ignore(path):
        assert isinstance(path, str)
        for ext in ignore_extens:
                if path.endswith(ext):
                        return True
        for words in ignore_keywords:
                if path.find(words) != -1:
                        return True
        if os.path.isfile(path):
                if os.stat(path).st_size > (3 *1024*1024):
                        return True
        return False

if sys.platform == "linux2":
        import watchdog.observers.inotify
elif sys.platform == "darwin":
        import watchdog.observers.kqueue
else:
        import watchdog.observers.read_directory_changes
class LocalFileNotifier(watchdog.events.FileSystemEventHandler):
        def __init__(self, center):
                self.center = center

        def on_created(self, event):
                if os.path.isdir(event.src_path):
                        return
                if ignore(event.src_path):
                        return
                self.center.handle_message("MODIFIED", event.src_path)

        def on_deleted(self, event):
                if os.path.isdir(event.src_path):
                        return

                if ignore(event.src_path):
                        return
                self.center.handle_message("DELETE", event.src_path)

        def on_modified(self, event):
                if os.path.isdir(event.src_path):
                        return

                if ignore(event.src_path):
                        return
                self.center.handle_message("MODIFIED", event.src_path)

        def on_moved(self, event):
                if os.path.isdir(event.src_path):
                        return

                if os.path.isdir(event.dest_path):
                        return

                if ignore(event.src_path):
                        return
                if ignore(event.dest_path):
                        return
                self.center.handle_message("MOVE_FROM", event.src_path)
                self.center.handle_message("MOVE_TO", event.dest_path)


class EventCenter():
        def __init__(self):
                self.remotes = {}
                self.handlers = {
                        "MODIFIED" : self.handle_modified,
                        "DELETE" : self.handle_delete,
                        "MOVE_FROM" : self.handle_delete,
                        "MOVE_TO" : self.handle_modified,
                        "REMOTE_REG" : self.handle_remote_reg,
                        "REMOTE_UNREG" : self.handle_remote_unreg,
                        "REMOTE_BYE" : self.handle_remote_close,
                        "REMOTE_SUSPEND" : self.handle_remote_suspend,
                        "REMOTE_RESUME" : self.handle_remote_resume,
                        "REMOTE_MKDIR" : self.handle_remote_mkdir,
                        "REMOTE_PUT" : self.handle_remote_put,
                        "REMOTE_RENAME" : self.handle_remote_rename,
                        "REMOTE_RM" : self.handle_remote_rm,
                        "REMOTE_GET" : self.handle_remote_get,
                        "REMOTE_GET_LIST" : self.handle_remote_get_list,
                        "REMOTE_EXISTS" : self.handle_remote_exists

                }
                self.watchers = {}

                if sys.platform == "linux2":
                        self.observer = watchdog.observers.inotify.InotifyObserver()
                elif sys.platform == "darwin":
                        self.observer = watchdog.observers.kqueue.KqueueObserver()
                elif sys.platform == "win32":
                        self.observer = watchdog.observers.read_directory_changes.WindowsApiObserve()
                self.local = LocalFileNotifier(self)
                self.observer.start()

        def do_nothing(self, msg):
                pass

        def add_remote(self, ip, remote):
                assert isinstance(ip,str)
                if ip in self.remotes.keys():
                        return

                assert len(self.remotes.keys()) == 0
                print("{0} connected".format(ip))
                self.remotes[ip] = remote

        def handle_message(self, _id, msg, remote=None):
                assert isinstance(_id,str)
                assert isinstance(msg, str)

                if _id in self.handlers.keys():
                        if _id.startswith("REMOTE") == False:
                                print("recv:{0}:{1}".format(_id, msg))
                        self.handlers[_id](msg, remote)
                else:
                        print("Unknown msg: " + _id)

        def handle_remote_reg(self, msg, remote=None):
                assert isinstance(msg, str)
                print("recv:REG:"+msg)
                w = self.observer.schedule(self.local, msg, True)
                self.watchers[msg] = w

        def handle_remote_unreg(self, msg, remote=None):
                assert isinstance(msg, str)
                print("recv:UNREG:"+msg)
                if msg not in self.watchers.keys():
                        pass
                else:
                        self.observer.unschedule(self.watchers[msg])
                        self.watchers.pop(msg)

        def handle_remote_close(self, msg, remote=None):
                assert isinstance(msg, str)
                print("recv:BYE:"+msg)
                self.remotes.pop(msg.split(":")[0])

        def handle_modified(self, msg, remote=None):
                assert isinstance(msg, str)
                if os.path.exists(msg) == False:
                        return
                elif os.path.islink(msg):
                        return
                elif ignore(msg):
                        return
                else:
                        f = open(msg, "r")
                        c = f.read()
                        f.close()
                        data = base64.b64encode(c)
                obj = {}
                obj["path"] = msg
                obj["content_base64"] = data
                self.send_message("PULL", json.dumps(obj), remote)


        def handle_delete(self, msg, remote=None):
                assert isinstance(msg, str)
                self.send_message("RM", msg)

        def send_message(self, _id, msg, remote=None):
                if len(self.remotes) == 0:
                        print("Error, no remote")
                        return
                if remote == None:
                        for r in self.remotes.values():
                                r.sendall(_id + ":" + msg + "\n")
                else:
                        remote.sendall(_id+":"+msg+"\n")

        def handle_remote_suspend(self, msg, remote=None):
                print("recv:SUSPEND:"+msg)
                for path in self.watchers.keys():
                        self.observer.unschedule(self.watchers[path])

        def handle_remote_resume(self, msg, remote=None):
                print("recv:RESUME:"+msg)
                for path in self.watchers.keys():
                        w = self.observer.schedule(self.local, path, True)
                        self.watchers[path] = w

        def handle_remote_put(self, msg, remote=None):
                obj = json.loads(msg)
                path = obj["path"]
                content_base64 = obj['content_base64']
                print("recv:PUT:"+path)
                f = open(path, 'w')
                data = base64.b64decode(content_base64)
                f.write(data)
                f.close()

        def handle_remote_rename(self, msg, remote=None):
                obj = json.loads(msg)
                old_path = obj["old_path"]
                new_path = obj["new_path"]
                print("recv:RENAME:"+old_path+" -> " + new_path)
                try:
                        os.rename(old_path, new_path)
                except:
                        pass

        def handle_remote_mkdir(self, msg, remote=None):
                print("recv:MKDIR:"+msg)
                try:
                        os.makedirs(msg)
                except:
                        pass

        def handle_remote_rm(self, msg, remote=None):
                print("recv:RM:"+msg)
                try:
                        os.remove(msg)
                except:
                        pass

        def handle_remote_get(self, msg, remote=None):
                print("recv:GET:"+msg)
                self.handle_modified(msg, remote)

        def handle_remote_get_list(self, msg, remote):
                print("recv:LIST:"+msg)
                file_list = []
                for f in os.listdir(msg):
                        if ignore(f):
                                continue
                        file_content = {}
                        full_path = os.path.join(msg, f)
                        if os.path.isfile(full_path):
                                file_content["is_path"] = False
                        elif os.path.isdir(full_path):
                                file_content["is_path"] = True
                        else:
                                file_content["is_path"] = False

                        file_content["name"] = f
                        file_list.append(file_content)
                ret = json.dumps(file_list)
                if remote != None:
                        remote.sendall("LIST:"+ret+"\n")

        def handle_remote_exists(self, msg, remote):
                print("recv:EXISTS:"+msg)
                result = os.path.exists(msg)
                ret = "NO"
                if result == True:
                        ret = "YES"
                else:
                        ret = "NO"
                if remote != None:
                        remote.sendall("EXISTS:"+ret+"\n")


event_center = EventCenter()

class ServerHandler(SocketServer.StreamRequestHandler):

        def handle(self):
                event_center.add_remote(str(self.client_address[0]),
                                        self.request)
                while True:
                        line = self.rfile.readline()
                        assert(isinstance(line, str))
                        if len(line) == 0:
                                break
                        line = line.strip()
                        pair = []
                        index = line.find(":")
                        pair.append(line[0:index])
                        pair.append(line[index+1:])
                        event_center.handle_message(pair[0].strip(),
                                                    pair[1].strip(),
                                                    self.request)
                        if pair[0].strip() == "BYE":
                                break

if __name__ == "__main__":
        if len(sys.argv) < 3:
                print("usage: syncserver ip port")
                exit(-1)
        host = sys.argv[1]
        port = int(sys.argv[2])
        server = SocketServer.TCPServer((host, port), ServerHandler)
        server.allow_reuse_address = True
        server.serve_forever()
