Distribution Preloader
=====

Awaits configured nodes count in configured time for start with minimal cluster size in distributed systems.

## Usage

In your rebar.config

```erlang
{deps,
 [{distribution_preloader, {git, "https://github.com/bottleneko/distribution_preloader", {branch, "master"}}}
 ]}.
```

In your *.app.src

```erlang
...
{applications,[
    kernel,
    stdlib,
    ...
    distribution_preloader,
    your_application,
    ...
]}
...
```

## Configuration

In your sys.config
```erlang
{distribution_preloader,
 [{cluster_wait_threshold_seconds, 60}, % maximum time for waiting cluster in seconds
  {cluster_size, 3}                     % if your app requires at least 3 nodes for start
 ]}.

{nodefinder,
 [{if_name, <<"eth0">>} % if you have internal internal network eth0 for distribution
 ]}.
```
