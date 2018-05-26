#define lock 1
#define free 0

#define NotCs 0
#define WantRead 1
#define ReadCS 2
#define WantWrite 3
#define WriteCS 4
#define Finished 5

#define Iterations 100

#define PROC_NUM 4

bit reader = 0;
bit writer = 0;
byte nReaders = 0;
byte nWriters = 0;

byte state[PROC_NUM];

inline spinLock(l)
{
	bit prev;
lock_state:
	atomic
	{
		prev = l;
		l = 1;
	}
	if
		:: (prev == 1) -> goto lock_state;
		:: else -> skip;
	fi;

}

inline spinUnlock(l)
{	
	l = 0;
}

inline LockReader()
{
	spinLock(reader);
	nReaders++;
	if     
		:: nReaders == 1 -> spinLock(writer);
		:: else -> skip;
	fi;
	spinUnlock(reader);
}

inline UnlockReader()
{
	spinLock(reader)
	nReaders--;
	if
		:: nReaders == 0 -> spinUnlock(writer);
		:: else -> skip;
	fi;
	spinUnlock(reader);
}

inline LockWriter()
{
	atomic
	{
		spinLock(writer);
		nWriters++;
	}
	
}

inline UnlockWriter()
{
	atomic
	{
		spinUnlock(writer);
		nWriters--;
	}
}


active [PROC_NUM] proctype user()
{
	state[_pid] = NotCs;

	int cnt = 0;

	do
	:: (cnt < Iterations) ->
		cnt++;
		state[_pid] = WantWrite;
		LockWriter();
		state[_pid] = WriteCS;
		UnlockWriter();
		state[_pid] = WantRead;
		LockReader();
		state[_pid] = ReadCS;
		UnlockReader();
		state[_pid] = NotCs;
	od;
	state[_pid] = Finished;
}

