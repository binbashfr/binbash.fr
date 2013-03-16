backend default {
        .host = "127.0.0.1";
        .port = "8888";
}

sub vcl_deliver {
        if (obj.hits > 0) {
                set resp.http.X-Cache = "HIT";
        } else {
                set resp.http.X-Cache = "MISS";
        }
}

sub vcl_recv {
        if (req.url ~ "(Packages\.gz|Packages\.bz2|Release|Translation-en\.bz2|\.db.*|Sources\.gz)") {
                return(pass);
        }
        
        if (req.http.Accept-Encoding) {
                if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|iso|exe)$") {
                        # pas de compression pour ces demandes
                        remove req.http.Accept-Encoding;
                } elsif (req.http.Accept-Encoding ~ "gzip") {
                        set req.http.Accept-Encoding = "gzip";
                } elsif (req.http.Accept-Encoding ~ "deflate") {
                        set req.http.Accept-Encoding = "deflate";
                } else {
                        # unkown algorithm
                        remove req.http.Accept-Encoding;
                }
        }
        
        if (req.http.user-agent ~ "MSIE") {
                set req.http.user-agent = "msie";
        } else {
                set req.http.user-agent = "firefox";
        }
}

sub vcl_fetch {
        if (req.url ~ "\.(deb|udeb|rpm|xz|gz|bz2|cvd|iso|exe|tar)" && req.url !~ "(Packages\.gz|Packages\.bz2|Release|Translation-en\.bz2|\.db.*|Sources\.gz)") {
                set beresp.do_stream = true;
                set beresp.ttl = 3d;
        }
} 
