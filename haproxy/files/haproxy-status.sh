{%- from "haproxy/map.jinja" import proxy with context -%}
#!/bin/sh

show_stats() {
  echo 'show stat' | socat 'UNIX-CONNECT:{{ proxy.stats_socket }}' STDIO | awk \
  '
  function fillstr(string, num)
  {
    len=length(string);
    if (len>=num)
    {
      printf("%s",substr(string,1,num));
    }
    else
    {
      printf("%s",string);
      for(i=1; i<=num-len; i++)
      {
        printf(" ");
      }
    }
  }

  BEGIN {
    FS = ",";
  };

  {
    if ($1 ~ /^#/) { next };
    if ($1 == "") { next };

    status=sprintf("Status: %s",$18);
    if ($37 != "") {
      status=status sprintf("/%s",$37);
    }
    sessions=sprintf("Sessions: %s",$5);
    rate=sprintf("Rate: %s",$34);

    fillstr($1,25);
    fillstr($2,15);
    fillstr(status,20);
    fillstr(sessions,15);
    fillstr(rate,10);
    printf("\n");
  }
  '
}

show_stats
