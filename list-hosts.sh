#!/bin/bash


echo
echo 'arp-scan'
arp-scan -l | cut -s -f 1,2 | sort -n | while read ipaddr macaddr
do
        #echo -e "$macaddr\t$ipaddr\t$(resolveip $ipaddr 2>/dev/null | sed 's/.*is //' )"
        echo -e "$macaddr\t$ipaddr\t$(host $ipaddr 2>/dev/null | sed -r -e 's/.*(\spointer|not found)\s*//' | tr '\n' ' ')"
done


echo
echo 'nmap -sP'
nmap -sP 192.168.x.x/24 | while read a
do
        ((++c))

        if test $c -le 2
        then
                continue
        fi

        #echo "$c:$a"

        if echo "$a" | egrep -q "^Nmap scan report"
        then
                p1="$(echo "$a" | cut -d' ' -f5-6 | sed 's/[()]//g')"
        fi

        if echo "$a" | egrep -q "^MAC Addr"
        then
                p2="$(echo "$a" | cut -d' ' -f3-)"
        fi

        if test -n "$p1" -a -n "$p2"
        then
                echo -e "${p2%% *}\t${p1#* }\t${p1% *} ${p2#* }"
                unset p1 p2
                #echo
        fi
done
