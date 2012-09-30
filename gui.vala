namespace StreamPlayer
{
  class StreamPlayer: Gtk.Window 
  {
    /* ********************* *
     *    privatne cleny     *
     * ********************* */
    
    private Streamer streamer;
    private Tracklist tracklist;
    
    private Gtk.TreeIter current_track;
    private Gtk.TreeIter current_selection;
    
    private bool can_unpause;

    /* widgety */  
    private Gtk.Box vbx_main_layout;
    private Gtk.MenuBar mb_menu;
    private Gtk.Toolbar tlb_toolbar;
    private Gtk.Statusbar stb_statusbar;
    private Gtk.Paned pn_library;
    private Gtk.Paned pn_tracklist;
    private Gtk.Paned pn_tracks_album;
    private Gtk.Paned pn_artist_album;
    private Gtk.Box vbx_tracklist_layout;
    
    private Gtk.ScrolledWindow sw_library;
    private Gtk.ScrolledWindow sw_artist;
    private Gtk.ScrolledWindow sw_album;
    private Gtk.ScrolledWindow sw_tracks;
    private Gtk.ScrolledWindow sw_tracklist;
    
    private Gtk.TreeView tw_library;
    private Gtk.TreeView tw_artist;
    private Gtk.TreeView tw_album;
    private Gtk.TreeView tw_tracks;
    
    /* moznosti tracklistu */
    //private Gtk.HButtonBox bb_tracklist_buttons;
    //private Gtk.Button b_tracklist_controls;
    private Gtk.MenuBar mb_tracklist;
    private Gtk.MenuItem mi_tracklist_controls;
    private Gtk.Menu m_tracklist_controls;
    private Gtk.ImageMenuItem mi_tracklist_delete;
    private Gtk.ImageMenuItem mi_tracklist_open;
    
    /* menubar */
    private Gtk.Menu m_multimedia;
    //private Gtk.Menu m_edit;
    //private Gtk.Menu m_view;
    //private Gtk.Menu m_playback;
    
    private Gtk.MenuItem mi_multimedia;
    private Gtk.MenuItem mi_edit;
    private Gtk.MenuItem mi_view;
    private Gtk.MenuItem mi_playback;
    
    private Gtk.ImageMenuItem smi_media_open;
    private Gtk.ImageMenuItem smi_media_close;
    
    private Gtk.AccelGroup acg;
   
    /* prvky toolbaru */
    private Gtk.ToolButton tb_back;
    private Gtk.ToolButton tb_play;
    private Gtk.ToolButton tb_pause;
    private Gtk.ToolButton tb_stop;
    private Gtk.ToolButton tb_forward;
    private Gtk.ToolButton tb_repeat;
    private Gtk.ToolButton tb_shuffle;
    private TrackInfo track_info;
    private PlaybackPositioner playback_positioner;
       
    /* ikony toolbaru */    
    private Gdk.Pixbuf icon_back;
    private Gtk.IconSet iset_back;
    private Gtk.Image img_back;
    private Gdk.Pixbuf icon_play;
    private Gtk.IconSet iset_play;
    private Gtk.Image img_play;
    private Gdk.Pixbuf icon_stop;
    private Gtk.IconSet iset_stop;
    private Gtk.Image img_stop;
    private Gdk.Pixbuf icon_forward;
    private Gtk.IconSet iset_forward;
    private Gtk.Image img_forward;
    private Gdk.Pixbuf icon_repeat;
    private Gtk.IconSet iset_repeat;
    private Gtk.Image img_repeat;
    private Gdk.Pixbuf icon_shuffle;
    private Gtk.IconSet iset_shuffle;
    private Gtk.Image img_shuffle;
    private Gdk.Pixbuf icon_pause;
    private Gtk.IconSet iset_pause;
    private Gtk.Image img_pause;
    
    private Gtk.Menu context_menu;
    private Gtk.ImageMenuItem delete_item;
    private Gtk.ImageMenuItem open_item;
    
    /*temporary*/
    private Gtk.Box temp_box;
    private Gtk.ProgressBar pbar;
    
    /* konstruktor */
    public StreamPlayer()
    {
      this.set_default_size(1200, 700);
      this.set_position(Gtk.WindowPosition.CENTER);
      this.set_border_width(1);
      this.set_title("ValaPlayer");
      
      can_unpause = false;
      
      try
      {
        this.icon = new Gdk.Pixbuf.from_file("icons/appicon.png");
      }
      catch(GLib.Error err)
      {
        GLib.printerr("Error while loading application icon: %s\n", err.message);
      }
      
      streamer = new Streamer();
      tracklist = new Tracklist(ref current_track, ref current_selection);
      
      vbx_main_layout = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
      vbx_main_layout.homogeneous = false;
      
      mb_menu = new Gtk.MenuBar();
      initialize_menubar();
      vbx_main_layout.pack_start(mb_menu, false, false, 0);
      
      tlb_toolbar = new Gtk.Toolbar();
      tlb_toolbar.get_style_context().add_class(Gtk.STYLE_CLASS_PRIMARY_TOOLBAR);
      tlb_toolbar.height_request = 50;
      initialize_toolbar();
           
      vbx_main_layout.pack_start(tlb_toolbar, false, false, 0);   
      
      /* rozmiestnenie prvkov */
      pn_library = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
      pn_library.position = 300;
      
            
      pn_tracklist = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
      pn_tracklist.position = 600;
      pn_library.pack2(pn_tracklist, false, false);
      
      pn_tracks_album = new Gtk.Paned(Gtk.Orientation.VERTICAL);
      pn_tracklist.pack1(pn_tracks_album, false, false);
                  
      pn_artist_album = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
      pn_tracks_album.pack1(pn_artist_album, false, false);
            
      vbx_main_layout.pack_start(pn_library, true, true, 0);
      
      stb_statusbar = new Gtk.Statusbar();
      vbx_main_layout.pack_start(stb_statusbar, false, false, 0);

      /* pridava scrollbary oknam */
      sw_library = new Gtk.ScrolledWindow(null, null);
      sw_library.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.ALWAYS);
      sw_library.set_shadow_type(Gtk.ShadowType.IN);
      sw_artist = new Gtk.ScrolledWindow(null, null);
      sw_artist.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.ALWAYS);
      sw_artist.set_shadow_type(Gtk.ShadowType.IN);
      sw_album = new Gtk.ScrolledWindow(null, null);
      sw_album.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.ALWAYS);
      sw_album.set_shadow_type(Gtk.ShadowType.IN);
      sw_tracks = new Gtk.ScrolledWindow(null, null);
      sw_tracks.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.ALWAYS);
      sw_tracks.set_shadow_type(Gtk.ShadowType.IN);
      sw_tracklist = new Gtk.ScrolledWindow(null, null);
      sw_tracklist.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.ALWAYS);
      sw_tracklist.set_shadow_type(Gtk.ShadowType.IN);
      
      /* kniznica -- zamenit za AbstractView */
      tw_library = new Gtk.TreeView();
      tw_artist = new Gtk.TreeView();
      tw_album = new Gtk.TreeView();
      tw_tracks = new Gtk.TreeView();

      /* ohranicenia widgetov */
      sw_library.margin_right = 4;
      sw_tracklist.margin_left = 4;
      sw_tracks.margin_top = 4;
      sw_artist.margin_right = 2;
      sw_album.margin_left = 2;
      
      sw_library.add(tw_library);
      sw_artist.add(tw_artist);
      sw_album.add(tw_album);
      sw_tracks.add(tw_tracks);
      sw_tracklist.add(tracklist);      
      
      //pn_library.pack1(sw_library, false, false);
      pbar = new Gtk.ProgressBar(); //zamzat
      temp_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 2); //zmazat
      temp_box.homogeneous = false; //zmazat
      temp_box.pack_start(sw_library, true, true, 0); //zmazat
      temp_box.pack_start(pbar, false, false, 0); //zmazat
      pn_library.pack1(temp_box, false, false); //zmazat
      pn_artist_album.pack1(sw_artist, false, false);
      pn_artist_album.pack2(sw_album, false, false);
      pn_tracks_album.pack2(sw_tracks, false, false);
      
      /* prvky tracklistu */
      vbx_tracklist_layout = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
      vbx_tracklist_layout.homogeneous = false;
      vbx_tracklist_layout.pack_start(sw_tracklist, true, true, 0);
      
      mb_tracklist = new Gtk.MenuBar();
      mi_tracklist_controls = new Gtk.MenuItem.with_label("Možnosti");
      m_tracklist_controls = new Gtk.Menu();
      mi_tracklist_controls.set_submenu(m_tracklist_controls);
            
      mi_tracklist_open = new Gtk.ImageMenuItem.from_stock(Gtk.Stock.OPEN, null);
      m_tracklist_controls.add(mi_tracklist_open);
      mi_tracklist_delete = new Gtk.ImageMenuItem.from_stock(Gtk.Stock.DELETE, null);
      m_tracklist_controls.add(mi_tracklist_delete);
      mb_tracklist.append(mi_tracklist_controls); //###
      
      vbx_tracklist_layout.pack_end(mb_tracklist, false, false, 0);
      
      pn_tracklist.add2(vbx_tracklist_layout);
      
      this.add(vbx_main_layout);
      
      /* pripojenie callbackov */
      this.destroy.connect(Gtk.main_quit);
      
      //b_tracklist_controls.clicked.connect(on_tracklist_options_clicked);
      mi_tracklist_delete.activate.connect(on_tracklist_delete_clicked);
      mi_tracklist_open.activate.connect(on_open_activated);
      
      tb_play.clicked.connect(on_play_clicked);
      tb_stop.clicked.connect(on_stop_clicked);
      tb_pause.clicked.connect(on_pause_clicked);
      tb_forward.clicked.connect(on_forward_clicked);
      tb_back.clicked.connect(on_back_clicked);
      
      tracklist.cursor_changed.connect(on_tracklist_selection_changed);
      tracklist.row_activated.connect(on_tracklist_row_activated);
      
      streamer.end_of_stream.connect(on_streamer_eos);
      streamer.playback_error.connect(on_streamer_error);
      streamer.player_stopped.connect(on_player_stopped);
      streamer.track_info_obtained.connect(on_track_info_obtained);
      streamer.player_playing.connect(on_player_playing);
      streamer.query_position_changed.connect(on_query_position_changed);
      streamer.track_duration_obtained.connect(on_track_duration_obtained);
      
      tracklist.file_path.connect(on_filepath_received);
      tracklist.button_press_event.connect(on_mouse_button_pressed);
      tracklist.content_changed.connect(on_tracklist_content_changed);
      
      playback_positioner.positioner.change_value.connect(on_positioner_change_value);
    }

    /* inicializacia menubaru */
    private void initialize_menubar()
    {
      acg = new Gtk.AccelGroup();
      this.add_accel_group(acg);
      
      /* multimedia menu */
      mi_multimedia = new Gtk.MenuItem.with_mnemonic("_Multimédia");
      m_multimedia = new Gtk.Menu();
      mi_multimedia.set_submenu(m_multimedia);
      
      smi_media_open = new Gtk.ImageMenuItem.from_stock(Gtk.Stock.OPEN, null);
      m_multimedia.add(smi_media_open);
      smi_media_open.add_accelerator("activate", acg, 'O', Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);
      smi_media_open.activate.connect(on_open_activated);
      
      smi_media_close = new Gtk.ImageMenuItem.from_stock(Gtk.Stock.CLOSE, null);
      m_multimedia.add(smi_media_close);
      smi_media_close.add_accelerator("activate", acg, 'X', Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);
      smi_media_close.activate.connect(on_mi_close_activated);

      mb_menu.append(mi_multimedia);
      
      mi_edit = new Gtk.MenuItem.with_mnemonic("_Upraviť");
      mb_menu.append(mi_edit);
      
      mi_view = new Gtk.MenuItem.with_mnemonic("_Zobraziť");
      mb_menu.append(mi_view);
      
      mi_playback = new Gtk.MenuItem.with_mnemonic("_Prehrávanie");
      mb_menu.append(mi_playback);
    }
    
    /* inicializacia toolbaru */
    private void initialize_toolbar()
    {
      try
      {
        icon_back = new Gdk.Pixbuf.from_file("icons/back.png");
        iset_back = new Gtk.IconSet.from_pixbuf(icon_back);
        img_back = new Gtk.Image.from_icon_set(iset_back, Gtk.IconSize.LARGE_TOOLBAR);
        icon_play = new Gdk.Pixbuf.from_file("icons/play.png");
        iset_play = new Gtk.IconSet.from_pixbuf(icon_play);
        img_play = new Gtk.Image.from_icon_set(iset_play, Gtk.IconSize.LARGE_TOOLBAR);
        icon_stop = new Gdk.Pixbuf.from_file("icons/stop.png");
        iset_stop = new Gtk.IconSet.from_pixbuf(icon_stop);
        img_stop = new Gtk.Image.from_icon_set(iset_stop, Gtk.IconSize.LARGE_TOOLBAR);
        icon_forward = new Gdk.Pixbuf.from_file("icons/forward.png");
        iset_forward = new Gtk.IconSet.from_pixbuf(icon_forward);
        img_forward = new Gtk.Image.from_icon_set(iset_forward, Gtk.IconSize.LARGE_TOOLBAR);
        icon_repeat = new Gdk.Pixbuf.from_file("icons/repeat.png");
        iset_repeat = new Gtk.IconSet.from_pixbuf(icon_repeat);
        img_repeat = new Gtk.Image.from_icon_set(iset_repeat, Gtk.IconSize.LARGE_TOOLBAR);
        icon_shuffle = new Gdk.Pixbuf.from_file("icons/shuffle.png");
        iset_shuffle = new Gtk.IconSet.from_pixbuf(icon_shuffle);
        img_shuffle = new Gtk.Image.from_icon_set(iset_shuffle, Gtk.IconSize.LARGE_TOOLBAR);
        icon_pause = new Gdk.Pixbuf.from_file("icons/pause.png");
        iset_pause = new Gtk.IconSet.from_pixbuf(icon_pause);
        img_pause = new Gtk.Image.from_icon_set(iset_pause, Gtk.IconSize.LARGE_TOOLBAR);
      }
      catch(GLib.Error e)
      {
        Gtk.MessageDialog dlg = new Gtk.MessageDialog(this, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, 
                                                      Gtk.ButtonsType.OK, "%s", e.message);
        dlg.set_title("Error");
        dlg.run();
        dlg.destroy();
      }
      
      tb_back = new Gtk.ToolButton(img_back, null);
      tb_back.set_size_request(50, 50);
      tlb_toolbar.add(tb_back);
      tb_play = new Gtk.ToolButton(img_play, null);
      tb_play.set_size_request(50, 50);
      tlb_toolbar.add(tb_play);
      tb_pause = new Gtk.ToolButton(img_pause, null);
      tlb_toolbar.add(tb_pause);
      tb_stop = new Gtk.ToolButton(img_stop, null);
      tb_stop.set_size_request(50, 50);
      tlb_toolbar.add(tb_stop);
      tb_forward = new Gtk.ToolButton(img_forward, null);
      tb_forward.set_size_request(50, 50);
      tlb_toolbar.add(tb_forward);
      tb_repeat = new Gtk.ToolButton(img_repeat, null);
      tb_repeat.set_size_request(50, 50);
      tlb_toolbar.add(tb_repeat);
      tb_shuffle = new Gtk.ToolButton(img_shuffle, null);
      tb_shuffle.set_size_request(50, 50);
      tlb_toolbar.add(tb_shuffle);
      
      playback_positioner = new PlaybackPositioner();
      tlb_toolbar.add(playback_positioner);
      playback_positioner.show_all();
      
      track_info = new TrackInfo();
      tlb_toolbar.add(track_info);
      track_info.show_all();
      track_info.visible = false;
    }
    
    /* SPRACOVANIE SIGNALOV */

    /** 
     * Funkcia, ktora je volana vzdy ked sa zmeni vybrana polozka tracklistu
     *  nastavi iterator current_selection, aby ukazoval na vybranu polozku
     *
     * @param void
     *
     * @retruns void 
     */
    private void on_tracklist_selection_changed()
    {
      Gtk.TreeModel model;
      Gtk.TreeIter iter;
      Gtk.TreeSelection selection;
      selection = tracklist.get_selection();
      GLib.List<Gtk.TreePath> paths = selection.get_selected_rows(out model);
      Gtk.TreePath first = paths.nth_data(0);
      model.get_iter(out iter, first);
      current_selection = iter;
    }
    
    /** 
     * Prehrat vybranu skadbu pri dvojkliku
     *
     * @param path nevyuziva sa
     * @param col nevyuziva sa
     *
     * @retruns void 
     */
    private void on_tracklist_row_activated(Gtk.TreePath path, Gtk.TreeViewColumn col)
    {
      if(streamer.is_playing())
        streamer.set_state_stop();
      current_track = current_selection;
      can_unpause = true;
      tracklist.play_current(ref current_track, ref streamer);
    }

    /* play selected track when button is clicked */
    private void on_play_clicked()
    {
      if(streamer.is_paused())
      {
        streamer.set_state_playing();
        return;
      }
      
      if(streamer.is_playing())
      {
        streamer.set_state_stop();
      }
      
      can_unpause = true;
      tracklist.play_current(ref current_track, ref streamer);
    }
    
    /* pause playback */
    private void on_pause_clicked()
    {
      if(can_unpause)
      {
        if(streamer.is_playing() == true)
        {
          streamer.pause();
          print("Player state: PAUSED\n");
          tb_play.set_icon_widget(img_play);
        }
        else
        {
          streamer.set_state_playing();
          print("Player stateL PLAYING\n");
        }
      }
      return;
    }

    /* stop playback */
    private void on_stop_clicked()
    {
      streamer.stop();
      can_unpause = false;
    }
    
    /* play next song when button is clicked */
    private void on_forward_clicked()
    {
      tracklist.play_next(ref current_track, ref current_selection, ref streamer);
    }
    
    private void on_back_clicked()
    {
      tracklist.play_previous(ref current_track, ref current_selection, ref streamer);
    }
    
    /* detect end of stream */
    private void on_streamer_eos()
    {
      print("End of Stream\n");
      Gtk.TreeIter iter;
      iter = current_track;
      if(!tracklist.model.iter_next(ref iter))
      {
        streamer.set_state_stop();
        can_unpause = false;
        return;
      }
      can_unpause = true;

      tracklist.play_next(ref current_track, ref current_selection, ref streamer);
    }
    
    /* show error message sent by streamer */
    private void on_streamer_error(string message)
    {
      print("STREAMER ERROR: %s\n", message);
      stb_statusbar.push(2, message);
      stb_statusbar.get_context_id("streamer error");
    }
    
    private void on_filepath_received(string path)
    {
      stb_statusbar.push(0, path);
      stb_statusbar.get_context_id("current track's path");
    }
    
    private void on_open_activated()
    {
      Gtk.FileChooserDialog dialog = new Gtk.FileChooserDialog("Otvoriť média", this, Gtk.FileChooserAction.OPEN, null);
      dialog.set_transient_for(this);
      dialog.set_select_multiple(true);
      
      dialog.add_button(Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL);
      dialog.add_button(Gtk.Stock.OPEN, Gtk.ResponseType.OK);
      
      Gtk.FileFilter filter = new Gtk.FileFilter();
      filter.set_filter_name("Audio súbory");
      filter.add_pattern("*.mp3");
      filter.add_pattern("*.wma");
      filter.add_pattern("*.ogg");
      dialog.add_filter(filter);
      
      GLib.SList<string> list = null;
      
      int result = dialog.run();
      
      switch(result)
      {
        case(Gtk.ResponseType.OK):
        {
          list = dialog.get_filenames();
          dialog.destroy();
          break;
        }
        case(Gtk.ResponseType.CANCEL):
        {
          dialog.destroy();
          break;
        }
        default:
          break;
      }
      
      if(list != null && list.length() != 0)
      {
        double fraction = 1.0 / list.length(); //zmazat - progressbar
        pbar.set_fraction(0.0);
        print("%f\n", fraction);
        for(uint i=0; i<list.length(); i++)
        {
          string uri = "file://" + list.nth_data(i);
          string duration;
          int64 n_dur;
          streamer.get_track_length(uri, out duration, out n_dur);
          TagStore tags = new TagStore();
          TagReader.get_tags(uri, out tags);
          string tracklist_item = tags.artist + " - " + tags.title;
          tracklist.add_item(tracklist_item, duration, list.nth_data(i), "0");
          tracklist.index_tracks();
          pbar.set_fraction(pbar.get_fraction() + fraction);
          while(Gtk.events_pending())
            Gtk.main_iteration();
        }
        print("\nTracklist size: %u\n", tracklist.size());
        pbar.set_fraction(0.0);
      }
    }
    
    private void on_player_stopped()
    {
      GLib.print("Player state: NULL\n");
      track_info.visible = false;
      playback_positioner.positioner.adjustment.value = 0.0;
      playback_positioner.positioner.set_sensitive(false);
      playback_positioner.duration = "00:00";
      playback_positioner.position = "00:00";
      this.set_title("ValaPlayer");
    }
    
    private void on_player_playing()
    {
      GLib.print("Player state: PLAYING\n");
      track_info.visible = true;
      playback_positioner.positioner.set_sensitive(true);
    }
    
    private void on_track_info_obtained(TagStore tags)
    {
      track_info.set_info(tags);
      string title = "ValaPlayer - " + tags.artist + " - " + tags.title;
      this.set_title(title);
    }
    
    private void on_track_duration_obtained(int64 duration)
    {
      Gtk.Adjustment adj = new Gtk.Adjustment(0.0, 0.0, (double) duration, ((double) duration) / 50.0, ((double) duration) / 20.0, 0.0);
      playback_positioner.positioner.set_adjustment(adj);
      playback_positioner.duration = Helpers.calculate_duration_string(duration);
    }
        
    private void on_query_position_changed(int64 position)
    {
      playback_positioner.positioner.adjustment.value = (double) position;
      playback_positioner.position = Helpers.calculate_duration_string(position);
    }
    
    private bool on_positioner_change_value(Gtk.ScrollType type, double val)
    {
      streamer.set_position((int64) val);
      return false;
    }
    
    private bool on_mouse_button_pressed(Gdk.EventButton event)
    {
      Gtk.TreeSelection selection = tracklist.get_selection();
      if(selection.count_selected_rows() <= 0)
      {
        return false;
      }
      
      if(event.button == 3)
      {
        context_menu = new Gtk.Menu();
        open_item = new Gtk.ImageMenuItem.from_stock(Gtk.Stock.OPEN, null);
        open_item.activate.connect(on_open_activated);
        context_menu.append(open_item);
        delete_item = new Gtk.ImageMenuItem.from_stock(Gtk.Stock.DELETE, null);
        delete_item.activate.connect(on_tracklist_delete_clicked);
        context_menu.append(delete_item);
        context_menu.show_all();
        context_menu.popup(null, null, null, event.button, event.time);
        return true;
      }
      return false;
    }
    
    private void on_tracklist_delete_clicked()
    {
      tracklist.delete_items(ref current_track, ref streamer);
    }
    
    private void on_tracklist_content_changed()
    {
      if(tracklist.size() == 0)
      {
        //print("Tracklist is empty\n");
        tracklist.can_delete = false;
        tracklist.set_dummy_model(true, ref current_track, ref current_selection);
      }
      else
      {
        //print("Tracklist is not empty\n");
        tracklist.can_delete = true;
        tracklist.set_dummy_model(false, ref current_track, ref current_selection);
      }
    }
    
    private void on_mi_close_activated()
    {
      Gtk.main_quit();
    }
  }
}
