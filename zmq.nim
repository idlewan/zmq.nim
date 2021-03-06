# Nimrod wrapper of 0mq
# Generated by c2nim with modifications and enhancement
# from Andreas Rumpf, Erwan Ameil
# Generated from zmq version 4.0.4
# Original licence follows:

#
#    Copyright (c) 2007-2013 Contributors as noted in zeromq's AUTHORS file
#
#    This file is part of 0MQ.
#
#    0MQ is free software; you can redistribute it and/or modify it under
#    the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    0MQ is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

## Nimrod 0mq wrapper. This file contains the low level C wrappers as well as
## some higher level constructs. The higher level constructs are easily
## recognizable because they are the only ones that have documentation.
##
## Example of a client:
## 
## .. code-block:: nimrod
##   import zmq
##   
##   var requester = zmq.connect("tcp://localhost:5555")
##   echo("Connecting...")
##   for i in 0..10:
##     echo("Sending hello... (" & $i & ")")
##     send(requester, "Hello")
##     var reply = receive(requester)
##     echo("Received: ", reply)
##   close(requester)
##
## Example of a server:
##
## .. code-block:: nimrod
##   
##   import zmq
##   var responder = zmq.listen("tcp://*:5555")
##   while True:
##     var request = receive(responder)
##     echo("Received: ", request)
##     send(responder, "World")
##   close(responder)


{.deadCodeElim: on.}
when defined(windows):
  const 
    zmqdll* = "zmq.dll"
elif defined(macosx):
  const 
    zmqdll* = "libzmq.dylib"
else:
  const 
    zmqdll* = "libzmq.so"


#  Version macros for compile-time API version detection                     
const 
  ZMQ_VERSION_MAJOR* = 4
  ZMQ_VERSION_MINOR* = 0
  ZMQ_VERSION_PATCH* = 4
template ZMQ_MAKE_VERSION*(major, minor, patch: expr): expr =
  ((major) * 10000 + (minor) * 100 + (patch))

const 
  ZMQ_VERSION* = ZMQ_MAKE_VERSION(ZMQ_VERSION_MAJOR, ZMQ_VERSION_MINOR,
                                    ZMQ_VERSION_PATCH)

#****************************************************************************
#  0MQ errors.                                                               
#****************************************************************************
#  A number random enough not to collide with different errno ranges on      
#  different OSes. The assumption is that error_t is at least 32-bit type.   
const 
  ZMQ_HAUSNUMERO = 156384712
#  On Windows platform some of the standard POSIX errnos are not defined.    
when not(defined(ENOTSUP)):
  const 
    ENOTSUP* = (ZMQ_HAUSNUMERO + 1)
    EPROTONOSUPPORT* = (ZMQ_HAUSNUMERO + 2)
    ENOBUFS* = (ZMQ_HAUSNUMERO + 3)
    ENETDOWN* = (ZMQ_HAUSNUMERO + 4)
    EADDRINUSE* = (ZMQ_HAUSNUMERO + 5)
    EADDRNOTAVAIL* = (ZMQ_HAUSNUMERO + 6)
    ECONNREFUSED* = (ZMQ_HAUSNUMERO + 7)
    EINPROGRESS* = (ZMQ_HAUSNUMERO + 8)
    ENOTSOCK* = (ZMQ_HAUSNUMERO + 9)
    EMSGSIZE* = (ZMQ_HAUSNUMERO + 10)
    EAFNOSUPPORT* = (ZMQ_HAUSNUMERO + 11)
    ENETUNREACH* = (ZMQ_HAUSNUMERO + 12)
    ECONNABORTED* = (ZMQ_HAUSNUMERO + 13)
    ECONNRESET* = (ZMQ_HAUSNUMERO + 14)
    ENOTCONN* = (ZMQ_HAUSNUMERO + 15)
    ETIMEDOUT* = (ZMQ_HAUSNUMERO + 16)
    EHOSTUNREACH* = (ZMQ_HAUSNUMERO + 17)
    ENETRESET* = (ZMQ_HAUSNUMERO + 18)

