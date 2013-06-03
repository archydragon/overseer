Overseer
========

Like UNIX 'watch' for your browser.

Requirements
------------

For building and running:
* **Erlang R16B**
* **Rebar**

Type ``make all`` to build Overseer and ``make run`` or ``./overseer.sh`` to run it.

For web access:
* Any modern **web browser** with enabled JavaScript and Websockets (tested in Firefox 20.0.1 (*works fine*), Chromium 27 (*works fine*), Opera 12.15 (*found at least two bugs, use at your own risc*))

Web application can be accessed by address [http://localhost:6600/](http://localhost:6600/).

Configuration
-------------

The file ``commands.cfg`` contains entries in format ``{"Shown name", {"shell_command", 10}}.`` where *"Shown name"* means menu entry on web page, *"shell_command"* — the command which result you need watch, and *10* — page update interval (in seconds).

In case you want to change HTTP port, modify ``src/overseer_app.src`` and re-compile.

License
-------

[WTFPL](http://sam.zoy.org/wtfpl/)

![Screenshot](https://raw.github.com/Mendor/overseer/master/screen.png)
