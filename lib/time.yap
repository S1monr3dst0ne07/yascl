




fn Time::NanoSleep(sec, nsec)
    // not rem, because i'm lazy.
    // also because yascl doesn't have multi-threading.
{
    static 2 ~ buf;
    put buf.0 = sec;
    put buf.1 = nsec;

    Sys::TryCall(
        "Time::NanoSleep",
        SYSCALL::NANOSLEEP,
        buf,
        0,
    );
}


fn Time::Nap(msec)
{
    put low  = msec % 1000;
    put high = msec / 1000;

    Time::NanoSleep(high, low * 1000000);
}




