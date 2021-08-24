#!/bin/bash

tplink_router_ip=''
tplink_router_user=''
tplink_router_pass_md5=''
#
# use the following command to type the password and get
# the md5 hash to use as value for tplink_router_pass_md5
# read -s zxcv && echo -n $zxcv | md5sum - && unset zxcv
#
# or comment the tplink_router_pass_md5 above, uncomment
# 2 lines bellow and define plain text router's password 
#
#tplink_router_pass_txt=''
#tplink_router_pass_md5=$(echo -n "$tplink_router_pass_txt" | /usr/bin/md5sum - | /usr/bin/cut -c 1-32)

# -----------------------------------------------------------------------------------------------------
# end of setup
# -----------------------------------------------------------------------------------------------------



tplink_router_base64_user_passmd5=$(echo -n "$tplink_router_user:$tplink_router_pass_md5" | /usr/bin/base64)

#tplink_router_authorization_cookie_content=$(echo -n "Basic $tplink_router_base64_user_passmd5" | /bin/sed -f url_escape.sed)
#tplink_router_cookie_content_for_send="Authorization=$tplink_router_authorization_cookie_content"
#
# a implementação acima precisa de um arquivo adicional, o 'url_escape.sed'
# já a implementação a seguir resolve internamente a questão de codificar o URL
#
tplink_router_authorization_cookie_content="Basic $tplink_router_base64_user_passmd5"
tplink_router_cookie_content_for_send="Authorization="
#
# em https://stackoverflow.com/questions/296536/urlencode-from-a-bash-script/10660730#10660730
# tem uma ótima discussãos de como implementar o 'url_encoding' em bash script,  mas como aqui
# deseja-se codificar sempre e somente o texto 'Basic ' e um string base64, que é limitado ao
# conjunto de caracteres [a-zA-a0-9+/=], então basta se preocupar em codificar somente o ' '
# e o sub-conjunto [+/=] do base64
#
# ' ' : %20
#  +  : %2B
#  /  : %2F
#  =  : %3D
#
for (( i=0 ; i < ${#tplink_router_authorization_cookie_content} ; i++ ))
do
        char="${tplink_router_authorization_cookie_content:$i:1}"

        case "$char"
        in
                #( [[:space:]+/=] )
                #       printf -v encoded '%%%02X' "'$encode"
                #       ;;
                ( ' ' ) encoded='%20' ;;
                ( '+' ) encoded='%2B' ;;
                ( '/' ) encoded='%2F' ;;
                ( '=' ) encoded='%3D' ;;
                (  *  ) encoded=$char
        esac

        tplink_router_cookie_content_for_send+="$encoded"
done

unset i char encoded

echo
echo "tplink_router_user                    : $tplink_router_user"
echo "tplink_router_pass_md5                : $tplink_router_pass_md5"
echo "tplink_router_base64_user_passmd5     : $tplink_router_base64_user_passmd5"
echo "tplink_router_cookie_content_for_send : $tplink_router_cookie_content_for_send"

#exit 99

echo



echo "# Trying to connect : http://$tplink_router_ip/"

tplink_router_check=$(/usr/bin/wget \
--no-verbose \
--output-document=/dev/null \
"http://$tplink_router_ip/" 2>&1 )

if test $? -ne 0
then
        echo "- connection failed:"
        echo "$tplink_router_check"
        echo "! Execution failed."
        exit 1
fi

#exit 99



echo "# Requesting  login : http://$tplink_router_ip/userRpm/LoginRpm.htm?Save=Save"

# obs: testado e funciona!   é possível mandar o cookie de autorização
#      sem estar no formato url-encoded... basta utilizar este header:
#
#--header="Cookie: Authorization=Basic $tplink_router_base64_user_passmd5" \
#
tplink_router_login_response=$(/usr/bin/wget \
--quiet \
--output-document=- \
--referer="http://$tplink_router_ip/" \
--header="Cookie: $tplink_router_cookie_content_for_send" \
"http://$tplink_router_ip/userRpm/LoginRpm.htm?Save=Save" )

#echo "tplink_router_login_response=$tplink_router_login_response"

tplink_router_url_dynamic_key=$(echo $tplink_router_login_response | /bin/sed -r -e "s/.*http:\/\/[^/]+\/([^/]+)\/userRpm.*|.*/\1/gi")
# o sintax highlighter do mcedit buga na expressão acima... este comentário termina com aspas duplas e dá uma resolvida no bug "

if test -z "$tplink_router_url_dynamic_key"
then
        echo "- URL's dynamic key not found in login response:"
        echo "$tplink_router_login_response"
        echo "! Execution failed."
        exit 2
fi

echo "# URL's dynamic key : $tplink_router_url_dynamic_key"

#exit 99

sleep 2



echo "# Requesting reboot : http://$tplink_router_ip/$tplink_router_url_dynamic_key/userRpm/SysRebootRpm.htm?Reboot=Reboot"

while read tplink_reboot_response_line
do
        #echo "tplink_reboot_response_line:$tplink_reboot_response_line"

        if echo $tplink_reboot_response_line | /bin/egrep -qi 'id\s*=\s"t_title".*Restart'
        then
                echo '- Device is restarting... Good bye =)'
                exit 0
        fi
done < <(
/usr/bin/wget \
--quiet \
--output-document=- \
--referer="http://$tplink_router_ip/$tplink_router_url_dynamic_key/userRpm/SysRebootRpm.htm" \
--header="Cookie: $tplink_router_cookie_content_for_send" \
"http://$tplink_router_ip/$tplink_router_url_dynamic_key/userRpm/SysRebootRpm.htm?Reboot=Reboot"
)

echo "- Something went wrong, or just the router restart page was not identified."

exit 3
