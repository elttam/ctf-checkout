# Overview

**Title:** checkout  
**Category:** Crypto  
**Flag:** libctf{ecb_mode_strikes_again}  
**Difficulty:** easy

# Usage

The following will pull the latest 'elttam/ctf-checkout' image from DockerHub, run a new container named 'libctfso-checkout', and publish the vulnerable service on port 80:

```sh
docker run --rm \
  --publish 80:80 \
  --name libctfso-checkout \
  elttam/ctf-checkout:latest
```

# Build (Optional)

If you prefer to build the 'elttam/ctf-checkout' image yourself you can do so first with:

```sh
docker build ${PWD} \
  --tag elttam/ctf-checkout:latest
```
