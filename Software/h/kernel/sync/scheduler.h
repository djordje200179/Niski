#pragma once

struct kthread;

void kscheduler_enqueue(struct kthread* thread);
struct kthread* kscheduler_dequeue();