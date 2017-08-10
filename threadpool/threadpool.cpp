/*************************************************************************
    > File Name: threadpool.cpp
    > Author:
    > Mail:
    > Created Time: 2017年08月06日 星期日 10时40分55秒
 ************************************************************************/
#include <sys/types.h>
#include <sys/wait.h>
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

#include <sys/epoll.h>
#include <sys/sysinfo.h>
#include <sys/syscall.h>
//#define _GNU_SOURCE
#include <utmpx.h>

#include <iostream>
#include <queue>
#include <atomic>
#include <string>
#include <vector>
#include <map>
#include <thread>
#include <functional>

#define MAX_EVENTS 10

namespace threadpool {

class Worker {
  public:
    int pipefd[2] = {-1,-1};
    int ep_fd = -1;

    int run_cpu_no = 0;
    bool stop = false;

    int queues_num = 2;
    std::atomic_flag queues_flag[2];
    std::atomic_flag queues_notify;
    std::queue< std::function<void()> > queues[2];

    int debug = 0;
    struct epoll_event events[MAX_EVENTS];

    Worker(int cpu) {
        queues_flag[0].clear();
        queues_flag[1].clear();

        run_cpu_no = cpu;
        init();
    }

    ~Worker() {
        if (pipefd[0] > 0)
            close(pipefd[0]);
        if (pipefd[1] > 0)
            close(pipefd[1]);

        if (ep_fd > 0)
            close(ep_fd);

        //    std::cout << " run_cpu_no:" << run_cpu_no << " debug:" << debug <<" no_h:" << queues[0].size() + queues[1].size() << std::endl;
    }

    Worker(Worker &&w) noexcept :
        pipefd{(w.pipefd[0]),w.pipefd[1]},
           ep_fd(w.ep_fd),
           run_cpu_no(w.run_cpu_no),
    queues_num(w.queues_num) {
        queues_flag[0].clear();
        queues_flag[1].clear();
        queues[0] = w.queues[0];
        queues[1] = w.queues[1];
        stop = false;

        w.pipefd[0] = -1;
        w.pipefd[1] = -1;
        w.ep_fd = -1;
    }

    void init() {
        if (pipe(pipefd) == -1) {
            perror("pipe");
            exit(EXIT_FAILURE);
        }

        int flags = fcntl(pipefd[0], F_GETFL);
        flags |= O_NONBLOCK;
        fcntl(pipefd[0], F_SETFL, flags);

        flags = fcntl(pipefd[1], F_GETFL);
        flags |= O_NONBLOCK;
        fcntl(pipefd[1], F_SETFL, flags);

        ep_fd = epoll_create1(0);
        if (ep_fd == -1) {
            perror("epoll_create1");
            exit(EXIT_FAILURE);
        }

        struct epoll_event ev;
        ev.events = EPOLLIN;
        ev.data.fd = pipefd[0];
        if (epoll_ctl(ep_fd, EPOLL_CTL_ADD, pipefd[0], &ev) == -1) {
            perror("epoll_ctl: pipefd[0]");
            exit(EXIT_FAILURE);
        }

    }

    void notify(int cmd) {
        if (cmd == 1 && queues_notify.test_and_set() ) {
            return;
        }

        //  std::cout <<"worker_"<< run_cpu_no << " notify pipefd[1]:" <<pipefd[1] << std::endl;
        int ret = write(pipefd[1], &cmd, sizeof(cmd));
        if (ret < 0) {
            std::cout  << "notify error! cmd:" << cmd << std::endl;
            perror("notify");
        }

    }

    // add new task to the worker
    bool enqueue(std::function<void()>& task) {
        if(stop) {
            std::cout << "enqueue on stopped worker\n";
            return false;
        }

        for (int i = 0; i < queues_num; i++) {
            if (!queues_flag[i].test_and_set()) {
                queues[i].emplace(task);

                // TODO notify worker thread
                notify(1);

                queues_flag[i].clear();
                return true;
            }
        }

        return false;
    }

    void handler () {
        for (int i = 0; i < queues_num; i++) {
            if (!queues_flag[i].test_and_set()) {
                debug += queues[i].size();
                while (!queues[i].empty()) {
                    std::function<void()> task = std::move(queues[i].front());
                    queues[i].pop();

                    // handler task
                    task();
                }

                queues_flag[i].clear();
                if (!stop)
                    return;
            }

        }
    }

