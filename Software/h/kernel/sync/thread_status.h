#pragma once

enum kthread_status {
	KTHREAD_STATUS_SUCCESS,
	KTHREAD_STATUS_NOMEM,
	KTHREAD_STATUS_TIMEDOUT,
	KTHREAD_STATUS_BUSY,
	KTHREAD_STATUS_ERROR
};	