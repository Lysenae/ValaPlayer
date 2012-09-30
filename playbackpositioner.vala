namespace StreamPlayer
{
  class PlaybackPositioner: Gtk.ToolItem
  {
    private Gtk.Scale _positioner;
    private Gtk.Label _label_position;
    private Gtk.Label _label_duration;
    private Gtk.Label _label_slash;
    private Gtk.Table layout;
    private Gtk.Table sublayout;
    
    public PlaybackPositioner()
    {
      layout = new Gtk.Table(2, 1, true);
      
      _positioner = new Gtk.Scale(Gtk.Orientation.HORIZONTAL, null);
      _positioner.set_range(0.0, 0.0);
      _positioner.width_request = 250;
      _positioner.draw_value = false;
      _positioner.set_sensitive(false);
      layout.attach(_positioner, 0, 1, 0, 1, Gtk.AttachOptions.EXPAND, Gtk.AttachOptions.EXPAND, 3, 3);
      
      sublayout = new Gtk.Table(1, 3, false);
      
      _label_position = new Gtk.Label("00:00");
      _label_duration = new Gtk.Label("00:00");
      _label_slash = new Gtk.Label("/");
      sublayout.attach(_label_position, 0, 1, 0, 1, Gtk.AttachOptions.EXPAND, Gtk.AttachOptions.EXPAND, 2, 3);
      sublayout.attach(_label_slash, 1, 2, 0, 1, Gtk.AttachOptions.EXPAND, Gtk.AttachOptions.EXPAND, 2, 3);
      sublayout.attach(_label_duration, 2, 3, 0, 1, Gtk.AttachOptions.EXPAND, Gtk.AttachOptions.EXPAND, 2, 3);
      
      layout.attach(sublayout, 0, 1, 1, 2, Gtk.AttachOptions.EXPAND, Gtk.AttachOptions.EXPAND, 3, 3);
      
      this.add(layout);
      this.can_focus = false;
      this.can_default = false;
    }
    
    public Gtk.Scale positioner
    {
      get
      {
        return _positioner;
      }
    }
    
    public string position
    {
      get
      {
        return _label_position.get_text();
      }
      set
      {
        _label_position.set_text(value);
      }
    }

    public string duration
    {
      get
      {
        return _label_duration.get_text();
      }
      set
      {
        _label_duration.set_text(value);
      }
    }
  }
}
