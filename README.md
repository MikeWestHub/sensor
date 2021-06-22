# Sensor

Sensor is a Command Line Interface that allows the manipulation of files within a given file system. Primary operations are writing, updating, deleting and executing. This Gem is currently built with running on Mac and Linux systems in mind. 

Sensor also supports the forwarding of process execution information over HTTP to an address and port of your choice. 

## Installation

Clone this repository:

    $ git clone git@github.com:westmd23/sensor.git

And then execute:

    $ bundle install

Run the following to make the `sensor` file executable:

    $ chmod +x sensor

## Usage

The Sensor CLI expects the full or relative path to a filename as the first argument. By default, the Sensor framework will attempt to execute the file if no flags are given.

Example:

    $ ./sensor /bin/date

Or, if you haven't made `sensor` executable:

    $ ruby sensor /bin/date

Descriptions for all available options can be printed by passing the `--help` flag. All flags beside the `--write` flag must be passed with a vaid filename. Both the `--write` and `--update` flags must be accompanied by the `--content` flag. The full option list follows:
```bash
-w, --write
-u, --update
-d, --delete
-x, --execute
-c, --content CONTENT
-f, --forward 
```

The `--forward` flag can be passed with any arguments to send a JSON body containing information about the Sensor process to an address and port of your choosing. Sensor uses `localhost` and `2000`as the default `ADDRESS` and `PORT` respectively. To change the location of the server you would like to forward to, set the `ADDRESS` and `PORT` variables in your environment.

    $ export ADDRESS=example.com
    $ export PORT=1234

Example command line with `--forward`:
```bash
$ ./sensor sensor.txt -w -c "Hello, Sensor!!" -f
```

Much of the activity that takes place in Sensor is captured and logged as JSON in `logs/sensor.log`. To watch the logs as you interact with the command line, run:

    $ tail -f log/sensor.log

`*.log` is ignored by git so you will have to run a command line process to create the log file before you can tail.

See the `tcp_test_server.rb` command in the Testing section to check your network output when passing the `--forward` flag.

## Testing

To run the rspec suite, run the following command after `bundle install` has completed successfully:

    $ rspec

There is also a `docker-compose.yml` that runs the spec suite in a Linux environment. This can be run with:

    $ docker-compose up
 
To manually test network communication, Sensor ships with a simle TCP server that can be found in `spec/tcp_test_server.rb`. This server allows you to pass command line input with the `--forward` flag and see the headers and body generated from the `POST` request. To run the server:

    $ ruby spec/tcp_test_server.rb

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
