#!/usr/bin/perl

my $global_config = "/CAMAXESS/global.conf";
my $global_params = { };

sub GetParams 
{
  my $config = shift;
  my $delim  = shift || '=';
  my $params = { };

  open(CONF,$config) || die "$config: $!\n";
  foreach (grep(!/^#/,<CONF>))
  {
      tr/\x22\x27\x0a\x0d//d;
      my($key,$value) = split /$delim/;
      $params->{$key} = $value;
  }
  close(CONF);
return $params;
}

sub _msg
{
   my $msg = shift;
   my $inf = shift || "inf";
   if ($inf eq "err")
   { 
     print STDERR "Error: ".$msg."\n";
     exit;
   }
   else
   {
     print "Info: ".$msg."\n";
   }
}

sub SrcStart
{
   my $tagname   = shift;
   my $srcurl    = shift;
   my $srcmux    = shift;

   if ( ProcessCheck($tagname."_SRC") )
   {
     _msg($tagname."_SRC already started");
   }
   else
   {
      my $src_cmd = "nohup ".$global_params->{'vlc_cmd'}.
              " --meta-description=".$tagname."_SRC ".$global_params->{'vlc_src_extra_opts'}.
              " --no-rtsp-tcp rtsp://".$srcurl." --rtsp-caching=".$global_params->{'vlc_src_rtsp_caching'}.
              " --no-sout-audio --sout".
              " '#std{access=".$global_params->{'vlc_src_access'}.",dst=".$srcmux.",mux=".$global_params->{'vlc_src_mux'}."}'".
              " >> ".$global_params->{'vlc_logs'}."/".$tagname."_src.log 2>&1 &"."\n";
     
     `su -c "$src_cmd" $global_params->{'vlc_user'}`;

     sleep 2;
     _msg($tagname."_SRC started"); 
   }
}

sub StreamerStart
{
   my $tagname   = shift;
   my $srcmux    = shift;
   my $dststream = shift;

   if ( ProcessCheck($tagname."_STREAM") )
   {
     _msg($tagname."_STREAM already started");
   }
   else
   {
      my $stream_cmd = "nohup ".$global_params->{'vlc_cmd'}.
          " --meta-description=".$tagname."_STREAM ".$global_params->{'vlc_streamer_extra_opts'}.
          " http://".$srcmux." --loop --http-caching=".$global_params->{'vlc_streamer_http_caching'}.
          " --sout '#transcode{vcodec=".$global_params->{'vlc_streamer_vcodec'}.",vb=".$global_params->{'vlc_streamer_vbit'}.
    	  "}:std{access=".$global_params->{'vlc_streamer_access'}.",dst=".$dststream.",mux=".$global_params->{'vlc_streamer_mux'}.
	  "}'"." >> ".$global_params->{'vlc_logs'}."/".$tagname."_streamer.log 2>&1 &"."\n"; 
      `su -c "$stream_cmd" $global_params->{'vlc_user'}`;

      sleep 2;
      _msg($tagname."_STREAM started");
   }
}

sub ProcessCheck
{
   my $tagname = shift;
   my $pid = `ps ax | grep -v grep | grep $tagname | awk '{print \$1}'`; 
   chomp $pid;
   return $pid;
}

sub TestPageGen
{

  my $tagname   = shift;
  my $dststream = shift;

my $campage =<<EOF;

   <script type="text/javascript" src="swfobject.js"></script>
   <div id="mplayer">this will be replaced by the SWF.</div>
   <script type="text/javascript">
       var so = new SWFObject('player.swf','player','459','375','9');
       so.addParam('allowfullscreen','true');
       so.addParam('flashvars','start=1&amp;repeat=always&amp;file=http://$global_params->{'vlc_streamer_ip'}$dststream&amp;bufferlength=0&amp;autostart=true&amp;displayclick=none&amp;mute=false');
       so.write('mplayer');
   </script>

EOF

  open WWW, ">".$global_params->{'vlc_web_dir'}."/".$tagname.".htm";

   print WWW $campage;

  close WWW;
  
  _msg("URL: http://".$global_params->{'vlc_web_srv'}."/".$tagname.".htm");

}


$global_params = GetParams($global_config,' = ');

_msg("VLC not found!","err") if ( ! -e $global_params->{'vlc_cmd'} ); 

open CAM_CONF, $global_params->{'vlc_camlist'};
foreach my $cam (grep(!/^#|^$/,<CAM_CONF>))
{

    chomp $cam;
    my ($tagname, $srcurl, $srcmux, $dststream) = split (/\t+| +/, $cam);
              
    SrcStart($tagname, $srcurl, $srcmux);

    StreamerStart($tagname, $srcmux, $dststream);

    TestPageGen($tagname,$dststream);

}
close CAM_CONF;


