#!/bin/python
import SocketServer
import watchdog
import watchdog.events
import watchdog.observers
import sys
import os

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

                self.center.handle_message("MODIFIED", event.src_path)

        def on_deleted(self, event):
                if os.path.isdir(event.src_path):
                        return

                self.center.handle_message("DELETE", event.src_path)

        def on_modified(self, event):
                if os.path.isdir(event.src_path):
                        return

                self.center.handle_message("MODIFIED", event.src_path)

        def on_moved(self, event):
                if os.path.isdir(event.src_path):
                        return

                if os.path.isdir(event.dest_path):
                        return

                self.center.handle_message("MOVE_FROM", event.src_path)
                self.center.handle_message("MOVE_TO", event.dest_path)


class EventCenter():
        def __init__(self):
                self.filters = []
                self.ignores = [".git"]
                self.remotes = {}
                self.handlers = {
                        "REG" : self.handle_reg,
                        "UNREG" : self.handle_unreg,
                        "BYE" : self.handle_close,
                        "MODIFIED" : self.handle_modified,
                        "DELETE" : self.handle_delete,
                        "MOVE_FROM" : self.handle_delete,
                        "MOVE_TO" : self.handle_modified,
                        "SUSPEND" : self.handle_suspend,
                        "RESUME" : self.handle_resume,
                        # "SUSPEND" : self.do_nothing,
                        # "RESUME" : self.do_nothing,
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

        def handle_message(self, _id, msg):
                assert isinstance(_id,str)
                assert isinstance(msg, str)
                if msg in self.filters and _id != "RESUME":
                        print("{0} {1} but remote dont want it, do nothing".format(_id, msg))
                        return

                for igonre_path in self.ignores:
                        if msg.find(igonre_path) != -1:
                                print("{0} {1} but in ignore list, do nothing".format(_id, msg))
                                return

                if _id in self.handlers.keys():
                        print("{0} : {1}".format(_id, msg))
                        self.handlers[_id](msg)
                else:
                        print("Unknown msg: " + _id)

        def handle_reg(self, msg):
                assert isinstance(msg, str)
                w = self.observer.schedule(self.local, msg, True)
                self.watchers[msg] = w

        def handle_unreg(self, msg):
                assert isinstance(msg, str)
                if msg not in self.watchers.keys():
                        print("{0} not under watch".format(msg))
                else:
                        self.observer.unschedule(self.watchers[msg])
                        self.watchers.pop(msg)

        def handle_close(self, msg):
                assert isinstance(msg, str)
                self.remotes.pop(msg)

        def handle_modified(self, msg):
                assert isinstance(msg, str)
                self.send_message("PULL", msg)


        def handle_delete(self, msg):
                assert isinstance(msg, str)
                self.send_message("RM", msg)

        def send_message(self, _id, msg):
                if len(self.remotes) == 0:
                        print("Error, no remote")
                        return
                self.remotes.values()[0].sendall(_id + ":" + msg + "\n")

        def handle_suspend(self, msg):
                if msg not in self.filters:
                        self.filters.append(msg)

        def handle_resume(self, msg):
                if msg in self.filters:
                        self.filters.remove(msg)

event_center = EventCenter()

class ServerHandler(SocketServer.StreamRequestHandler):

        def handle(self):
                event_center.add_remote(str(self.client_address[0]),
                                        self.request)
                while True:
                        line = self.rfile.readline()
                        if len(line) == 0:
                                break
                        line = line.strip()
                        pair = line.split(":")
                        event_center.handle_message(pair[0].strip(), pair[1].strip())
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
