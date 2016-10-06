#!/usr/local/bin/perl 

# test DNS availability  with dig
#example
#./dig.pl google.com  2
#testing DNS for google.com  2 times
#Request 0   Query time: 31  msec
#Request 1   Query time: 12  msec
#Final Results:
#Total Requests=2         min_time=12     max_time=31     avg_time=21.5   timeouts=0  

$domain_name="google.com"; 
$retries=100;

$min_time=10000;
$max_time=0;
$avg_time=0;
$timeouts=0; 


if ($ARGV[0]) {

    $domain_name = $ARGV[0];
 
}  

if ($ARGV[1]) {
    $retries = $ARGV[1];
} 


print "testing DNS for $domain_name  $retries times\n";
 
for ( $i=0; $i<$retries; $i++) 

{

#--- close output from system command 
        open my $oldout, ">&STDOUT";  # "dup" the stdout filehandle
        close STDOUT;
#       warn "\n==STDOUT closed:\n";


        $dns_result=`/usr/local/bin/dig $domain_name`; 

        open STDOUT, '>&', $oldout;  # restore the dup'ed filehandle to STDOUT
#       warn "\n==STDOUT reopened:\n";

#  print "attempt $i\n dns_result:\n------\n$dns_result\n---------\n"; 
  $dns_result =~ s/\R//g;   #remove \n
#print "attempt $i\n dns_result:\n------\n$dns_result\n---------\n"; 


if ( $dns_result=~/time\:\s(\d+)\smsec/ ) 
 
   {
     print  "Request $i   Query time: $1  msec\n"; 
      $avg_time+=$1;
      
      if ( $min_time>$1 ) { $min_time=$1;}
      if ($max_time < $1) { $max_time=$1;}
   } 

else { $timeouts+=1; } 



} 

$avg_time=$avg_time/$retries;

print "Final Results:\n";
print "Total Requests=$retries\t min_time=$min_time\t max_time=$max_time\t avg_time=$avg_time\t timeouts=$timeouts  \n"; 

