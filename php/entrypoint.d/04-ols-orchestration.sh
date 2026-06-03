#!/bin/bash
# 04-ols-orchestration.sh: OpenLiteSpeed VHost and Template configuration

# 1. Dynamic OpenLiteSpeed Global Tuning
mkdir -p /usr/local/lsws/conf/templates/
mkdir -p /usr/local/lsws/conf/vhosts/localhost/

# Set a safety fallback for the admin password if not provided via ENV
# This is done at runtime, so it doesn't leak into Docker image layers.
OLS_PASSWORD=${OLS_PASSWORD:-admin123}
/usr/local/lsws/admin/misc/admpass.sh "$OLS_PASSWORD" <<EOF
admin
$OLS_PASSWORD
$OLS_PASSWORD
EOF

# 1. Global Performance Tuning (Clean up and Force 1 Worker)
echo "Applying Global Performance Tuning..."
# Remove any existing directives to avoid duplicates on container restart
sed -i '/workerProcesses/d' /usr/local/lsws/conf/httpd_config.conf
sed -i '/useIpInProxyHeader/d' /usr/local/lsws/conf/httpd_config.conf
# Insert global directives at the top of the file
sed -i '1iworkerProcesses 1' /usr/local/lsws/conf/httpd_config.conf
sed -i '1iuseIpInProxyHeader 1' /usr/local/lsws/conf/httpd_config.conf

# 2. Sync Global PHP Engine Limits
echo "Syncing global PHP limits to ${PHP_MAX_CONNS:-15}..."
sed -i "s/\(maxConns\)[[:space:]]\+[0-9]\+/\1                        ${PHP_MAX_CONNS:-15}/g" /usr/local/lsws/conf/httpd_config.conf
sed -i "s/PHP_LSAPI_CHILDREN=[0-9]\+/PHP_LSAPI_CHILDREN=${PHP_MAX_CONNS:-15}/g" /usr/local/lsws/conf/httpd_config.conf

echo "Tuning applied successfully."

# 3. Generate Virtual Host Configuration (vhconf.conf)
echo "Generating OpenLiteSpeed VHost configuration..."
cat <<EOF > /usr/local/lsws/conf/vhosts/localhost/vhconf.conf
docRoot                   /var/www/html
index  {
  useServer               0
  indexFiles              index.php, index.html, index.htm
}

accessControl  {
  allow                   *
}

# Per-Client Throttling (Brute Force Protection)
perClientConnLimit  {
  staticReqLimit          10000
  dynamicReqLimit         10000
  outBandwidth            0
  inBandwidth             0
  softLimit               10000
  hardLimit               10000
  gracePeriod             15
  banPeriod               300
}

# PHP Engine Configuration (Low-RAM Tuning)
scripthttpConfig  {
  libPath                 modules/lsapi.so
  maxConn                 ${PHP_MAX_CONNS:-15}
  env                     LSAPI_MAX_REQS=500
  env                     LSAPI_MAX_IDLE=60
  env                     PHP_LSAPI_CHILDREN=${PHP_MAX_CONNS:-15}
  env                     LSAPI_AVOID_FORK=200M
}

# Compression Settings
gzip  {
  enable                  ${GZIP_ENABLE:-1}
  compressibleTypes       default
}

brotli  {
  enable                  ${BROTLI_ENABLE:-1}
}
EOF

# 3. Generate Docker Template (docker.conf)
# This is the master template used for all Dokploy deployments
echo "Generating OpenLiteSpeed Template configuration..."
cat <<'EOF' > /usr/local/lsws/conf/templates/docker.conf
allowSymbolLink           1
enableScript              1
restrained                0
setUIDMode                2
vhRoot                    /var/www/html/
configFile                $SERVER_ROOT/conf/vhosts/$VH_NAME/vhconf.conf

virtualHostConfig  {
  docRoot                 $VH_ROOT
  enableGzip              1

  errorlog  {
    useServer             1
  }

  accesslog $SERVER_ROOT/logs/$VH_NAME.access.log {
    useServer             0
    rollingSize           10M
    keepDays              7
    compressArchive       1
  }

  index  {
    useServer             0
    indexFiles            index.html, index.htm, index.php
    autoIndex             0
    autoIndexURI          /_autoindex/default.php
  }

  expires  {
    enableExpires         1
  }

  accessControl  {
    allow                 *
  }

  context / {
    location              $DOC_ROOT/
    allowBrowse           1

    rewrite  {
      enable              1
      inherit             1
      RewriteFile .htaccess
    }
  }

  rewrite  {
    enable                1
    autoLoadHtaccess      1    
    logLevel              0
  }

  vhssl  {
    keyFile               /root/.acme.sh/certs/$VH_NAME_ecc/$VH_NAME.key
    certFile              /root/.acme.sh/certs/$VH_NAME_ecc/fullchain.cer
    certChain             1
  }

  module lscache {
    lsapi_cache_enabled   1
  }
}
EOF

# 4. Final Polish: Apply dynamic compression to the Template
sed -i "/enableGzip/d" /usr/local/lsws/conf/templates/docker.conf
sed -i "/docRoot/a \  enableGzip              ${GZIP_ENABLE:-1}\n  enableBrotli            ${BROTLI_ENABLE:-1}" /usr/local/lsws/conf/templates/docker.conf

echo "LiteSpeed orchestration complete."
