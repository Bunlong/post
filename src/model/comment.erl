-module(comment, [Id, Title, Content]).
-compile([export_all]).

after_create() ->
  boss_mq:push("new-comments", THIS).