#  Native 0MQ error codes.                                                   
const 
  EFSM* = (ZMQ_HAUSNUMERO + 51)
  ENOCOMPATPROTO* = (ZMQ_HAUSNUMERO + 52)
  ETERM* = (ZMQ_HAUSNUMERO + 53)
  EMTHREAD* = (ZMQ_HAUSNUMERO + 54)

#  Run-time API version detection                                            
proc version*(major: var cint, minor: var cint, patch: var cint){.cdecl,
  importc: "zmq_version", dynlib: zmqdll.}

#  This function retrieves the errno as it is known to 0MQ library. The goal 
#  of this function is to make the code 100% portable, including where 0MQ   
#  compiled with certain CRT library (on Windows) is linked to an            
#  application that uses different CRT library.                              
proc errno*(): cint{.cdecl, importc: "zmq_errno", dynlib: zmqdll.}

#  Resolves system errors and 0MQ errors to human-readable string.           
proc strerror*(errnum: cint): cstring {.cdecl, importc: "zmq_strerror",
  dynlib: zmqdll.}

# Socket Types
type
  TSocket {.final, pure.} = object
  PSocket* = ptr TSocket

#****************************************************************************
#  0MQ infrastructure (a.k.a. context) initialisation & termination.         
#****************************************************************************
#  New API                                                                   
#  Context options                                                           
type
  TContext {.final, pure.} = object
  PContext* = ptr TContext
const 
  ZMQ_IO_THREADS* = 1
  ZMQ_MAX_SOCKETS* = 2

type TContextOptions* = enum
  IO_THREADS = 1
  MAX_SOCKETS = 2
  ZMQ_IPV6 = 42

#  Default for new contexts                                                  
const 
  ZMQ_IO_THREADS_DFLT* = 1
  ZMQ_MAX_SOCKETS_DFLT* = 1023

proc ctx_new*(): PContext {.cdecl, importc: "zmq_ctx_new", dynlib: zmqdll.}
proc ctx_term*(context: PContext): cint {.cdecl, importc: "zmq_ctx_term",
  dynlib: zmqdll.}
proc ctx_shutdown*(ctx: PContext): cint {.cdecl, importc: "zmq_ctx_shutdown",
  dynlib: zmqdll.}
proc ctx_set*(context: PContext; option: cint; optval: cint): cint {.cdecl,
  importc: "zmq_ctx_set", dynlib: zmqdll.}
proc ctx_get*(context: PContext; option: cint): cint {.cdecl,
  importc: "zmq_ctx_get", dynlib: zmqdll.}

#  Old (legacy) API                                                          
#proc zmq_init*(io_threads: cint): pointer
#proc zmq_term*(context: pointer): cint
#proc zmq_ctx_destroy*(context: pointer): cint

proc init*(io_threads: cint): PContext {.cdecl, importc: "zmq_init",
  dynlib: zmqdll.}
proc term*(context: PContext): cint {.cdecl, importc: "zmq_term",
                                      dynlib: zmqdll.}
proc ctx_destroy*(context: PContext): cint {.cdecl, importc: "zmq_ctx_destroy",
  dynlib: zmqdll.}


#****************************************************************************
#  0MQ message definition.                                                   
#****************************************************************************
type 
  TMsg* {.pure, final.} = object 
    priv*: array[0..32 - 1, cuchar]
  
  TFreeFn = proc (data, hint: pointer) {.noconv.}

proc msg_init*(msg: var TMsg): cint {.cdecl, importc: "zmq_msg_init",
  dynlib: zmqdll.}
proc msg_init*(msg: var TMsg; size: int): cint {.cdecl,
  importc: "zmq_msg_init_size", dynlib: zmqdll.}
