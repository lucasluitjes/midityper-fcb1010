require 'unimidi'
require 'pp'
require 'pry'

# patch to avoid using 100% cpu (is this still necessary or did they fix this?)
module AlsaRawMIDI
  class Input
    def gets
      until enqueued_messages?
        sleep 0.01
      end
      msgs = enqueued_messages
      @pointer = @buffer.length
      msgs
    end
  end
end

class Reader
  def initialize
    reload_controller
    @input = UniMIDI::Input.use(:first)
    monitor_usb
    start_loop
  end

  def monitor_usb
    usb_connect = `dmesg|grep USB2MIDI|tail -n1`
    Thread.new do
      loop do
        exit unless usb_connect == `dmesg|grep USB2MIDI|tail -n1`
        sleep 5
      end
    end
  end

  def reload_controller
    @mtime = File.mtime('controller.rb')
    load('./controller.rb')
    @controller = Controller.new
  end

  def start_loop
    File.open('log','w') do |f|
      f.sync = true
      loop do
        begin
          reload_controller unless File.mtime('controller.rb') == @mtime
        rescue SyntaxError => e
          puts e.inspect
          puts e.backtrace
        end
        data = @input.gets_data
        puts "\n" + data.inspect

        # switch pedals use 192, analog pedals use 176 (I think)
        if data[0] == 192
          raw = data[1] || 0

          # don't process multiple events within 0.4 seconds,
          # sometimes FCB1010 pedals trigger twice when pressed once
          if (Time.now.to_f - @controller.last_input) > 0.4
            f.puts raw / 10

            # first argument is bank number, second is pedal number
            @controller.process(raw / 10, (raw % 10) + 1)
          end
        end
      end
    end
  end
end

Reader.new
