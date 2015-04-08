# Resources

A simple Elixir module to gather system resource information or monitor it at a set interval on a *linux* system. Most other systems will just return :error or {:error, _}.

Resources is part of the Cellulose group of projects which are intented for
embeded Elixir/Erlang systems but may find practical application outside of this
area.

This project is very young and needs a lot of upgrades. Please feel free to
offer any suggestions!
  
## Usage Example
  
Polling example 1:

    Resources.start_monitor(callback: fn(args) -> IO.write "#{inspect args}" end)
    ...or...
    Resources.Monitor.start(callback: fn(args) -> IO.write "#{inspect args}" end)

Then, every 5 seconds the callback function will get called with all information found by Resources

Polling example 2: Start polling server with disk filtering

    Resources.Monitor.start [disks: [root: "/", dev: "/dev"], 
    callback: fn(args) -> IO.write "#{inspect args}" end]

Then, every 5 seconds the callback will be updated as in the first example except only the `/` and `/dev` disks will be available to the callback
and they will have the keys `:root` and `:dev` respectivly.

Standalone examples:

    iex> Resources.Cpu.info
    [load_1_min: "0.00", load_5_min: "0.01", load_15_min: "0.05",
    running_tasks: "2/207", last_pid: "1553"]

    ied> Resources.Memory.info
    [mem_free: 2614052, mem_total: 4044756]

## Contributing

We appreciate any contribution to Cellulose Projects, so check out our [CONTRIBUTING.md](CONTRIBUTING.md) guide for more information. We usually keep a list of features and bugs [in the issue tracker][2].

## Building documentation

Building the documentation requires [ex_doc](https://github.com/elixir-lang/ex_doc) to be installed. Please refer to
their README for installation instructions and usage instructions.

## License

The MIT License (MIT)

Copyright (c) 2015 Chris Dutton, Garth Hitchens

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