proc msg_init*(msg: var TMsg; data: cstring; size: int;
                        ffn: TFreeFn; hint: pointer): cint {.cdecl,
                        importc: "zmq_msg_init_data", dynlib: zmqdll.}
proc msg_send*(msg: var TMsg; s: PSocket; flags: cint): cint {.cdecl,
  importc: "zmq_msg_send", dynlib: zmqdll.}
proc msg_recv*(msg: var TMsg; s: PSocket; flags: cint): cint {.cdecl,
  importc: "zmq_msg_recv", dynlib: zmqdll.}
proc msg_close*(msg: var TMsg): cint {.cdecl, importc: "zmq_msg_close",
  dynlib: zmqdll.}
proc msg_move*(dest, src: var TMsg): cint {.cdecl,
  importc: "zmq_msg_move", dynlib: zmqdll.}
proc msg_copy*(dest, src: var TMsg): cint {.cdecl,
  importc: "zmq_msg_copy", dynlib: zmqdll.}
proc msg_data*(msg: var TMsg): cstring {.cdecl, importc: "zmq_msg_data",
  dynlib: zmqdll.}
proc msg_size*(msg: var TMsg): int {.cdecl, importc: "zmq_msg_size",
  dynlib: zmqdll.}
proc msg_more*(msg: var TMsg): cint {.cdecl, importc: "zmq_msg_more",
  dynlib: zmqdll.}
proc msg_get*(msg: var TMsg; option: cint): cint {.cdecl, importc: "zmq_msg_get",
  dynlib: zmqdll.}
proc msg_set*(msg: var TMsg; option: cint; optval: cint): cint {.cdecl,
  importc: "zmq_msg_set", dynlib: zmqdll.}

#****************************************************************************
#  0MQ socket definition.                                                    
#****************************************************************************
#  Socket types.                                                             
const 
  ZMQ_PAIR* = 0
  ZMQ_PUB* = 1
  ZMQ_SUB* = 2
  ZMQ_REQ* = 3
  ZMQ_REP* = 4
  ZMQ_DEALER* = 5
  ZMQ_ROUTER* = 6
  ZMQ_PULL* = 7
  ZMQ_PUSH* = 8
  ZMQ_XPUB* = 9
  ZMQ_XSUB* = 10
  ZMQ_STREAM* = 11

type
  TSocketType* = enum
      PAIR = 0,
      PUB = 1,
      SUB = 2,
      REQ = 3,
      REP = 4,
      DEALER = 5,
      ROUTER = 6,
      PULL = 7,
      PUSH = 8,
      XPUB = 9,
      XSUB = 10,
      STREAM = 11

#  Deprecated aliases                                                        
const 
  ZMQ_XREQ* = ZMQ_DEALER
  ZMQ_XREP* = ZMQ_ROUTER
