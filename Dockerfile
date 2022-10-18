#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:bullseye

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# runtime dependencies
RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                libbluetooth-dev \
                tk-dev \
                uuid-dev \
        ; \
        rm -rf /var/lib/apt/lists/*

ENV GPG_KEY A035C8C19219BA821ECEA86B64E628F8D684696D
ENV PYTHON_VERSION 3.10.8

RUN set -eux; \
        \
        wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"; \
        wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc"; \
        GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
        gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$GPG_KEY"; \
        gpg --batch --verify python.tar.xz.asc python.tar.xz; \
        command -v gpgconf > /dev/null && gpgconf --kill all || :; \
        rm -rf "$GNUPGHOME" python.tar.xz.asc; \
        mkdir -p /usr/src/python; \
        tar --extract --directory /usr/src/python --strip-components=1 --file python.tar.xz; \
        rm python.tar.xz; \
        \
        cd /usr/src/python; \
        gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
        ./configure \
                --build="$gnuArch" \
                --enable-loadable-sqlite-extensions \
                --enable-optimizations \
                --enable-option-checking=fatal \
                --enable-shared \
                --with-lto \
                --with-system-expat \
                --without-ensurepip \
        ; \
        nproc="$(nproc)"; \
        make -j "$nproc" \
        ; \
        make install; \
        \
# enable GDB to load debugging data: https://github.com/docker-library/python/pull/701
        bin="$(readlink -ve /usr/local/bin/python3)"; \
        dir="$(dirname "$bin")"; \
        mkdir -p "/usr/share/gdb/auto-load/$dir"; \
        cp -vL Tools/gdb/libpython.py "/usr/share/gdb/auto-load/$bin-gdb.py"; \
        \
        cd /; \
        rm -rf /usr/src/python; \
        \
        find /usr/local -depth \
                \( \
                        \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
                        -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \
                \) -exec rm -rf '{}' + \
        ; \
        \
        ldconfig; \
        \
        python3 --version

# make some useful symlinks that are expected to exist ("/usr/local/bin/python" and friends)
RUN set -eux; \
        for src in idle3 pydoc3 python3 python3-config; do \
                dst="$(echo "$src" | tr -d 3)"; \
                [ -s "/usr/local/bin/$src" ]; \
                [ ! -e "/usr/local/bin/$dst" ]; \
                ln -svT "$src" "/usr/local/bin/$dst"; \
        done

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 22.2.2
# https://github.com/docker-library/python/issues/365
ENV PYTHON_SETUPTOOLS_VERSION 63.2.0
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/5eaac1050023df1f5c98b173b248c260023f2278/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256 5aefe6ade911d997af080b315ebcb7f882212d070465df544e1175ac2be519b4

RUN set -eux; \
        \
        wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
        echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum -c -; \
        \
        export PYTHONDONTWRITEBYTECODE=1; \
        \
        python get-pip.py \
                --disable-pip-version-check \
                --no-cache-dir \
                --no-compile \
                "pip==$PYTHON_PIP_VERSION" \
                "setuptools==$PYTHON_SETUPTOOLS_VERSION" \
        ; \
        rm -f get-pip.py; \
        \
        pip --version


        RUN pip install autopep8==1.6.0
        RUN pip install bcrypt==3.2.0
        RUN pip install beautifulsoup4==4.10.0
        RUN pip install bs4==0.0.1
        RUN pip install certifi==2021.10.8
        RUN pip install cffi==1.15.0
        RUN pip install chardet==4.0.0
        RUN pip install charset-normalizer==2.0.12
        RUN pip install click==8.0.4
        RUN pip install configparser==5.2.0
        RUN pip install cryptography==36.0.2
        RUN pip install dnspython==2.2.1
        RUN pip install Exscript==2.6.3
        RUN pip install Flask==2.0.3
        RUN pip install future==0.18.2
        RUN pip install gevent==21.12.0
        RUN pip install greenlet==1.1.2
        RUN pip install idna==3.3
        RUN pip install itsdangerous==2.1.1
        RUN pip install Jinja2==3.0.3
        RUN pip install ldap3==2.9.1
        RUN pip install ldapdomaindump==0.9.3
        RUN pip install MarkupSafe==2.1.1
        RUN pip install parallel-ssh==2.10.0
        RUN pip install paramiko==2.10.2
        RUN pip install pip==19.3.1
        RUN pip install pssh==2.3.1
        RUN pip install pyasn1==0.4.8
        RUN pip install pycodestyle==2.8.0
        RUN pip install pycparser==2.21
        RUN pip install pycryptodomex==3.14.1
        RUN pip install PyFortiAPI==0.3.0
        RUN pip install PyNaCl==1.5.0
        RUN pip install pyOpenSSL==22.0.0
        RUN pip install pytz==2021.3
        RUN pip install requests==2.27.1
        RUN pip install setuptools==41.6.0
        RUN pip install six==1.16.0
        RUN pip install soupsieve==2.3.1
        RUN pip install ssh-python==0.10.0
        RUN pip install ssh2
        RUN pip install toml
        RUN pip install urllib3
        RUN pip install Werkzeug
        RUN pip install wheel
        RUN pip install zope.event
        RUN pip install zope.interface
        RUN pip install impacket
        RUN pip install cp-mgmt-api-sdk
        RUN pip install pyflakes
        RUN mkdir /opt/PipPackages
        ENV PYTHONPATH "${PYTHONPATH}:/opt/PipPackages"
