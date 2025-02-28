# Ruby Concurrency Examples
### Companion repo to my blog article [here](https://www.jakebills.com/posts/server_applications_in_ruby/)
## Usage
```shell
$ bundle
$ ruby server.rb # update file to test different server designs
# in a separate terminal:
$ telnet localhost 2000 # or open port of your choice
  Trying ::1...
  Connected to localhost.
  Escape character is '^]'.
  hello?
  hello?
  ^]
  telnet> ^C
$
```