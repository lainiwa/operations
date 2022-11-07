
# Tech Stack: What, Why?

Here I tried to balance two things:
1. demostrating my knowledge
2. not creating an unnecesserily complex "fizz-buzz enterpise edition"-like solution, where possible

## `poetry` for Python Dependencies Pinning
Switched from `pip install` to using `poetry`.

Rationale: if we want reproducibility, we need to pin our dependencies.  
There are multiple ways to do this:
* e.g. we could just place `pip freeze > requirements.txt` to our git hooks
* `poetry` is one of the tools, that have dependency pinnning out-of-the-box, so I expect it to be a more developer-friendly solution.

## `Dockerfile`
Docker is a standard tool for packing and deploying SaaS apps.

I explicitly do not go for a multi-stage build solution:
* otherwise we would have to `Dockerfile`s (prod and dev would differ)
* because two-stage build is slower, and less fit for development environment (also a bit more complex)
* when pulling the images, the server would pull the layer with `apt install ...` only once anyway

Note on the original README.md: the `DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y python3-pip` from the example would not work as intended, because the varible would be seen only by `apt-get update`.

## `scripts/` for automation
I prefer those to `Makefile`s, because:
* bash is usually present on the server OS
* shell syntanx is more well-known

## `docker-compose`
I decided that setting up a full-blown cluster would be an overkill, so I used docker-compose instead.

## `traefik`
We need to differentiate between the stage and the prod.
The simplest way would be to bind them to different ports, of course.
Yet I went a bit forther and set up a reverse proxy for HTTP `Host:` based differentiation.

## Github Actions
I decided I want to update the service when new code is commited to the repo.
One way to do this is to create an image with the service, which will then be pulled to the server and run.

Github Actions is just the CI/CD platform I'm familiar with.

## `terraform` for Hetzner
Spawns the VM, sends the `.env` file, `up`s the docker-compose.
Most popular tool for IaaC, has many integrations.

As I just spawn a signle VM, the provider choice is largely irrelevant: any would suffice, and the terraform code would be similar.

## No `ansible` (or other tool for server patching)
For more complicated cases I would prefer ansible, but for now terraform's `*-exec` is enough.

## Managing secrets with `get-secret`
I prefer having everything in the repo, so I picked `git-secret`.
There are a few similar tools (e.g. `agebox`, in case we do not want to use gpg).

The access control is not fine-grained of course, but if the number of DevOps is limited, it is enough. Otherwise we could use a 3rd party service (vault).
