-module(zforum_topic_controller, [Req]).
-compile(export_all).



add('GET', []) ->
	ok
;
	
add('POST', []) ->
	Name = Req:post_param("name"),
	NewTopic = topic:new(id, Name),
	{ok, SavedTopic} = NewTopic:save(),	
	{redirect, [{action, "topic"}]}
.


list('GET', []) ->
	Topics  = boss_db:find(topic, []),
	{ok, [{topics, Topics}]}
.

topic('GET', []) ->
	TopicId = Req:query_param("topic"),
	Topic  = boss_db:find_first(topic, []),
	Comments  = boss_db:find(comment, [topic_id, equals, TopicId]),
	{ok, [{comments, Comments}, {topic, Topic}]}
.

comment('POST', []) ->
	TopicId = Req:post_param("topic-id"),
	Comment = Req:post_param("comment"),
	NewComment = comment:new(id, Comment, TopicId),
	{ok, SavedComment} = NewComment:save(),
	{json, []}
	% {redirect, [{action, "list"}]}

.


pull('GET', [LastTimestamp]) ->
	TopicId = Req:query_param("topic_id"),
	{ok, Timestamp, Comments} = boss_mq:pull(
		TopicId,
		list_to_integer(LastTimestamp)
	),
	{json, [{timestamp, Timestamp}, {comments, Comments}]}
.

% live('GET', []) ->
% 	Greetings = boss_db:find(greeting, []),
% 	Timestamp = boss_mq:now("new-greetings"),
% 	{ok, [{greetings, Greetings}, {timestamp, Timestamp}]}
% .