-module(distribution_preloader_app).

-behaviour(application).

-define(NET_KERNEL_MONITOR_NODES_OPTIONS, [{node_type, visible}]).
-define(MILLISECONDS_IN_SECOND, 1000).

%% Application callbacks
-export([start/2, stop/1]).

%%%===================================================================
%%% API
%%%===================================================================

start(_StartType, _StartArgs) ->
  {ok, ClusterWaitTresholdSeconds} = application:get_env(cluster_wait_treshold_seconds),
  {ok, ClusterSize} = application:get_env(cluster_size),

  net_kernel:monitor_nodes(true, ?NET_KERNEL_MONITOR_NODES_OPTIONS),

  waiting_nodes_loop(ClusterWaitTresholdSeconds * ?MILLISECONDS_IN_SECOND, ClusterSize),
  decs_distribution_preloader_sup:start_link().

stop(_State) ->
  ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================

waiting_nodes_loop(ClusterWaitTresholdMillisecond, ClusterSize) ->
  receive
    {nodeup, _Node, ?NET_KERNEL_MONITOR_NODES_OPTIONS} ->
      AllNodes = all_nodes(),
      if length(AllNodes) >= ClusterSize ->
          net_kernel:monitor_nodes(false, ?NET_KERNEL_MONITOR_NODES_OPTIONS),
          flush(),
          ok;
         true ->
          waiting_nodes_loop(ClusterWaitTresholdMillisecond, ClusterSize)
      end;
    _Any ->
      waiting_nodes_loop(ClusterWaitTresholdMillisecond, ClusterSize)
  after ClusterWaitTresholdMillisecond ->
      exit({preloading_fail, {nodes_in_cluster, [all_nodes()]}})
  end.

flush() ->
  receive
    _ -> flush()
  after 0 ->
      ok
  end.

all_nodes() ->
  [node() | nodes()].
