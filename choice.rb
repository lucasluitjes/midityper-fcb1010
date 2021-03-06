class Choice
  def initialize controller
    @controller = controller
    @actions = [:root,[
      [:f_curr_tab, :f_curr_tab],
      [:f_new_tab, :f_new_tab],
      [:big_hotel, 'H'],
      [:return, Proc.new{@controller.xdo_key('Return')}],
      [:page_down, Proc.new{@controller.xdo_key('Page_Down')}],

      [:prevtab, Proc.new{@controller.xdo_key('Control_L+Shift_L+Tab')}],
      [:nexttab, Proc.new{@controller.xdo_key('Control_L+Tab')}],
      [:closetab, Proc.new{@controller.xdo_key('Control_L+F4')}],
      [:misc, [
        [:shell, [
          [:entr,'find | entr ruby '],
          [:ansible, [
            [:ap_diff, 'ansible-playbook site.yml -i hosts --check --diff '],
            [:ap_diff_tag, 'ansible-playbook site.yml -i hosts --check --diff -t  '],
            [:ap_diff_tag_tmp, 'ansible-playbook site.yml -i hosts --check --diff -t tmp '],
            [:ap, 'ansible-playbook site.yml -i hosts '],
            [:ap_tag, 'ansible-playbook site.yml -i hosts -t  '],
            [:ap_tag_tmp, 'ansible-playbook site.yml -i hosts -t tmp ']
          ]]
        ]],
        [:vim, [
          [:vnew, ':vnew .'],
          [:silk, 'V'],
          [:sulk, Proc.new {@controller.xdo_key 'Control_L+v'}],
          [:w, ':w'],
          [:shift_right, '>'],
          [:shift_left, '<'],
          [:repeat, '.'],
          [:yank, 'y'],
          [:x, 'x'],
          [:p, 'p']
        ]],
        [:conversate, [
          [:hi, 'hi'],
          [:ok, 'ok'],
          [:cool, 'cool'],
          [:exclaim, '!']
        ]]
      ]],
      [:escape, Proc.new{@controller.xdo_key('Escape')}],
      [:page_up, Proc.new{@controller.xdo_key('Page_Up')}]
    ]]
    @current_path = []
  end

  def choose value
    pp current_action
    if current_action.last.is_a?(Array)
      @current_path << value - 1
      return display_choices if current_action.last.is_a?(Array)
    end
    if current_action.last.is_a?(Symbol)
      send current_action.last
      return
    elsif current_action.last.is_a?(String)
      @controller.xdo_type current_action.last
    elsif current_action.last.is_a?(Proc)
      instance_eval &current_action.last
    end
    @current_path = []
    display_choices
  end

  def current_action 
    tmp = @actions
    @current_path.each do |i|
      tmp = tmp.last[i]
      break unless tmp
    end
    tmp
  end

  def display_choices str=nil
    File.open('choices','w') do |f|
      f.puts str if str
      current_action.last.each_with_index do |n,i|
        f.puts "#{i+1}) #{n.first.to_s}"
      end
    end
  end

  def test
    @controller.xdo_type 'test'
    @current_path = []
  end

  def f_curr_tab value, new_tab=false
    characters = [[nil], ('a'..'z')].map(&:to_a).flatten
    if @last_keys == nil
      File.open('choices','w') do |f|
        (1..26).each {|i| f.puts "#{i.to_s.rjust(2,'0')}) #{characters[i]}"}
      end
      @last_keys = []
      @controller.xdo_key new_tab ? 'F' : 'f'
    elsif @last_keys.size < 3
      @last_keys << value % 10
      puts @last_keys.inspect
    else
      @last_keys << value % 10
      puts @last_keys.inspect
      keys = ["#{@last_keys[0]}#{@last_keys[1]}","#{@last_keys[2]}#{@last_keys[3]}"].map(&:to_i)
      @controller.xdo_type keys.map {|n| characters[n] }.join
      @last_keys = nil
      @current_path = []
      display_choices
    end
  end

  def f_new_tab value
    f_curr_tab(value, true)
  end
end