#  Socket options.                                                           
const 
  ZMQ_AFFINITY* = 4
  ZMQ_IDENTITY* = 5
  ZMQ_SUBSCRIBE* = 6
  ZMQ_UNSUBSCRIBE* = 7
  ZMQ_RATE* = 8
  ZMQ_RECOVERY_IVL* = 9
  ZMQ_SNDBUF* = 11
  ZMQ_RCVBUF* = 12
  ZMQ_RCVMORE* = 13
  ZMQ_FD* = 14
  ZMQ_EVENTS* = 15
  #ZMQ_TYPE* = 16
  ZMQ_LINGER* = 17
  ZMQ_RECONNECT_IVL* = 18
  ZMQ_BACKLOG* = 19
  ZMQ_RECONNECT_IVL_MAX* = 21
  ZMQ_MAXMSGSIZE* = 22
  ZMQ_SNDHWM* = 23
  ZMQ_RCVHWM* = 24
  ZMQ_MULTICAST_HOPS* = 25
  ZMQ_RCVTIMEO* = 27
  ZMQ_SNDTIMEO* = 28
  ZMQ_LAST_ENDPOINT* = 32
  ZMQ_ROUTER_MANDATORY* = 33
  ZMQ_TCP_KEEPALIVE* = 34
  ZMQ_TCP_KEEPALIVE_CNT* = 35
  ZMQ_TCP_KEEPALIVE_IDLE* = 36
  ZMQ_TCP_KEEPALIVE_INTVL* = 37
  ZMQ_TCP_ACCEPT_FILTER* = 38
  ZMQ_IMMEDIATE* = 39
  ZMQ_XPUB_VERBOSE* = 40
  ZMQ_ROUTER_RAW* = 41
  #ZMQ_IPV6* = 42
  ZMQ_MECHANISM* = 43
  ZMQ_PLAIN_SERVER* = 44
  ZMQ_PLAIN_USERNAME* = 45
  ZMQ_PLAIN_PASSWORD* = 46
  ZMQ_CURVE_SERVER* = 47
  ZMQ_CURVE_PUBLICKEY* = 48
  ZMQ_CURVE_SECRETKEY* = 49
  ZMQ_CURVE_SERVERKEY* = 50
  ZMQ_PROBE_ROUTER* = 51
  ZMQ_REQ_CORRELATE* = 52
  ZMQ_REQ_RELAXED* = 53
  ZMQ_CONFLATE* = 54
  ZMQ_ZAP_DOMAIN* = 55

type TSockOptions* = enum
  AFFINITY = 4
  IDENTITY = 5
  SUBSCRIBE = 6
  UNSUBSCRIBE = 7
  RATE = 8
  RECOVERY_IVL = 9
  SNDBUF = 11
  RCVBUF = 12
  RCVMORE = 13
  FD = 14
  EVENTS = 15
  ZMQ_TYPE = 16
  LINGER = 17
  RECONNECT_IVL = 18
  BACKLOG = 19
  RECONNECT_IVL_MAX = 21
  MAXMSGSIZE = 22
  SNDHWM = 23
  RCVHWM = 24
  MULTICAST_HOPS = 25
  RCVTIMEO = 27
  SNDTIMEO = 28
  LAST_ENDPOINT = 32
  ROUTER_MANDATORY = 33
  TCP_KEEPALIVE = 34
  TCP_KEEPALIVE_CNT = 35
  TCP_KEEPALIVE_IDLE = 36
  TCP_KEEPALIVE_INTVL = 37
  TCP_ACCEPT_FILTER = 38
  IMMEDIATE = 39
  XPUB_VERBOSE = 40
  ROUTER_RAW = 41
  IPV6 = 42
  MECHANISM = 43
  PLAIN_SERVER = 44
  PLAIN_USERNAME = 45
  PLAIN_PASSWORD = 46
  CURVE_SERVER = 47
  CURVE_PUBLICKEY = 48
  CURVE_SECRETKEY = 49
  CURVE_SERVERKEY = 50
  PROBE_ROUTER = 51
  REQ_CORRELATE = 52
  REQ_RELAXED = 53
  CONFLATE = 54
  ZAP_DOMAIN = 55

#  Message options                                                           
const 
  ZMQ_MORE* = 1
type TMsgOptions = enum
    MORE = 1

#  Send/recv options.                                                        
const 
  ZMQ_DONTWAIT* = 1
  ZMQ_SNDMORE* = 2
type TSendRecvOptions* = enum
  DONTWAIT = 1
  SNDMORE = 2

#  Security mechanisms                                                       
const 
  ZMQ_NULL* = 0
  ZMQ_PLAIN* = 1
  ZMQ_CURVE* = 2
#  Deprecated options and aliases                                            
const 
  ZMQ_IPV4ONLY* = 31
  ZMQ_DELAY_ATTACH_ON_CONNECT* = ZMQ_IMMEDIATE
  ZMQ_NOBLOCK* = ZMQ_DONTWAIT
  ZMQ_FAIL_UNROUTABLE* = ZMQ_ROUTER_MANDATORY
  ZMQ_ROUTER_BEHAVIOR* = ZMQ_ROUTER_MANDATORY

