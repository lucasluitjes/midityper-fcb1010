require_relative 'choice'

class Controller
  attr_reader :last_input, :denylist

  # this array configures which bank number corresponds to which bank method. For example:
  # bank 0 corresponds to the gnome_bank method, bank 1 to the vim_bank method, etc.
  BANKS = %w{gnome vim thunderbird scrolling none scrolling none trello thunderbird choice}

  def initialize
    @last_input = Time.now.to_f

    # commands with one of the results below, *are* allowed to be triggered multiple times within 0.4 seconds
    @denylist = ['w', 'number mode on', 'b', 'k', 'j', 'Up', 'Down'].flatten.map {|n| "xdotool key #{n}"}
    @choice = Choice.new(self)

    # a bunch of instance variables for the scrolling bank
    @lock = Mutex.new
    @kill_scroller = false
    @pause_scroller = true
    @intervals = [-0.1, -0.25, -0.5, -1, -2, -3, 0, 3, 2, 1, 0.5, 0.25, 0.1]
    @scroll_speed = @intervals.index(0)

    Thread.abort_on_exception = true
  end

  def process bank_index, value
    bank = BANKS[bank_index]
    if bank != 'choice'
      @choice.controller = nil
      @choice = Choice.new(self)
    end
    puts "bank #{bank || bank_index}, value #{value}"
    begin
      result = send(:"#{bank}_bank", value) || 'command not found'
      @last_input = Time.now.to_f unless denylist.include?(result)
      puts result
    rescue => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
  end

  def choice_bank value
    @choice.choose value
  end

  # this configures which pedal corresponds to which window. For example:
  # pedal 2 switches to a window with VirtualBox in the title
  GNOME_WINDOWS = [nil, nil, :VirtualBox, :chromium, :Firefox, :thunderbird, :sublime, :slack]

  def gnome_bank value
    if value == 1
      xdo_key "Return"
    else
      program = GNOME_WINDOWS[value]
      xdotool("search --onlyvisible #{program} windowactivate")
    end
  end

  # this bank is for repeated scrolling, see the comments inside the method
  # and play with the buttons to see what happens (in a window with a scroll bar)
  def scrolling_bank value
    setup_thread { scrolling } unless @lock.locked?

    value -= 1

    case value
    when 0 # button 1, down, increase scrolling
      @pause_scroller = false
      @scroll_speed -= 1 unless @scroll_speed == 0
      "scroll vec: #{@intervals[@scroll_speed]}"
    when 1 # button 2, up, decrease scrolling
      @pause_scroller = false
      @scroll_speed += 1 unless @scroll_speed == @intervals.size - 1
      "scroll vec: #{@intervals[@scroll_speed]}"
    when 2 # button 3, pause
      @pause_scroller = !@pause_scroller
      "pause_scroller is #{@pause_scroller}"
    when 3 # button 4, reset
      @scroll_speed = 6
      @kill_scroller = true
      @pause_scroller = true
      finish_thread
      @kill_scroller = false
      'scroll thread reset'
    end
  end

  def scrolling
    last_scroll = Time.now.to_f
    until @kill_scroller
      sleep 0.05

      next if @pause_scroller

      since_last_scroll = Time.now.to_f - last_scroll
      vec = @intervals[@scroll_speed] # scroll speed and direction
      # puts vec
      if since_last_scroll > vec.abs
        xdotool("click #{vec.positive? ? 4 : 5}")
        last_scroll = Time.now.to_f
      end
    end
  end

  def setup_thread
    @lock.lock
    @thr = Thread.new do |_thread|
      yield
    end
    :started_thread
  end

  def finish_thread
    @lock.unlock
    @thr.value
  end

  # the first two pedals are for clicking links, see demo
  CHROMIUM_KEYS = [nil, nil, 'Return', 'Right', 'Down', 'Page_Down', 'Tab', 'Escape', 'H', 'Up', 'Page_Up']
  def chromium_bank value
    if @ascii_buffer
      @ascii_buffer << (value == 10 ? 0 : value)
      
      if @ascii_buffer.size == 2
        index = @ascii_buffer.map(&:to_s).join.to_i
        if @first_key_pressed
          @ascii_buffer = nil
        else
          @ascii_buffer = []
          @first_key_pressed = true
        end
        puts index

        character = ('a'..'z').to_a[index % 30]
        character.upcase! if index > 29
        xdo_key character unless index == 99
      else
        "#{@ascii_buffer.last} added to buffer"
      end
    else
      if value == 1
        xdo_key 'F' 
        @ascii_buffer = []
        @first_key_pressed = false
        'created buffer'
      else key = CHROMIUM_KEYS[value]
        xdo_key key
      end
    end
  end

  THUNDERBIRD_KEYS = [
    nil, 
    nil,
    'Menu+k+u',
    'Control_L+F6',
    'Down',
    'Page_Down',
    'Control_L+Shift_L+Tab', 
    'Control_L+Tab', 
    'Control_L+F4',
    'Up',
    'Page_Up'
  ]
  def thunderbird_bank value
 
    if value == 1
      curr = `DISPLAY=':0.0' xdotool getwindowfocus getwindowname`
      puts curr.inspect
      if !curr.include?(" - Mozilla Firefox\n")
        xdo_key "Return"
      else
        xdo_key "Control_L+Alt_L+r"
      end
    else
      xdo_key THUNDERBIRD_KEYS[value]
    end
  end

  TRELLO_KEYS = [
    nil, 
    'Left',
    'Down',
    'Right',
    'Return',
    'Page_Down',
    'l', 
    'Up', 
    '7',
    'Escape',
    'Page_Up'
  ]
  def trello_bank value
    xdo_key TRELLO_KEYS[value]
  end


  MISC_KEYS = [ 
    nil,
    'Left',
    'j',
    'Right',
    'w',
    'Page_Down',
    'k',
    'b',
    'Return',
    nil,
    'Page_Up'
  ]
  def misc_bank value
    if MISC_KEYS[value] == 'b'
      xdo_type 'dd'
    else
      xdo_key MISC_KEYS[value]
    end
  end

  VIM_KEYS = [
    nil,
    'Control_L+h',
    'j',
    'Control_L+l',
    'w',
    'Page_Down',
    'k',
    'b',
    'Return',
    nil,
    'Page_Up'
  ]

  def vim_bank value
    if @number
      @number = false
      xdo_key value.to_s
    else
      if key = VIM_KEYS[value]
        xdo_key key
      #elsif [4, 7].include? value
      #  xdo_type(value == 4 ? ':vnew .' : ':q')
      #  xdo_key 'Return'
      else
        @number = true
        'number mode on'
      end
    end
  end

  def _bank value
    'bank not found'
  end

  def wmiir str
    `DISPLAY=':0.0' wmiir xwrite #{str}`
    "wmiir xwrite #{str}"
  end

  def xdo_key key
    `DISPLAY=':0.0' xdotool key #{key}`
    "xdotool key #{key}"
  end
  
  def xdo_type str
    `DISPLAY=':0.0' xdotool type '#{str}'`
    "xdotool type '#{str}'"
  end

  def xdotool str
    `DISPLAY=':0.0' xdotool #{str}`
    "xdotool #{str}"
  end
end
