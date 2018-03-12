These scripts work together to generate Graphiz graphs to ~confuse~ help us

`watcher.sh` - will pick up any changes in the `./anno` directory and then send the changed filenames to `makeviz.sh` which makes an svg (visualization) and then calls `makehtml.py` to make an interactive html page. So it goes `watcher.sh` > `makeviz.sh` > `makehtml.py` > pretty graph

ran on server with `sudo -u basex watcher.sh &`

to find and stop an existing process (when you want to start it afresh) use `ps -aux | grep inotify` and kill the process by id

Requirements
* python
* inotify
* jquery.graphiz.svg 
