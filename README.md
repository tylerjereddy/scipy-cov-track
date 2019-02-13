Assess the line coverage for Python and compiled language source files retroactively over the history of the SciPy project using a Docker-based approach.

build Docker image in repo root with: `docker build -t scipy-cov .`

specify the dependency versions using environment variables (i.e., in a file), and run the docker container to probe line coverage with a command like this:
`docker run -it --env-file env_files/env-scipy-0.18.1 scipy-cov`
