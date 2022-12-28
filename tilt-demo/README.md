# Tilt demo

TODO:

- [x] run vote app and redis in docker
  - <https://docs.tilt.dev/api.html#api.docker_compose>
  - <https://docs.tilt.dev/api.html#api.dc_resource>
- [x] run result app and db in k8s
  - <https://docs.tilt.dev/api.html#api.k8s_yaml>
  - <https://docs.tilt.dev/api.html#api.k8s_resource>
- [ ] run worker app on host
  - <https://docs.tilt.dev/api.html#api.local_resource>
- multiple tiltfiles
  - <https://docs.tilt.dev/api.html#api.load>
  - <https://docs.tilt.dev/api.html#api.load_dynamic>
  - [x] vote and redis
  - [x] result and db
  - [ ] worker
- links and port forward
  - <https://docs.tilt.dev/accessing_resource_endpoints.html#arbitrary-links>
  - [x] vote and redis
  - [x] result and db
  - [ ] worker
- labels and grouping
  - <https://docs.tilt.dev/tiltfile_concepts.html#resource-groups>
  - [x] vote and redis
  - [x] result and db
  - [ ] worker
- [ ] Clone repo into a different workspace instead of commiting it?
  - ideal option if no code changes are required to get all desired scenarios working
- run-only mode vs edit mode
  - <https://docs.tilt.dev/tiltfile_config.html>
  - [ ] vote and redis. current is edit mode
  - [ ] result and db. current is run-only mode using pre-existing images from dockerhub
  - [ ] worker. dotnet build and run dll vs dotnet run on source?
- [ ] auto reload vs manual reload
  - TODO: maybe use redis and db for manual reload? or show how to toggle in the UI?
- running locally?
  - [ ] How do port mappings and links change when codespaces is opened locally in vscode?
  - [ ] what about when running locally **without** codespaces at all?
- [ ] name ports
- [ ] disable auto port forward?

```bash

# install Tilt
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash

# change into demo directory
cd tilt-demo

# create a clusters
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
# 5000 is vote app running in docker compose
# 31001 is result app running in kubernetes

# in tilt UI
# can also use the tilt UI to get to apps
# each app has a link to the app
# endpoints column when using the table view, top of page when using the details view

# apps are groups together in the tiltfile configuration

# type crtl + c to stop tilt

#  clean up
tilt down

k3d cluster delete --config ./k3d.yaml

```
