-module(post_comments_controller, [Req]).
-compile(export_all).

index('GET', []) ->
  Comments = boss_db:find(comment, []),
  Timestamp = boss_mq:now("new-comments"),
  {ok, [{comments, Comments}, {timestamp, Timestamp}]}.

pull('GET', [LastTimestamp]) ->
  {ok, Timestamp, Comments} = boss_mq:pull("new-comments", list_to_integer(LastTimestamp)),
  {json, [{timestamp, Timestamp}, {comments, Comments}]}.

create('GET', []) ->
  ok;
create('POST', []) ->
  Comment = comment:new(id, Req:post_param("title"), Req:post_param("content")),
  case Comment:save() of
    {ok, SavedComment} ->
      {redirect, [{action, "index"}]};
    {error, ErrorList} ->
      {ok, [{errors, ErrorList}, {new_msg, Comment}]}
  end.

delete('GET', [Id]) ->
  boss_db:delete(Id),
  {redirect, [{action, "index"}]}.

edit('GET', [Id])->
  Comment = boss_db:find(Id),
  {ok, [{comment, Comment}]};
edit('POST', [Id]) ->
  Comment = boss_db:find(Id),
  NewComment = Comment:set([{title, Req:post_param("title")}, {content, Req:post_param("content")}]),
  case NewComment:save() of
    {ok, SavedComment}->
      {redirect, [{action, "index"}]};
    {error, ErrorList} ->
      {ok, [{errors, ErrorList}, {new_msg, Comment}]}
  end.
