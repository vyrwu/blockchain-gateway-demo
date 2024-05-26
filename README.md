# polygon-demo

Simple reverse proxy that gives access to a selected number of Ethereum JSON-RPC
methods. Served by https://polygon-rpc.com/

## Supported methods

- [eth_blockNumber](https://www.quicknode.com/docs/polygon/eth_blockNumber)
- [eth_getBlockByNumber](https://www.quicknode.com/docs/polygon/eth_getBlockByNumber)

## What could be added to ensure the application is production ready?

### Application

- support for multiple destination URLs, with dynamic url selection (i.e. based
  on latency, health, or other metrics/indicators)
- config handling via file/environmental variable
- proper structured logger
- high-availability for proxy handler
- as app grows, improved project structure
- custom implementation of ReverseProxy for performance (alternatively nginx or
  envoy)
- rate-limitting/throttling
- API key auth

### CI/CD

- general release process
- CI and release pipelines (lint/test/scan/build/sign/publish)
- semantic versioning support with git tags/github releases
- progressive delivery (BG/Canary)
- manual approval process

### Infrastructure

- TLS support
- DNS setup
- service health checks
- private routing (i.e. with mesh)
- app autoscaling
- high-availability
- multi-environment support (test/stage/prod)
- split state files into multiple repos (what platform team owns vs. developers)
- better resource naming
- (optional) using OSS modules rather than plain TF resources
- remote TF state backend (i.e. S3)

### Observability

- logs/metrics/traces/dashboards (hot and cold storage)
- alerting (i.e. via Slack/PagerDuty)

## Comments

Provided infrastructure does not provision as I hit some network-related
blockers related to the Internet Gateway. I suspect more issues on the load
balancing side - all resolvable with additional time.

```
ResourceInitializationError: unable to pull secrets or registry auth: execution resource retrieval failed: unable to retrieve ecr registry auth: service call has been retried 3 time(s): RequestError: send request failed caused by: Post "https://api.ecr.eu-west-1.amazonaws.com/": dial tcp 63.34.63.179:443: i/o timeout. Please check your task network configuration.
```
