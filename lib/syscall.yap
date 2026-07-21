
use "lib/bool.yap"


seq SYSCALL
{
    READ, 
    WRITE,
    OPEN, 
    CLOSE,
    STAT,
    FSTAT,

    EXIT = 60,
}



fn Sys::TryCall(caller, code, a1, a2, a3, a4, a5)
{
    put retval = syscall(code, a1, a2, a3, a4, a5);

    jump skip ~ Sys::Error(retval) ^ Bool::TRUE;
        print("[%s] %s\n", [caller, Sys::ErrorMsg(retval)]);
    lab skip;


    return retval;
}



seq ERROR
{
    ZEROPLACEHOLDER,
    EPERM,
    ENOENT,
    ESRCH,
    EINTR,
    EIO,
    ENXIO,
    E2BIG,
    ENOEXEC,
    EBADF,
    ECHILD,
    EAGAIN,
    ENOMEM,
    EACCES,
    EFAULT,
    ENOTBLK,
    EBUSY,
    EEXIST,
    EXDEV,
    ENODEV,
    ENOTDIR,
    EISDIR,
    EINVAL,
    ENFILE,
    EMFILE,
    ENOTTY,
    ETXTBSY,
    EFBIG,
    ENOSPC,
    ESPIPE,
    EROFS,
    EMLINK,
    EPIPE,
    EDOM,
    ERANGE,
    EDEADLK,
    ENAMETOOLONG,
    ENOLCK,
    ENOSYS,
    ENOTEMPTY,
    ELOOP,
    ENOMSG,
    EIDRM,
    ECHRNG,
    EL2NSYNC,
    EL3HLT,
    EL3RST,
    ELNRNG,
    EUNATCH,
    ENOCSI,
    EL2HLT,
    EBADE,
    EBADR,
    EXFULL,
    ENOANO,
    EBADRQC,
    EBADSLT,
    EBFONT,
    ENOSTR,
    ENODATA,
    ETIME,
    ENOSR,
    ENONET,
    ENOPKG,
    EREMOTE,
    ENOLINK,
    EADV,
    ESRMNT,
    ECOMM,
    EPROTO,
    EMULTIHOP,
    EDOTDOT,
    EBADMSG,
    EOVERFLOW,
    ENOTUNIQ,
    EBADFD,
    EREMCHG,
    ELIBACC,
    ELIBBAD,
    ELIBSCN,
    ELIBMAX,
    ELIBEXEC,
    EILSEQ,
    ERESTART,
    ESTRPIPE,
    EUSERS,
    ENOTSOCK,
    EDESTADDRREQ,
    EMSGSIZE,
    EPROTOTYPE,
    ENOPROTOOPT,
    EPROTONOSUPPORT,
    ESOCKTNOSUPPORT,
    EOPNOTSUPP,
    EPFNOSUPPORT,
    EAFNOSUPPORT,
    EADDRINUSE,
    EADDRNOTAVAIL,
    ENETDOWN,
    ENETUNREACH,
    ENETRESET,
    ECONNABORTED,
    ECONNRESET,
    ENOBUFS,
    EISCONN,
    ENOTCONN,
    ESHUTDOWN,
    ETOOMANYREFS,
    ETIMEDOUT,
    ECONNREFUSED,
    EHOSTDOWN,
    EHOSTUNREACH,
    EALREADY,
    EINPROGRESS,
    ESTALE,
    EUCLEAN,
    ENOTNAM,
    ENAVAIL,
    EISNAM,
    EREMOTEIO,
    EDQUOT,
    ENOMEDIUM,
    EMEDIUMTYPE,
    ECANCELED,
    ENOKEY,
    EKEYEXPIRED,
    EKEYREVOKED,
    EKEYREJECTED,
    EOWNERDEAD,
    ENOTRECOVERABLE,
}


fn Sys::Error(retval)
{
    return retval > (0 - 4095);
}

