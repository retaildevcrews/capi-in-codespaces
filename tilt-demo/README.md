# Tilt demo

TODO:

- [x] run vote app and redis in docker
  - <https://docs.tilt.dev/api.html#api.docker_compose>
- [ ] run result app and db in k8s
- [ ] run worker app on host
- run-only mode vs edit mode
  - <https://docs.tilt.dev/tiltfile_config.html>
  - [ ] vote and redis
  - [ ] result and db
  - [ ] worker
- multiple tiltfiles
  - <https://docs.tilt.dev/api.html#api.load>
  - <https://docs.tilt.dev/api.html#api.load_dynamic>
  - [x] vote and redis
  - [ ] result and db
  - [ ] worker
- [ ] auto reload vs manual reload
  - TODO: maybe use redis and db for manual reload?
- links and port forward
  - <https://docs.tilt.dev/accessing_resource_endpoints.html#arbitrary-links>
  - [x] vote and redis
  - [ ] result and db
  - [ ] worker
- labels and grouping
  - <https://docs.tilt.dev/tiltfile_concepts.html#resource-groups>
  - [x] vote and redis
  - [ ] result and db
  - [ ] worker
- [ ] Clone repo into a different workspace instead of commiting it?
  - ideal option if no code changes are required to get all desired scenarios working
- [ ] How do port mappings and links change when codespaces is opened locally in vscode?

```bash

# install Tilt
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash

# change into demo directory
cd tilt-demo

# set environment variables for apps
VOTER_APP_PORT=5000
export VOTE_APP_URL="https://${CODESPACE_NAME}-${VOTER_APP_PORT}.preview.app.github.dev"

# start dev environment with tilt
tilt up

# view tilt ui
# go to ports tab and open port 10350 in the browser to view tilt UI

# type crtl + c to stop tilt

#  clean up
tilt down

```