#****************************************************************************
#  0MQ socket events and monitoring                                          
#****************************************************************************
#  Socket transport events (tcp and ipc only)                                
const 
  ZMQ_EVENT_CONNECTED* = 1
  ZMQ_EVENT_CONNECT_DELAYED* = 2
  ZMQ_EVENT_CONNECT_RETRIED* = 4
  ZMQ_EVENT_LISTENING* = 8
  ZMQ_EVENT_BIND_FAILED* = 16
  ZMQ_EVENT_ACCEPTED* = 32
  ZMQ_EVENT_ACCEPT_FAILED* = 64
  ZMQ_EVENT_CLOSED* = 128
  ZMQ_EVENT_CLOSE_FAILED* = 256
  ZMQ_EVENT_DISCONNECTED* = 512
  ZMQ_EVENT_MONITOR_STOPPED* = 1024
  ZMQ_EVENT_ALL* = (ZMQ_EVENT_CONNECTED or ZMQ_EVENT_CONNECT_DELAYED or
      ZMQ_EVENT_CONNECT_RETRIED or ZMQ_EVENT_LISTENING or
      ZMQ_EVENT_BIND_FAILED or ZMQ_EVENT_ACCEPTED or ZMQ_EVENT_ACCEPT_FAILED or
      ZMQ_EVENT_CLOSED or ZMQ_EVENT_CLOSE_FAILED or ZMQ_EVENT_DISCONNECTED or
      ZMQ_EVENT_MONITOR_STOPPED)
#  Socket event data  
type 
  zmq_event_t* {.pure, final.} = object 
    event*: uint16        # id of the event as bitfield
    value*: int32         # value is either error code, fd or reconnect interval
  
proc socket*(context: PContext, theType: cint): PSocket {.cdecl,
      importc: "zmq_socket", dynlib: zmqdll.}
proc close*(s: PSocket): cint{.cdecl, importc: "zmq_close", dynlib: zmqdll.}
proc setsockopt*(s: PSocket, option: TSockOptions, optval: pointer,
                       optvallen: int): cint {.cdecl, importc: "zmq_setsockopt",
      dynlib: zmqdll.}
proc getsockopt*(s: PSocket, option: TSockOptions, optval: pointer,
                   optvallen: ptr int): cint{.cdecl,
      importc: "zmq_getsockopt", dynlib: zmqdll.}
proc bindAddr*(s: PSocket, address: cstring): cint{.cdecl, importc: "zmq_bind",
      dynlib: zmqdll.}
proc connect*(s: PSocket, address: cstring): cint{.cdecl,
      importc: "zmq_connect", dynlib: zmqdll.}
proc unbind*(s: PSocket; address: cstring): cint {.cdecl, importc: "zmq_unbind",
      dynlib: zmqdll.}
proc disconnect*(s: Psocket; address: cstring): cint {.cdecl,
      importc: "zmq_disconnect", dynlib: zmqdll.}
proc send*(s: PSocket; buf: cstring; len: int; flags: cint): cint {.cdecl,
      importc: "zmq_send", dynlib: zmqdll.}
proc send_const*(s: PSocket; buf: cstring; len: int; flags: cint): cint {.cdecl,
      importc: "zmq_send_const", dynlib: zmqdll.}
proc recv*(s: PSocket; buf: cstring; len: int; flags: cint): cint {.cdecl,
      importc: "zmq_recv", dynlib: zmqdll.}
proc socket_monitor*(s: PSocket; address: cstring; events: cint): cint {.cdecl,
      importc: "zmq_socket_monitor", dynlib: zmqdll.}
proc sendmsg*(s: PSocket, msg: var TMsg, flags: cint): cint{.cdecl,
      importc: "zmq_sendmsg", dynlib: zmqdll.}
