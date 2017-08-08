/**** Copyright ************************************************
    > File Name: threadpool2.cpp
    > Author: 
    > Created Time: Mon 07 Aug 2017 08:01:45 PM CST
 ************************************************************************/

#include <iostream>
#include <queue>
#include <atomic>
#include <string>
#include <vector>
#include <thread>
#include <functional>
#include <mutex>
#include <condition_variable>

class Task {
  public:
    Task(std::string v):v(v) {};

    void operator()() {
        static int index =0;
        if (!(index++%100000))
            std::cout << "task:" << v << std::endl;

    };

    std::string v;
};


class ThreadPool {
  public:
    ThreadPool(size_t threads) : stop(false) {
        for(size_t i = 0; i<threads; ++i)
            workers.emplace_back(
            [this] {
            for(;;) {
                std::function<void()> task;

                {
                    std::unique_lock<std::mutex> lock(this->queue_mutex);
                    this->condition.wait(lock,
                    [this] { return this->stop || !this->tasks.empty(); });
                    if(this->stop && this->tasks.empty())
                        return;
                    task = std::move(this->tasks.front());
                    this->tasks.pop();
                }

                task();
            }
        }
        );

    }
    // add new work item to the pool
    void enqueue(std::function<void()>& task) {
        {
            std::unique_lock<std::mutex> lock(queue_mutex);

            // don't allow enqueueing after stopping the pool
            if(stop)
                throw std::runtime_error("enqueue on stopped ThreadPool");

            tasks.emplace(task);
        }
        condition.notify_one();
    }
    ~ThreadPool() {
        {
            std::unique_lock<std::mutex> lock(queue_mutex);
            stop = true;
        }
        condition.notify_all();
        for(std::thread &worker: workers)
            worker.join();
    }

    void Stop() {
        stop = true;
    }
  private:
    std::vector< std::thread > workers;
    // the task queue
    std::queue< std::function<void()> > tasks;

    // synchronization
    std::mutex queue_mutex;
    std::condition_variable condition;
    bool stop;
};


int main(int argc, char **argv) {
    if (argc < 2)
        exit(0);

    int t_n = std::stoi(argv[1]);

    ThreadPool tp(t_n);

    std::string in;
    while (getline(std::cin, in)) {
        //std::function<void()> tsk = Task(in);
        std::function<void()> tsk = Task(in);
        tp.enqueue(tsk);
    }

    tp.Stop();

    return 0;
}
