
/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
typedef  TDMuple3Callback<T> = Future<void> Function(T value);

typedef TDWhileTrueAsyncCallbackLoop = Function(bool loopAgain);
typedef TDWhileTrueAsyncCallback = Future<void> Function(TDWhileTrueAsyncCallbackLoop loop);