fn Sys::ErrorMsg(retval)
{
    put code = 0 - retval;

	jump skip_EPERM	            ~ code != ERROR::EPERM; return "Operation not permitted"; lab skip_EPERM;
	jump skip_ENOENT	        ~ code != ERROR::ENOENT; return "No such file or directory"; lab skip_ENOENT;
	jump skip_ESRCH	            ~ code != ERROR::ESRCH; return "No such process"; lab skip_ESRCH;
	jump skip_EINTR	            ~ code != ERROR::EINTR; return "Interrupted system call"; lab skip_EINTR;
	jump skip_EIO	            ~ code != ERROR::EIO; return "I/O error"; lab skip_EIO;
	jump skip_ENXIO	            ~ code != ERROR::ENXIO; return "No such device or address"; lab skip_ENXIO;
	jump skip_E2BIG	            ~ code != ERROR::E2BIG; return "Argument list too long"; lab skip_E2BIG;
	jump skip_ENOEXEC	        ~ code != ERROR::ENOEXEC; return "Exec format error"; lab skip_ENOEXEC;
	jump skip_EBADF	            ~ code != ERROR::EBADF; return "Bad file number"; lab skip_EBADF;
	jump skip_ECHILD	        ~ code != ERROR::ECHILD; return "No child processes"; lab skip_ECHILD;
	jump skip_EAGAIN	        ~ code != ERROR::EAGAIN; return "Try again"; lab skip_EAGAIN;
	jump skip_ENOMEM	        ~ code != ERROR::ENOMEM; return "Out of memory"; lab skip_ENOMEM;
	jump skip_EACCES	        ~ code != ERROR::EACCES; return "Permission denied"; lab skip_EACCES;
	jump skip_EFAULT	        ~ code != ERROR::EFAULT; return "Bad address"; lab skip_EFAULT;
	jump skip_ENOTBLK	        ~ code != ERROR::ENOTBLK; return "Block device required"; lab skip_ENOTBLK;
	jump skip_EBUSY	            ~ code != ERROR::EBUSY; return "Device or resource busy"; lab skip_EBUSY;
	jump skip_EEXIST	        ~ code != ERROR::EEXIST; return "File exists"; lab skip_EEXIST;
	jump skip_EXDEV	            ~ code != ERROR::EXDEV; return "Cross-device link"; lab skip_EXDEV;
	jump skip_ENODEV	        ~ code != ERROR::ENODEV; return "No such device"; lab skip_ENODEV;
	jump skip_ENOTDIR	        ~ code != ERROR::ENOTDIR; return "Not a directory"; lab skip_ENOTDIR;
	jump skip_EISDIR	        ~ code != ERROR::EISDIR; return "Is a directory"; lab skip_EISDIR;
	jump skip_EINVAL	        ~ code != ERROR::EINVAL; return "Invalid argument"; lab skip_EINVAL;
	jump skip_ENFILE	        ~ code != ERROR::ENFILE; return "File table overflow"; lab skip_ENFILE;
	jump skip_EMFILE	        ~ code != ERROR::EMFILE; return "Too many open files"; lab skip_EMFILE;
	jump skip_ENOTTY	        ~ code != ERROR::ENOTTY; return "Not a typewriter"; lab skip_ENOTTY;
	jump skip_ETXTBSY	        ~ code != ERROR::ETXTBSY; return "Text file busy"; lab skip_ETXTBSY;
	jump skip_EFBIG	            ~ code != ERROR::EFBIG; return "File too large"; lab skip_EFBIG;
	jump skip_ENOSPC	        ~ code != ERROR::ENOSPC; return "No space left on device"; lab skip_ENOSPC;
	jump skip_ESPIPE	        ~ code != ERROR::ESPIPE; return "Illegal seek"; lab skip_ESPIPE;
	jump skip_EROFS	            ~ code != ERROR::EROFS; return "Read-only file system"; lab skip_EROFS;
	jump skip_EMLINK	        ~ code != ERROR::EMLINK; return "Too many links"; lab skip_EMLINK;
	jump skip_EPIPE	            ~ code != ERROR::EPIPE; return "Broken pipe"; lab skip_EPIPE;
	jump skip_EDOM	            ~ code != ERROR::EDOM; return "Math argument out of domain of func"; lab skip_EDOM;
	jump skip_ERANGE	        ~ code != ERROR::ERANGE; return "Math result not representable"; lab skip_ERANGE;
	jump skip_EDEADLK	        ~ code != ERROR::EDEADLK; return "Resource deadlock would occur"; lab skip_EDEADLK;
	jump skip_ENAMETOOLONG	    ~ code != ERROR::ENAMETOOLONG; return "File name too long"; lab skip_ENAMETOOLONG;
	jump skip_ENOLCK	        ~ code != ERROR::ENOLCK; return "No record locks available"; lab skip_ENOLCK;
	jump skip_ENOSYS	        ~ code != ERROR::ENOSYS; return "Function not implemented"; lab skip_ENOSYS;
	jump skip_ENOTEMPTY	        ~ code != ERROR::ENOTEMPTY; return "Directory not empty"; lab skip_ENOTEMPTY;
	jump skip_ELOOP	            ~ code != ERROR::ELOOP; return "Too many symbolic links encountered"; lab skip_ELOOP;
	jump skip_ENOMSG	        ~ code != ERROR::ENOMSG; return "No message of desired type"; lab skip_ENOMSG;
	jump skip_EIDRM	            ~ code != ERROR::EIDRM; return "Identifier removed"; lab skip_EIDRM;
	jump skip_ECHRNG	        ~ code != ERROR::ECHRNG; return "Channel number out of range"; lab skip_ECHRNG;
	jump skip_EL2NSYNC	        ~ code != ERROR::EL2NSYNC; return "Level 2 not synchronized"; lab skip_EL2NSYNC;
	jump skip_EL3HLT	        ~ code != ERROR::EL3HLT; return "Level 3 halted"; lab skip_EL3HLT;
	jump skip_EL3RST	        ~ code != ERROR::EL3RST; return "Level 3 reset"; lab skip_EL3RST;
	jump skip_ELNRNG	        ~ code != ERROR::ELNRNG; return "Link number out of range"; lab skip_ELNRNG;
	jump skip_EUNATCH	        ~ code != ERROR::EUNATCH; return "Protocol driver not attached"; lab skip_EUNATCH;
	jump skip_ENOCSI	        ~ code != ERROR::ENOCSI; return "No CSI structure available"; lab skip_ENOCSI;
	jump skip_EL2HLT	        ~ code != ERROR::EL2HLT; return "Level 2 halted"; lab skip_EL2HLT;
	jump skip_EBADE	            ~ code != ERROR::EBADE; return "Invalid exchange"; lab skip_EBADE;
	jump skip_EBADR	            ~ code != ERROR::EBADR; return "Invalid request descriptor"; lab skip_EBADR;
	jump skip_EXFULL	        ~ code != ERROR::EXFULL; return "Exchange full"; lab skip_EXFULL;
	jump skip_ENOANO	        ~ code != ERROR::ENOANO; return "No anode"; lab skip_ENOANO;
	jump skip_EBADRQC	        ~ code != ERROR::EBADRQC; return "Invalid request code"; lab skip_EBADRQC;
	jump skip_EBADSLT	        ~ code != ERROR::EBADSLT; return "Invalid slot"; lab skip_EBADSLT;
	jump skip_EBFONT	        ~ code != ERROR::EBFONT; return "Bad font file format"; lab skip_EBFONT;
	jump skip_ENOSTR	        ~ code != ERROR::ENOSTR; return "Device not a stream"; lab skip_ENOSTR;
	jump skip_ENODATA	        ~ code != ERROR::ENODATA; return "No data available"; lab skip_ENODATA;
	jump skip_ETIME	            ~ code != ERROR::ETIME; return "Timer expired"; lab skip_ETIME;
	jump skip_ENOSR	            ~ code != ERROR::ENOSR; return "Out of streams resources"; lab skip_ENOSR;
	jump skip_ENONET	        ~ code != ERROR::ENONET; return "Machine is not on the network"; lab skip_ENONET;
	jump skip_ENOPKG	        ~ code != ERROR::ENOPKG; return "Package not installed"; lab skip_ENOPKG;
	jump skip_EREMOTE	        ~ code != ERROR::EREMOTE; return "Object is remote"; lab skip_EREMOTE;
	jump skip_ENOLINK	        ~ code != ERROR::ENOLINK; return "Link has been severed"; lab skip_ENOLINK;
	jump skip_EADV	            ~ code != ERROR::EADV; return "Advertise error"; lab skip_EADV;
	jump skip_ESRMNT	        ~ code != ERROR::ESRMNT; return "Srmount error"; lab skip_ESRMNT;
	jump skip_ECOMM	            ~ code != ERROR::ECOMM; return "Communication error on send"; lab skip_ECOMM;
	jump skip_EPROTO	        ~ code != ERROR::EPROTO; return "Protocol error"; lab skip_EPROTO;
	jump skip_EMULTIHOP	        ~ code != ERROR::EMULTIHOP; return "Multihop attempted"; lab skip_EMULTIHOP;
	jump skip_EDOTDOT	        ~ code != ERROR::EDOTDOT; return "RFS specific error"; lab skip_EDOTDOT;
	jump skip_EBADMSG	        ~ code != ERROR::EBADMSG; return "Not a data message"; lab skip_EBADMSG;
	jump skip_EOVERFLOW	        ~ code != ERROR::EOVERFLOW; return "Value too large for defined data type"; lab skip_EOVERFLOW;
	jump skip_ENOTUNIQ	        ~ code != ERROR::ENOTUNIQ; return "Name not unique on network"; lab skip_ENOTUNIQ;
	jump skip_EBADFD	        ~ code != ERROR::EBADFD; return "File descriptor in bad state"; lab skip_EBADFD;
	jump skip_EREMCHG	        ~ code != ERROR::EREMCHG; return "Remote address changed"; lab skip_EREMCHG;
	jump skip_ELIBACC	        ~ code != ERROR::ELIBACC; return "Can not access a needed shared library"; lab skip_ELIBACC;
	jump skip_ELIBBAD	        ~ code != ERROR::ELIBBAD; return "Accessing a corrupted shared library"; lab skip_ELIBBAD;
	jump skip_ELIBSCN	        ~ code != ERROR::ELIBSCN; return "lib section in a.out corrupted"; lab skip_ELIBSCN;
	jump skip_ELIBMAX	        ~ code != ERROR::ELIBMAX; return "Attempting to link in too many shared libraries"; lab skip_ELIBMAX;
	jump skip_ELIBEXEC	        ~ code != ERROR::ELIBEXEC; return "Cannot exec a shared library directly"; lab skip_ELIBEXEC;
	jump skip_EILSEQ	        ~ code != ERROR::EILSEQ; return "Illegal byte sequence"; lab skip_EILSEQ;
	jump skip_ERESTART	        ~ code != ERROR::ERESTART; return "Interrupted system call should be restarted"; lab skip_ERESTART;
	jump skip_ESTRPIPE	        ~ code != ERROR::ESTRPIPE; return "Streams pipe error"; lab skip_ESTRPIPE;
	jump skip_EUSERS	        ~ code != ERROR::EUSERS; return "Too many users"; lab skip_EUSERS;
	jump skip_ENOTSOCK	        ~ code != ERROR::ENOTSOCK; return "Socket operation on non-socket"; lab skip_ENOTSOCK;
	jump skip_EDESTADDRREQ	    ~ code != ERROR::EDESTADDRREQ; return "Destination address required"; lab skip_EDESTADDRREQ;
	jump skip_EMSGSIZE	        ~ code != ERROR::EMSGSIZE; return "Message too long"; lab skip_EMSGSIZE;
	jump skip_EPROTOTYPE	    ~ code != ERROR::EPROTOTYPE; return "Protocol wrong type for socket"; lab skip_EPROTOTYPE;
	jump skip_ENOPROTOOPT	    ~ code != ERROR::ENOPROTOOPT; return "Protocol not available"; lab skip_ENOPROTOOPT;
	jump skip_EPROTONOSUPPORT	~ code != ERROR::EPROTONOSUPPORT; return "Protocol not supported"; lab skip_EPROTONOSUPPORT;
	jump skip_ESOCKTNOSUPPORT	~ code != ERROR::ESOCKTNOSUPPORT; return "Socket type not supported"; lab skip_ESOCKTNOSUPPORT;
	jump skip_EOPNOTSUPP	    ~ code != ERROR::EOPNOTSUPP; return "Operation not supported on transport endpoint"; lab skip_EOPNOTSUPP;
	jump skip_EPFNOSUPPORT	    ~ code != ERROR::EPFNOSUPPORT; return "Protocol family not supported"; lab skip_EPFNOSUPPORT;
	jump skip_EAFNOSUPPORT	    ~ code != ERROR::EAFNOSUPPORT; return "Address family not supported by protocol"; lab skip_EAFNOSUPPORT;
	jump skip_EADDRINUSE	    ~ code != ERROR::EADDRINUSE; return "Address already in use"; lab skip_EADDRINUSE;
	jump skip_EADDRNOTAVAIL	    ~ code != ERROR::EADDRNOTAVAIL; return "Cannot assign requested address"; lab skip_EADDRNOTAVAIL;
	jump skip_ENETDOWN	        ~ code != ERROR::ENETDOWN; return "Network is down"; lab skip_ENETDOWN;
	jump skip_ENETUNREACH	    ~ code != ERROR::ENETUNREACH; return "Network is unreachable"; lab skip_ENETUNREACH;
	jump skip_ENETRESET	        ~ code != ERROR::ENETRESET; return "Network dropped connection because of reset"; lab skip_ENETRESET;
	jump skip_ECONNABORTED	    ~ code != ERROR::ECONNABORTED; return "Software caused connection abort"; lab skip_ECONNABORTED;
	jump skip_ECONNRESET	    ~ code != ERROR::ECONNRESET; return "Connection reset by peer"; lab skip_ECONNRESET;
	jump skip_ENOBUFS	        ~ code != ERROR::ENOBUFS; return "No buffer space available"; lab skip_ENOBUFS;
	jump skip_EISCONN	        ~ code != ERROR::EISCONN; return "Transport endpoint is already connected"; lab skip_EISCONN;
	jump skip_ENOTCONN	        ~ code != ERROR::ENOTCONN; return "Transport endpoint is not connected"; lab skip_ENOTCONN;
	jump skip_ESHUTDOWN	        ~ code != ERROR::ESHUTDOWN; return "Cannot send after transport endpoint shutdown"; lab skip_ESHUTDOWN;
	jump skip_ETOOMANYREFS	    ~ code != ERROR::ETOOMANYREFS; return "Too many references: cannot splice"; lab skip_ETOOMANYREFS;
	jump skip_ETIMEDOUT	        ~ code != ERROR::ETIMEDOUT; return "Connection timed out"; lab skip_ETIMEDOUT;
	jump skip_ECONNREFUSED	    ~ code != ERROR::ECONNREFUSED; return "Connection refused"; lab skip_ECONNREFUSED;
	jump skip_EHOSTDOWN	        ~ code != ERROR::EHOSTDOWN; return "Host is down"; lab skip_EHOSTDOWN;
	jump skip_EHOSTUNREACH	    ~ code != ERROR::EHOSTUNREACH; return "No route to host"; lab skip_EHOSTUNREACH;
	jump skip_EALREADY	        ~ code != ERROR::EALREADY; return "Operation already in progress"; lab skip_EALREADY;
	jump skip_EINPROGRESS	    ~ code != ERROR::EINPROGRESS; return "Operation now in progress"; lab skip_EINPROGRESS;
	jump skip_ESTALE	        ~ code != ERROR::ESTALE; return "Stale NFS file handle"; lab skip_ESTALE;
	jump skip_EUCLEAN	        ~ code != ERROR::EUCLEAN; return "Structure needs cleaning"; lab skip_EUCLEAN;
	jump skip_ENOTNAM	        ~ code != ERROR::ENOTNAM; return "Not a XENIX named type file"; lab skip_ENOTNAM;
	jump skip_ENAVAIL	        ~ code != ERROR::ENAVAIL; return "No XENIX semaphores available"; lab skip_ENAVAIL;
	jump skip_EISNAM	        ~ code != ERROR::EISNAM; return "Is a named type file"; lab skip_EISNAM;
	jump skip_EREMOTEIO	        ~ code != ERROR::EREMOTEIO; return "Remote I/O error"; lab skip_EREMOTEIO;
	jump skip_EDQUOT	        ~ code != ERROR::EDQUOT; return "Quota exceeded"; lab skip_EDQUOT;
	jump skip_ENOMEDIUM	        ~ code != ERROR::ENOMEDIUM; return "No medium found"; lab skip_ENOMEDIUM;
	jump skip_EMEDIUMTYPE	    ~ code != ERROR::EMEDIUMTYPE; return "Wrong medium type"; lab skip_EMEDIUMTYPE;
	jump skip_ECANCELED	        ~ code != ERROR::ECANCELED; return "Operation Canceled"; lab skip_ECANCELED;
	jump skip_ENOKEY	        ~ code != ERROR::ENOKEY; return "Required key not available"; lab skip_ENOKEY;
	jump skip_EKEYEXPIRED	    ~ code != ERROR::EKEYEXPIRED; return "Key has expired"; lab skip_EKEYEXPIRED;
	jump skip_EKEYREVOKED	    ~ code != ERROR::EKEYREVOKED; return "Key has been revoked"; lab skip_EKEYREVOKED;
	jump skip_EKEYREJECTED	    ~ code != ERROR::EKEYREJECTED; return "Key was rejected by service"; lab skip_EKEYREJECTED;
	jump skip_EOWNERDEAD	    ~ code != ERROR::EOWNERDEAD; return "Owner died"; lab skip_EOWNERDEAD;
	jump skip_ENOTRECOVERABLE	~ code != ERROR::ENOTRECOVERABLE; return "State not recoverable"; lab skip_ENOTRECOVERABLE;

}


