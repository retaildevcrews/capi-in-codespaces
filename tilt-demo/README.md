# Tilt demo

TODO:

- [x] run vote app and redis in docker
- [x] run result app and db in k8s
- [x] run worker app directy on host
- [x] multiple Tiltfiles for organization
- [x] UI links and port forwards
- [x] labels and grouping to organize UI
- [x] Clone repo into a different workspace instead of commiting it
- [ ] diagram of setup
- run-only mode vs edit mode
  - <https://docs.tilt.dev/tiltfile_config.html>
  - [ ] vote and redis. current is edit mode
  - [ ] result and db. current is run-only mode
  - [ ] worker. current is edit mode
- [ ] auto reload vs manual reload
  - maybe use redis and db for manual reload? or show how to toggle in the UI?
- using the tilt setup locally
  - [ ] How do port mappings and links change when codespaces is opened locally in vscode?
  - [ ] what about when running locally **without** codespaces at all?
- [ ] named ports in codespace devcontainer
- [ ] disable auto port forwards to reduce the number of ports in the ports tab?
- [ ] codespace: workspaces and editing files in a different workspace

```bash

# install Tilt
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash

# clone voting sample app
git clone https://github.com/dockersamples/example-voting-app.git /workspaces/example-voting-app

# change into demo directory
cd tilt-demo

# add entries to hosts file.
# the worker sample app is looking for specific host names and is not configurable without code changes
if ! grep "tilt-demo" /etc/hosts
then
  echo "append db and redis to /etc/hosts"
  echo '# tilt-demo' | sudo tee -a /etc/hosts
  echo '127.0.0.1 db redis' | sudo tee -a /etc/hosts
else
  echo "found tilt-demo in /etc/hosts. skip append"
fi

# create a cluster
k3d cluster create --config ./k3d.yaml

# set environment variables for apps
# voter app
VOTE_APP_PORT=5000
export VOTE_APP_URL="https://${CODESPACE_NAME}-${VOTE_APP_PORT}.preview.app.github.dev"
# results app
RESULT_APP_PORT=31001
export RESULT_APP_URL="https://${CODESPACE_NAME}-${RESULT_APP_PORT}.preview.app.github.dev"

# start dev environment with tilt
tilt up

# view tilt ui
# go to ports tab and open port 10350 in the browser to view tilt UI

# other ports
# vote app running in docker compose
#   UI = 5000
#   redis = 6379
# result app running in kubernetes
#   UI = 31001
#   psql db = 5432
# worker app is running on the host

# in tilt UI
# can also use the tilt UI to get to apps
# each app has a link to the app
# endpoints column when using the table view, top of page when using the details view

# click on the "Vote app" and "Result app" links in the Tilt UI to open in a new tab
# The Results app shows 50/50 initially when there are no votes
# Pick one of the options in te Vote app
# Go back to the Results app and observe the change in the UI

# Tilt was able to coordinate development of multiple apps, running in different environments. Get nice features like auto reloads and redeploys, single plane of glass UI with streaming logs, named links in UI, service grouping, and more.

# type crtl + c to stop tilt

#  clean up
tilt down

k3d cluster delete --config ./k3d.yaml

```
