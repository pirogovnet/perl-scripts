#!/usr/bin/perl -w

#task - generate radius profile for freeradius 

$j=1;
#$count=71064000;
$count=71032000;

if (open (FH,">l2tp-64k-dqp-lns-noipv4-norse.users")) {
        for($i=71000001;$i<=$count;$i++) {
            

if ($i <71008001) {$j=2;}
if ($i>= 71008001 && $i <71016001) {$j=2;}
if ($i>= 71016001 && $i <71024001) {$j=6;}
if ($i>= 71024001 && $i <71032001) {$j=6;}
if ($i>= 71032001 && $i <71040001) {$j=6;}
if ($i>= 71040001 && $i <71048001) {$j=6;}
if ($i>= 71048001 && $i <71056001) {$j=6;}
if ($i>= 71056001 && $i <=$count)  {$j=6;}



print FH "
$i\@l2tp\.net Cleartext-Password \:\= \"1234\"
        Service-Type = Framed-User,
        Framed-Protocol = PPP,
#        Tunnel-Type = L2TP,
#        Tunnel-Medium-Type = IPv4,
#        Tunnel-Server-Endpoint = 30.1.$j.2,
#        Tunnel-Server-Endpoint = 12.12.35.$j,
#        Tunnel-Client-Endpoint = 168.95.98.35,
#        Tunnel-Function = LAC-Only,
#        Tunnel-Password = redback,
        Framed-Pool = \"pool-1\",
#        Subscriber-Profile-Name = \"sub-dhcpv6pd\",
        Acct-Interim-Interval = \"86400\",
        Class = \"HiNetCL\:HN\=$i FT\=x PT\=0 DR\=12288\/3072\",
#        Framed-IPv6-Pool \= \"pool1\-v6\",
#        Dynamic-QoS-Param \= \"pwfq-circuit-rate-max 1024 parent\",
#        Dynamic-QoS-Param \+\= \"pwfq-circuit-weight 110 parent\",
#        Dynamic-QoS-Param \+\= \"police-circuit-rate rate-absolute 1024 parent\",
#        Dynamic-QoS-Param \+\= \"police-circuit-burst 384000 parent\",
###	Qos-Policing-Profile-Name = \"POLICING\",
###	Qos-Metering-Profile-Name = \"METERING\",
###     Service-Name:1 += \"Inet-Unlim-DayNight\",
###        Service-Action:1 += 1,
###        Service-Parameter:1 += \"DayInRate=1024 DayInBurst=55533 DayOutRate=1024 DayOutBurst=55533 NightInRate=1024 NightInBurst=77733 NightOutRate=1024 NightOutBurst=77733 InterimTime=900\",
        Port-Limit = 5,
        Filter-Id = out:SPAM,
        Filter-Id += in:SPAM,
        Context-Name = hinet1,
"
        }
        close FH;
} else {
        print "failed";
}

