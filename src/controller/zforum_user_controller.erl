-module(zforum_user_controller, [Req]).
-compile(export_all).


login('GET', []) ->
    {ok, [{redirect, Req:header(referer)}]};

login('POST', []) ->
    Username = Req:post_param("username"),
    case boss_db:find(forum_user, [{username, Username}], [{limit, 1}]) of
        [ForumUser] ->
            case ForumUser:check_password(Req:post_param("password")) of
                true ->
                   {redirect, proplists:get_value("redirect",
                       Req:post_params(), "/topic/home"), ForumUser:set_login_cookies()};
					% {redirect, [{action, "home"}]};
                false ->
                    {ok, [{error, "Password mismatch"}]}
            end;
        [] ->
            {ok, [{error, "ForumUser not found"}]}
    end
.


register('GET', []) ->
    {ok, []}
;

register('POST', []) ->
    Email = Req:post_param("email"),
    Username = Req:post_param("username"),
    {ok, Password} = user_lib:hash_password(Req:post_param("password")),
    ForumUser = forum_user:new(id, Email, Username, Password),
    Result = ForumUser:save(),
    {redirect, [{action, "login"}]}
.