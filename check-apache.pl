  #!/usr/local/bin/perl
  # script: localSOS
  
  use constant PIDFILE  => '/usr/local/apache/var/run/httpd.pid';
  $MAIL                 =  '/usr/sbin/sendmail';
  $MAIL_FLAGS           =  '-t -oi';
  $WEBMASTER            =  'webmaster';
  
  open (PID,PIDFILE) || die PIDFILE,": $!\n";
  $pid = <PID>;  close PID;
  kill 0,$pid || sos();
  
  sub sos {
    open (MAIL,"| $MAIL $MAIL_FLAGS") || die "mail: $!";
    my $date = localtime();
    print MAIL <<END;
  To: $WEBMASTER
  From: The Watchful Web Server Monitor <nobody>
  Subject: Web server is down
  
  I tried to call the Web server at $date but there was
  no answer.
  
  Respectfully yours,
  
  The Watchful Web Server Monitor   
  END
    close MAIL;
  }