proc recvmsg*(s: PSocket, msg: var TMsg, flags: cint): cint{.cdecl,
      importc: "zmq_recvmsg", dynlib: zmqdll.}


#****************************************************************************
#  I/O multiplexing.                                                         
#****************************************************************************
const 
  ZMQ_POLLIN* = 1
  ZMQ_POLLOUT* = 2
  ZMQ_POLLERR* = 4
type 
  TPollItem*{.pure, final.} = object 
    socket*: PSocket
    fd*: cint
    events*: cshort
    revents*: cshort

const 
  ZMQ_POLLITEMS_DFLT* = 16
proc poll*(items: ptr TPollItem, nitems: cint, timeout: int): cint{.
  cdecl, importc: "zmq_poll", dynlib: zmqdll.}

#  Built-in message proxy (3-way) 
proc proxy*(frontend: PSocket; backend: PSocket; capture: PSocket): cint {.
  cdecl, importc: "zmq_proxy", dynlib: zmqdll.}

#  Encode a binary key as printable text using ZMQ RFC 32  
proc z85_encode*(dest: cstring; data: ptr uint8; size: int): cstring {.
  cdecl, importc: "zmq_z85_encode", dynlib: zmqdll.}

#  Encode a binary key from printable text per ZMQ RFC 32  
proc z85_decode*(dest: ptr uint8; string: cstring): ptr uint8 {.
  cdecl, importc: "zmq_z85_decode", dynlib: zmqdll.}

#  Deprecated aliases 
#const 
#  ZMQ_STREAMER* = 1
#  ZMQ_FORWARDER* = 2
#  ZMQ_QUEUE* = 3
#  Deprecated method 
#proc zmq_device*(type: cint; frontend: pointer; backend: pointer): cint



# Unofficial easier-for-Nimrod API

type
  EZmq* = object of ESynch ## exception that is raised if something fails
  TConnection* {.pure, final.} = object ## a connection
    c*: PContext  ## the embedded context
    s*: PSocket   ## the embedded socket

proc zmqError*() {.noinline, noreturn.} =
  ## raises EZmq with error message from `zmq.strerror`.
  var e: ref EZmq
  new(e)
  e.msg = $strerror(errno())
  raise e


proc connect*(address: string, mode: TSocketType = REQ): TConnection =
    ## open a new connection and connects
    result.c = ctx_new()
    if result.c == nil:
        zmqError()

    result.s = socket(result.c, cint(mode))
    if result.s == nil:
        zmqError()

    if connect(result.s, address) != 0:
        zmqError()

proc listen*(address: string, mode: TSocketType = REP): TConnection =
    ## open a new connection and binds on the socket
    result.c = ctx_new()
    if result.c == nil:
        zmqError()

    result.s = socket(result.c, cint(mode))
    if result.s == nil:
        zmqError()

    if bindAddr(result.s, address) != 0:
        zmqError()

proc close*(c: TConnection) =
    ## closes the connection.
    if close(c.s) != 0:
        zmqError()
    if ctx_destroy(c.c) != 0:
        zmqError()


proc send*(c: TConnection, msg: string) =
    ## sends a message over the connection.
    var m: TMsg
    if msg_init(m, msg.len) != 0:
        zmqError()

    copyMem(msg_data(m), cstring(msg), msg.len)

    if msg_send(m, c.s, 0) == -1:
        zmqError()
    # no close msg after a send

proc receive*(c: TConnection): string =
    ## receives a message from a connection.
    var m: TMsg
    if msg_init(m) != 0:
        zmqError()

    if msg_recv(m, c.s, 0) == -1:
        zmqError()

    result = newString( msg_size(m) )
    copyMem(addr(result[0]), msg_data(m), result.len)

    if msg_close(m) != 0:
        zmqError()

proc setsockopt*(c: TConnection, option: TSockOptions, optval: string): int =
    return setsockopt(c.s, option, cstring(optval), optval.len)
