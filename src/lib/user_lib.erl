%% file: src/lib/user_lib.erl
-module(user_lib).
-compile(export_all).

%% On success, returns {ok, Hash}.
hash_password(Password)->
    {ok, Salt} = bcrypt:gen_salt(),
    bcrypt:hashpw(Password, Salt).

%% Tests for presence and validity of session.
%% Forces login on failure.
require_login(Req) ->
    case Req:cookie("user_id") of
        undefined -> {redirect, "/user/login"}; 
        Id ->
            case boss_db:find(Id) of
                undefined -> {redirect, "/user/login"};
                ForumUser ->
                    case ForumUser:session_identifier() =:= Req:cookie("session_id") of
                        false -> {redirect, "/user/login"};
                        true -> {ok, ForumUser}
                    end
            end
     end.

compare_password(PasswordAttempt, Password) ->
    {ok, Password} =:= bcrypt:hashpw(PasswordAttempt, Password)
.