    void operator()() {
        cpu_set_t set;
        CPU_ZERO(&set);
        CPU_SET(run_cpu_no, &set);

        pid_t pid = syscall(SYS_gettid);
        if (sched_setaffinity(pid, sizeof(set), &set) == -1)
            std::cout << "gettid:" << pid <<" sched_setaffinity error!\n";
        /*
                int cpu = sched_getcpu();
                int ret =0;//= syscall(SYS_get_cpu, &cpu, NULL, NULL);
                std::cout << "*ret:"<< ret<< "*****cpu:"<< cpu<< "****pid:" << pid << std::endl;
        */
        int nfds;
        for (;;) {
            nfds = epoll_wait(ep_fd, events, MAX_EVENTS, -1);
            if (nfds == -1) {
                perror("epoll_wait");
                return;
            }

            for (int n = 0; n < nfds; ++n) {
                if (events[n].data.fd == pipefd[0]) {
                    int cmd;
                    int ret = read(pipefd[0], &cmd, sizeof(cmd));
//                    std::cout << "cmd:" << cmd << std::endl;
                    queues_notify.clear();
                    if (ret < 0) {
                        continue;
                    }
                    switch(cmd) {
                    case 0:
                        handler();
                        return;
                    case 1:
                        // TODO handler queues
                        handler();
                        break;
                    default:
                        break;
                    }
                } else {
                    // do_use_fd(events[n].data.fd);

                }

            }

        }
    }
};

void handler(Worker *w) {
    (*w)();
}

class ThreadPool {
  public:
    std::vector<std::thread> threads;
    //std::vector<Worker*> workers;
    std::vector<std::vector<Worker*>> workers_vl;
    std::vector<uint32_t> nexts;
    int cpus;

    ThreadPool(int threads_num = 0) {
        cpus = get_nprocs();
        threads_num = threads_num < 1 ? cpus : threads_num;

        int idx = 0;
        int idx_old = 0;
        std::vector<Worker*> workers;
        for (int i=0; i<threads_num; i++) {
            Worker *w = new Worker(i%cpus);
            threads.emplace_back(std::thread(handler, w));

            idx = i%cpus;
            if (idx_old != 0 && idx < static_cast<int>(workers_vl.size()))
                workers_vl[idx].emplace_back(w);
            else {
                workers.emplace_back(w);
                //std::cout << "*****idx_old:"<< idx_old << "****idx:" << idx << std::endl;
                if (idx_old != idx || i == threads_num -1) {
                    workers_vl.emplace_back(workers);
                    idx_old = idx;
                    workers.clear();
                }

                if (idx_old == 0 && idx ==0) {
                    workers_vl.emplace_back(workers);
                    workers.clear();
                }
            }
        }

        for (int i=0; i<cpus; i++) {
            nexts.emplace_back(0);
        }

        /*
        std::cout << "**cpu:"<< cpus <<"****workers_vl.size:" << workers_vl.size() << std::endl;
        for (auto wl : workers_vl) {
            std::cout << "********workers.size:" << wl.size() << std::endl;
        }
        */
    }

    ~ThreadPool() {
        for (auto &th : threads) th.join();
        //for (auto w : workers) delete w;

        for (auto wl : workers_vl) {
            for (auto w : wl) delete w;
        }
    }

    inline  bool for_wl(std::function<void()> &task) {
        for (auto wl : workers_vl) {
            for (auto w : wl) {
                if (w->enqueue(task))
                    return true;
            }
        }

        return false;
    }


    bool enqueue(std::function<void()> &task) {
        int cpu = sched_getcpu();
        int idx = cpu;

        if (static_cast<int>(workers_vl.size()) > cpu) {
            int idx_size = workers_vl[idx].size();
            while (workers_vl[idx][(nexts[idx]++)%idx_size]->enqueue(task))
                return true;

            if (for_wl(task))
                return true;
        } else {
            if (for_wl(task))
                return true;
        }

        return false;
    }

    void stop() {
        for (auto workers : workers_vl) {
            for (auto w : workers) {
                w->stop = true;
                w->notify(0);
            }
        }
    }
};

} // namespace



class Task {
  public:
    Task(std::string v):v(v) {};

    void operator()() {
        static int index = 0;
        if (!(index++%100000))
            std::cout << "task:" << v << std::endl;
    };

    std::string v;
};



int main(int argc, char **argv) {
    if (argc < 2)
        exit(0);

    int t_n = std::stoi(argv[1]);

    threadpool::ThreadPool tp(t_n);

    std::string in;
    while (getline(std::cin, in)) {
        std::function<void()> tsk = Task(in);
        if(!tp.enqueue(tsk)) {
            std::cout << "ThreadPool::enqueue error !" << std::endl;
        }
    }

    tp.stop();
    return 0;
}
